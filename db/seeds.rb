# db/seeds.rb

puts "🌱 Lancement des seeds..."

# 🚨 Nettoyage des catégories invalides
valid_categories = Product::CATEGORIES
invalid_products = Product.where.not(category: valid_categories)

if invalid_products.any?
  puts "⚠️ Suppression des produits avec catégories invalides : #{invalid_products.pluck(:category).uniq.join(', ')}"
  invalid_products.destroy_all
else
  puts "🎉 Aucune catégorie invalide trouvée"
end

# 🚨 Nettoyage des variétés invalides de roses
valid_varieties = %w[explorer esperance avalanche]
invalid_roses = Product.where(category: "roses").where.not(variety: valid_varieties)

if invalid_roses.any?
  puts "⚠️ Suppression des variétés de roses invalides : #{invalid_roses.pluck(:variety).uniq.join(', ')}"
  invalid_roses.destroy_all
else
  puts "🎉 Aucune variété de roses invalide trouvée"
end

# 🌸 Bouquets Composés
# Prix de 25€ à 150€ (bouquets ronds & bulles)
bouquet_round_prices = (25..150).step(5).map { |p| ["#{p}€", p * 100] }.to_h

# Prix de 15€ à 150€ (bouquets variés)
bouquet_varie_prices = (15..150).step(5).map { |p| ["#{p}€", p * 100] }.to_h

Product.find_or_initialize_by(name: "Bouquet rond").update!(
  category: "compositions",
  product_type: "rond",
  price_options: bouquet_round_prices,
  customizable_price: true,
  image_url: "bouquet.jpg"
)

Product.find_or_initialize_by(name: "Bouquet bulle").update!(
  category: "compositions",
  product_type: "rond",
  price_options: bouquet_round_prices,
  customizable_price: true,
  image_url: "bouquet_bulle.jpg"
)

Product.find_or_initialize_by(name: "Bouquet varié").update!(
  category: "compositions",
  product_type: "varié",
  price_options: bouquet_varie_prices,
  customizable_price: true,
  image_url: "bouquet_varie.jpg"
)

# 🌹 Roses
puts "Création des bouquets de roses..."

rose_prices = {
  "explorer"  => { 5 => 1750, 7 => 2450, 9 => 3150 },
  "esperance" => { 5 => 1750, 7 => 2450, 9 => 3150 },
  "avalanche" => { 5 => 1500, 7 => 2100, 9 => 2700 }
}

rose_images = {
  "explorer"  => "roses_explorer.jpg",
  "esperance" => "roses_esperance.jpg",
  "avalanche" => "roses_avalanche.jpg"
}

rose_prices.each do |variety, sizes|
  sizes.each do |size, price|
    Product.find_or_initialize_by(name: "Bouquet de #{size} roses #{variety.capitalize}").update!(
      price_cents: price,
      category: "roses",
      variety: variety,
      image_url: rose_images[variety]
    )
  end
end

puts "✅ Bouquets de roses créés avec succès !"

# Génération des prix personnalisables (20€ à 400€ en pas de 20)
custom_prices = (20..400).step(20).map { |p| ["#{p} €", p * 100] }.to_h

# 🕊️ Deuil
custom_prices_coupe = { "18€" => 1800 }.merge((20..400).step(20).map { |p| ["#{p} €", p * 100] }.to_h)

Product.find_or_initialize_by(name: "Coupe de plantes").update!(
  category: "deuil",
  price_cents: 1800,
  customizable_price: true,
  price_options: custom_prices_coupe,
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "coeur_deuil.jpg"
)

Product.find_or_initialize_by(name: "Coussin Coeur").update!(
  category: "deuil",
  price_cents: 7000,
  price_options: {
    "29 cm x 30 cm" => 7000,
    "38 cm x 40 cm" => 9000
  },
  size_options: "Petit (29x30), Grand (38x40)",
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "coeur_deuil.jpg"
)

Product.find_or_initialize_by(name: "Dessus de Cercueil").update!(
  category: "deuil",
  price_cents: 25000,
  price_options: {
    "80 cm" => 25000,
    "1 mètre" => 30000
  },
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "dessus_cercueil.jpg"
)

Product.find_or_initialize_by(name: "Gerbe Piquée").update!(
  category: "deuil",
  price_cents: 7000, # prix minimum
  customizable_price: true,
  price_options: (70..400).step(20).map { |p| ["#{p}€", p * 100] }.to_h,
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "gerbe.jpg"
)

devant_de_tombe_prices = (100..400).step(20).map { |p| ["#{p} €", p * 100] }.to_h

Product.find_or_initialize_by(name: "Devant de Tombe").update!(
  category: "deuil",
  price_cents: 10000,
  customizable_price: true,
  price_options: devant_de_tombe_prices,
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "coupe.jpg"
)

Product.find_or_initialize_by(name: "Croix, 1 mètre").update!(
  category: "deuil",
  price_cents: 35000,
  customizable_price: false, # 🔹 aucun menu
  color_options: "rouge et blanc, rose et blanc, vert et blanc, orange saumoné et blanc",
  image_url: "croix.jpg"
)

# 🌿 Plantes
Product.find_or_initialize_by(name: "Orchidée 2 Branches avec Cache Pot").update!(
  category: "orchidees",
  price_cents: 2700,
  image_url: "orchidees.jpg"
)

puts "✅ Tous les produits ont été créés ou mis à jour avec succès !"

# === Création de l'admin ===
admin_email = "letamineflesselles@yahoo.com"
admin_password = "etamine80260"

User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.admin = true
end

puts "✅ Compte admin créé ou déjà existant : #{admin_email}"
