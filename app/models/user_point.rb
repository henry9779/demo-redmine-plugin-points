class UserPoint < ActiveRecord::Base
  belongs_to :user
  has_many :logs, class_name: 'UserPointLog', foreign_key: 'user_point_id', dependent: :destroy

  validates :user_id, presence: true, uniqueness: true

  def init_log(user)
    UserPointLog.new(user_point: self, user: user)
  end
end
