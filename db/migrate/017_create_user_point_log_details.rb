class CreateUserPointLogDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :user_point_log_details do |t|
      t.integer :user_point_log_id
      t.string :property
      t.integer :user_id
      t.string :old_value
      t.string :value
    end
  end
end
