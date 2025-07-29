Product.destroy_all

# 🌸 Bouquets Composés
Product.create!(
  name: "Bouquet Rond",
  category: "compositions",
  price_cents: 2500,
  customizable_price: true,
  min_price_cents: 2500,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "bouquet.jpg",
  stock_quantity: 100
)

Product.create!(
  name: "Bouquet Varié",
  category: "compositions",
  price_cents: 1500,
  customizable_price: true,
  min_price_cents: 1500,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "bouquet_varie.jpg",
  stock_quantity: 100
)

Product.create!(
  name: "Bouquet Bulle",
  category: "compositions",
  price_cents: 2500,
  customizable_price: true,
  min_price_cents: 2500,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "bouquet_bulle.jpg",
  stock_quantity: 100
)

# 🌹 Bouquets de Roses
Product.create!(
  name: "Bouquet Roses Rouges (Explorer 50 cm)",
  category: "roses",
  price_cents: 1750, # prix de base : 5 roses
  size_options: "5 roses,7 roses,9 roses",
  addons: "Gypsophile (+2€),Eucalyptus (+3.50€)",
  color_options: "Rouge",
  image_url: "roses.jpg",
  stock_quantity: 50
)

Product.create!(
  name: "Bouquet Roses Blanches (Avalanche 50 cm)",
  category: "roses",
  price_cents: 1500,
  size_options: "5 roses,7 roses,9 roses",
  addons: "Gypsophile (+2€),Eucalyptus (+3.50€)",
  color_options: "Blanc",
  image_url: "roses_blanches.jpg",
  stock_quantity: 50
)

Product.create!(
  name: "Bouquet Roses Roses (Espérance 50 cm)",
  category: "roses",
  price_cents: 1750,
  size_options: "5 roses,7 roses,9 roses",
  addons: "Gypsophile (+2€),Eucalyptus (+3.50€)",
  color_options: "Rose",
  image_url: "roses_roses.jpg",
  stock_quantity: 50
)

# 🕊️ Deuil
Product.create!(
  name: "Coussin Cœur",
  category: "deuil",
  price_cents: 7000,
  size_options: "Petit (29x30),Grand (38x40)",
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "coeur_deuil.jpg",
  stock_quantity: 10
)

Product.create!(
  name: "Dessus de Cercueil",
  category: "deuil",
  price_cents: 25000,
  size_options: "80 cm,1 mètre",
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "dessus_cercueil.jpg",
  stock_quantity: 5
)

Product.create!(
  name: "Gerbe Piquée",
  category: "deuil",
  price_cents: 7000,
  customizable_price: true,
  min_price_cents: 7000,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "gerbe.jpg",
  stock_quantity: 10
)

Product.create!(
  name: "Coupe de Plantes",
  category: "deuil",
  price_cents: 1800,
  customizable_price: true,
  min_price_cents: 1800,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "coupe.jpg",
  stock_quantity: 20
)

# 🌿 Plantes
Product.create!(
  name: "Orchidée 2 Branches avec Cache Pot",
  category: "orchidees",
  price_cents: 2700,
  image_url: "orchidees.jpg",
  stock_quantity: 30
)
