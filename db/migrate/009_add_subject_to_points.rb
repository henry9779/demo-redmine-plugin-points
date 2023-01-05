class AddSubjectToPoints < ActiveRecord::Migration[5.2]
  def change
    add_column :points, :subject, :string
  end
end
