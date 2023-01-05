class CreatePointLines < ActiveRecord::Migration[5.2]
  def change
    create_table :point_lines do |t|
      t.integer :point_id
      t.integer :user_id
      t.integer :project_id
      t.string :time_entry_ids
      t.string  :description
      t.decimal :total_entries, precision: 10, scale: 2, default: 0
      t.decimal :value, precision: 10, scale: 2, default: 0
      t.decimal :convert_value, precision: 10, scale: 2, default: 0
      t.decimal :carry_value, precision: 10, scale: 2, default: 0

      t.timestamps null: false
    end
    add_index :point_lines, :point_id
    add_index :point_lines, :user_id
    add_index :point_lines, :project_id
  end
end
