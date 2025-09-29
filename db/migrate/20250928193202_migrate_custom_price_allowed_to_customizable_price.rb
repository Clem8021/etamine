class MigrateCustomPriceAllowedToCustomizablePrice < ActiveRecord::Migration[8.0]
  def up
    # On copie les valeurs de custom_price_allowed dans customizable_price
    execute <<-SQL
      UPDATE products
      SET customizable_price = custom_price_allowed
    SQL

    # Ensuite, on supprime la colonne custom_price_allowed
    remove_column :products, :custom_price_allowed, :boolean
  end

  def down
    # On restaure la colonne si on rollback
    add_column :products, :custom_price_allowed, :boolean, default: false

    # On recopie depuis customizable_price
    execute <<-SQL
      UPDATE products
      SET custom_price_allowed = customizable_price
    SQL
  end
end
