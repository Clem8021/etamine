class CleanInvalidRoseVarieties < ActiveRecord::Migration[8.0]
  def up
    valid_varieties = %w[explorer esperance avalanche]

    # Supprimer toutes les roses qui ne sont pas dans la liste
    Product.where(category: "roses")
           .where.not(variety: valid_varieties)
           .destroy_all
  end

  def down
    # Pas de restauration possible (les enregistrements supprimés ne reviennent pas)
    say "⚠️ Impossible de restaurer les anciennes variétés de roses supprimées."
  end
end
