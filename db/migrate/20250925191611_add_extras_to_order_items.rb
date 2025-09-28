class AddExtrasToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :message_card, :boolean
    add_column :order_items, :message_text, :text
    add_column :order_items, :ribbon, :boolean
    add_column :order_items, :ribbon_text, :text
  end
end
