class CreateClosedDates < ActiveRecord::Migration[8.0]
  def change
    create_table :closed_dates do |t|
      t.date :date
      t.string :label
      t.boolean :recurring

      t.timestamps
    end
  end
end
