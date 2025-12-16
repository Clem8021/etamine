class AddCascadeToDeliveryDetails < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :delivery_details, :orders
    add_foreign_key :delivery_details, :orders, on_delete: :cascade
  end
end
