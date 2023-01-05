class AddPointIdToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :point_id, :integer
  end
end
