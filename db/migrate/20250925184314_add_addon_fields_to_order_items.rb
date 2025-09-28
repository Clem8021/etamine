class AddAddonFieldsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :addon_text, :text
    add_column :order_items, :addon_type, :string
  end
end
