class CreateAvailableDates < ActiveRecord::Migration[8.0]
  def change
    create_table :available_dates do |t|
      t.date :date
      t.boolean :available

      t.timestamps
    end
  end
end
