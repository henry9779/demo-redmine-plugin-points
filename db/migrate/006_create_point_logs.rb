class CreatePointLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :point_logs do |t|
      t.integer   :point_id
      t.text      :note
      t.integer   :user_id
      t.timestamps
    end
  end
end
