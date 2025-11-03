class AddFlagsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :addon_card, :boolean, default: false, null: false unless column_exists?(:order_items, :addon_card)
    add_column :order_items, :addon_ruban, :boolean, default: false, null: false unless column_exists?(:order_items, :addon_ruban)
  end
end
