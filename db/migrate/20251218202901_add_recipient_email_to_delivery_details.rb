class AddRecipientEmailToDeliveryDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :delivery_details, :recipient_email, :string
  end
end
