class CreateDeliveryDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :delivery_details do |t|
      t.references :order, null: false, foreign_key: true
      t.string :mode
      t.date :date
      t.string :day
      t.string :time_slot
      t.text :ceremony_info
      t.string :recipient_name
      t.string :recipient_firstname
      t.string :recipient_address
      t.string :recipient_zip
      t.string :recipient_city
      t.string :recipient_phone
      t.string :sender_name
      t.string :sender_phone
      t.text :notes

      t.timestamps
    end
  end
end
