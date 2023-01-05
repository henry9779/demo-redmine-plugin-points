class PointLine < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :point
  belongs_to :user
  belongs_to :project

  validates :value, presence: true

  enum status_id: { pending: 0, confirm: 1, reject: 2, finish: 3 }, _prefix: true

  safe_attributes 'point_id',
                  'user_id',
                  'project_id',
                  'time_entry_ids',
                  'description',
                  'total_entries',
                  'value',
                  'convert_value',
                  'carry_value',
                  'status_id',
                  'user_unit',
                  'user_area',
                  'purple_no'

  serialize :time_entry_ids, Array

  after_create :set_time_entry_point_id

  after_destroy :empty_time_entry_point_id
  after_destroy :update_point_amount

  scope :without_reject, -> { where.not(status_id: self.status_ids['reject']) }

  def retrieve_time_entries
    ids = self.time_entry_ids
    TimeEntry.where(id: ids)
  end

  def update_values
    if self.status_id_pending?
      time_entries = self.retrieve_time_entries
      update_total_entries = time_entries.map(&:hours).reduce(:+)
      self.update(total_entries: update_total_entries)

      update_convert_value = self.value * self.total_entries
      self.update(convert_value: update_convert_value)

      unless self.convert_value.zero? && self.carry_value.nonzero?
        update_carry_value = point.carry_value_format(convert_value)
        self.update(carry_value: update_carry_value)
      end
    end
  end

  private

  def set_time_entry_point_id
    time_entries = self.retrieve_time_entries
    time_entries.update_all(point_id: self.point.id)
  end

  def empty_time_entry_point_id
    time_entries = self.retrieve_time_entries
    time_entries.update_all(point_id: nil)
  end

  def update_point_amount
    point_lines = self.point.lines
    amount = point_lines.map(&:carry_value).reduce(:+)
    self.point.amount = amount
  end
end
