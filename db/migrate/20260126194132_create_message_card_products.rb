class CreateMessageCardProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :message_card_products do |t|
      t.references :message_card, null: false, foreign_key: true
      t.references :product,      null: false, foreign_key: true
      t.timestamps
    end
  end
end
