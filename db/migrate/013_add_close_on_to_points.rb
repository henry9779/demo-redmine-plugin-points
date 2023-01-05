class AddCloseOnToPoints < ActiveRecord::Migration[5.2]
  def change
    add_column :points, :closed_on, :datetime
  end
end
