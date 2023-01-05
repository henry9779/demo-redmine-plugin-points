class CreateUserPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :user_points do |t|
      t.integer :user_id, uniqueness: true, null: false
      t.decimal :value, precision: 10, scale: 2, default: 0, null: false
      t.integer :update_by_id

      t.timestamps
    end
  end
end
