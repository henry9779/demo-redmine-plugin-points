class CreatePointSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :point_settings do |t|
      t.integer :user_id, uniqueness: true, null: false

      t.timestamps
    end
  end
end
