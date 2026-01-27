class AddUniqueIndexToMessageCardProducts < ActiveRecord::Migration[8.0]
  def change
    add_index :message_card_products,
              [:product_id, :message_card_id],
              unique: true,
              name: "index_message_card_products_on_product_id_and_message_card_id"
  end
end
