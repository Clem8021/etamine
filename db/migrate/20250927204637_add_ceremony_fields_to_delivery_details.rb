class AddCeremonyFieldsToDeliveryDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :delivery_details, :ceremony_date, :date
    add_column :delivery_details, :ceremony_time, :time
    add_column :delivery_details, :ceremony_location, :string
  end
end
