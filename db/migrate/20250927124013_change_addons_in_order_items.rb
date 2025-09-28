class ChangeAddonsInOrderItems < ActiveRecord::Migration[7.1]
  def up
    # Supprime l'ancienne colonne (string)
    remove_column :order_items, :addons, :string if column_exists?(:order_items, :addons, :string)

    # Ajoute la nouvelle colonne sous forme de tableau
    add_column :order_items, :addons, :text, array: true, default: []
  end

  def down
    # Supprime la colonne tableau
    remove_column :order_items, :addons if column_exists?(:order_items, :addons)

    # Réajoute la colonne en string simple
    add_column :order_items, :addons, :string
  end
end
