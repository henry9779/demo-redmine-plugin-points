class UserPointLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_point

  has_many :details,
           class_name: 'UserPointLogDetail',
           foreign_key: 'user_point_log_id',
           dependent: :delete_all

  def save(&args)
    details.empty? ? false : super
  end

  def add_detail(property, user, old_value, value)
    details << UserPointLogDetail.new(
      property: property,
      user: user,
      old_value: old_value,
      value: value
    )
  end

  def add_point_detail(user, old_value, value)
    add_detail('point', user, old_value, value)
  end

  def add_remark_detail(user, old_value, value)
    add_detail('remark', user, old_value, value)
  end
end
