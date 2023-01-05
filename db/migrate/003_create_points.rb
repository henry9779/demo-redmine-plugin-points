class CreatePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :points do |t|
      t.integer  :author_id
      t.integer  :status_id, default: 0, null: false
      t.decimal  :amount, precision: 10, scale: 2, default: 0, null: false
      t.text     :description
      t.datetime :point_date, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps null: false
    end
  end
end
