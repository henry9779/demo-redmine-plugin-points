class CreateUserPointLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_point_logs do |t|
      t.integer :user_point_id
      t.integer :user_id

      t.timestamps
    end
  end
end
