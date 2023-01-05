class AddPointLinesFields < ActiveRecord::Migration[5.2]
  def change
    add_column :point_lines, :user_unit, :string
    add_column :point_lines, :user_area, :string
    add_column :point_lines, :purple_no, :string
  end
end
