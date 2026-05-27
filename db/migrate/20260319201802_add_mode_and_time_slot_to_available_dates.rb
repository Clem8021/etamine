class AddModeAndTimeSlotToAvailableDates < ActiveRecord::Migration[8.0]
  def change
    add_column :available_dates, :mode, :string
    add_column :available_dates, :time_slot, :string
  end
end
