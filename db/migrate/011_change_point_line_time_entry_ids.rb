class ChangePointLineTimeEntryIds < ActiveRecord::Migration[5.2]
  def up
    change_column :point_lines, :time_entry_ids, :text
  end

  def down
    change_column :point_lines, :time_entry_ids, :string
  end
end
