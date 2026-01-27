# db/migrate/20260126194523_create_message_card_products.rb
class CreateMessageCardProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :message_card_products do |t|
      t.references :message_card, null: false, foreign_key: true
      t.references :product,      null: false, foreign_key: true

      t.timestamps

      add_index :message_card_products, [:product_id, :message_card_id], unique: true
    end
  end
end
