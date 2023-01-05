class CreatePointLogDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :point_log_details do |t|
      t.integer   :point_log_id
      t.integer   :log_detail_id
      t.string    :property   #attr => 本身欄位, cf => 自訂欄位
      t.string    :prop_key
      t.string    :old_value
      t.string    :value
      t.timestamps
    end
  end
end
