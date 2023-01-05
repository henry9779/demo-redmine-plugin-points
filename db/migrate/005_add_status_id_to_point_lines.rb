class AddStatusIdToPointLines < ActiveRecord::Migration[5.2]
  def change
    add_column :point_lines, :status_id, :integer, default: 0, null: false
  end
end
