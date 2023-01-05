class ChangeUserPointsValue < ActiveRecord::Migration[5.2]
  def up
    change_column_null :user_points, :value, true
  end

  def down
    change_column_null :user_points, :value, false
  end
end
