class AddAddonsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :addon_card_type, :string
    add_column :order_items, :addon_card_text, :text
    add_column :order_items, :addon_ruban_text, :text
  end
end
