class ChangeAddonsToArrayInOrderItems < ActiveRecord::Migration[7.0]
  def change
    # Supprimer l’ancienne colonne string si elle existe
    remove_column :order_items, :addons, :string

    # Recréer en array de string avec valeur par défaut []
    add_column :order_items, :addons, :string, array: true, default: [], null: false
  end
end
