class AddRemarkToUserPoints < ActiveRecord::Migration[5.2]
  def change
    add_column :user_points, :remark, :string
  end
end
