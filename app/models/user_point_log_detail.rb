class UserPointLogDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_point_log
end
