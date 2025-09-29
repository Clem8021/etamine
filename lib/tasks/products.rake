namespace :products do
  desc "Supprimer les produits avec une catégorie invalide"
  task clean: :environment do
    valid_categories = Product::CATEGORIES
    invalid_products = Product.where.not(category: valid_categories)

    if invalid_products.any?
      puts "⚠️ Produits trouvés avec une catégorie invalide :"
      invalid_products.group_by(&:category).each do |cat, prods|
        puts "  - #{cat} (#{prods.count} produits)"
      end

      count = invalid_products.count
      invalid_products.destroy_all
      puts "✅ #{count} produits supprimés."
    else
      puts "🎉 Aucun produit invalide trouvé."
    end
  end
end
