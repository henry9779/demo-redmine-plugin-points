class Point < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  has_many :lines, class_name: 'PointLine', foreign_key: 'point_id', dependent: :delete_all

  has_many :logs, class_name: 'PointLog', foreign_key: 'point_id', dependent: :destroy

  enum status_id: { pending: 0, sync: 1, reject: 2, finish: 3,
                    partially_reject: 4, in_review: 5, fail: 6 }, _prefix: true

  validates :subject,
            :author_id,
            :status_id,
            :amount,
            :point_date,
            :start_date,
            :end_date, presence: true

  safe_attributes 'subject',
                  'author_id',
                  'status_id',
                  'amount',
                  'description',
                  'point_date',
                  'start_date',
                  'end_date',
                  'lines_attributes'

  accepts_nested_attributes_for :lines, allow_destroy: true

  before_save :calculate_amount
  after_destroy :set_time_entry_point_id_nil

  def lines_from_time_entries(time_entries)
    self.lines ||= []
    decimal_entries = time_entries.each do |entry|
      entry.hours = entry.hours.round(2)
    end

    entry_data = decimal_entries.pluck(:project_id, :user_id, :hours)
    entries = entry_data.group_by { |e| [e.first, e.second] }.transform_values { |v| v.map(&:last).reduce(:+) }
    date_range = (time_entries.map(&:spent_on).min..time_entries.map(&:spent_on).max)
    purple_no_cf_id = CustomField.find_by(type: 'ProjectCustomField', name: '紫藤案號').try(:id)

    entries.each do |k, v|
      user = User.find_by(id: k[1])
      project = Project.find_by(id: k[0])
      entry_ids = time_entries.where(user_id: user, project_id: project, spent_on: date_range).pluck(:id).map(&:to_s)
      default_value = user&.user_point&.value || 0.0
      convert_value = default_value * v
      carry_value = carry_value_format(convert_value)
      purple_no = project.custom_field_value(purple_no_cf_id)

      self.lines << PointLine.new(user_id: user.id,
                                  project_id: project.id,
                                  total_entries: v,
                                  time_entry_ids: entry_ids,
                                  value: default_value,
                                  convert_value: convert_value,
                                  carry_value: carry_value,
                                  user_area: user.area_cf_value,
                                  user_unit: user.unit_cf_value,
                                  purple_no: purple_no,
                                  edit_by: user.mail,
                                  description: user&.user_point&.remark)
    end

    sort_entires_to_lines
  end

  # 依照 專案 紫藤案號 及 用戶 英文名排序後，將 lines 資料更新
  def sort_entires_to_lines
    sort_entries = self.lines.sort_by { |line| [line.purple_no, line.user.lastname] }
    self.lines = []
    self.lines << sort_entries
  end

  def init_log(user, note = '')
    @current_log ||= PointLog.new(point: self, user: user, note: note)
  end

  def current_log
    @current_log
  end

  def waiting_for_sync?
    self.status_id_pending?
  end

  def sync_failed?
    self.status_id_fail?
  end

  def carry_value_format(convert_value)
    if convert_value % 10 < 2.5 # 原始計算 尾數 0 - 2.49  結算點數尾數 為 0
      convert_value.floor(-1)
    elsif convert_value % 10 < 7.5 # 原始計算 尾數 2.5 - 7.49 結算點數尾數 為 5
      convert_value.floor(-1) + 5
    else # 原始計算 尾數 7.5 - 9.99 結算點數進位 10
      convert_value.floor(-1) + 10
    end
  end

  def calculate_amount
    self.amount = self.lines.map(&:carry_value).reduce(:+)
  end

  def set_time_entry_point_id_nil
    time_etries = TimeEntry.where(point_id: self)
    time_etries.update_all(point_id: nil)
  end

  def date_range
    "#{self.start_date.to_date} - #{self.end_date.to_date}"
  end
end
