class PointLog < ActiveRecord::Base
  has_many :details, class_name: 'PointLogDetail', foreign_key: 'point_log_id', dependent: :delete_all

  belongs_to :point
  belongs_to :user

  def save(&args)
    details.empty? ? false : super
  end

  def add_attribute_detail(attribute, old_value, value, detail_id = nil)
    add_detail('attr', attribute, old_value, value, detail_id)
  end

  def add_detail(property, prop_key, old_value, value, detail_id = nil)
    details << PointLogDetail.new(
      property: property,
      prop_key: prop_key,
      old_value: old_value,
      value: value,
      log_detail_id: detail_id
    )
  end
end
