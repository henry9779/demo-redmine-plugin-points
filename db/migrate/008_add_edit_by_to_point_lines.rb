class AddEditByToPointLines < ActiveRecord::Migration[5.2]
  def change
    add_column :point_lines, :edit_by, :string
  end
end
