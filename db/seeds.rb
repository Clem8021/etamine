Product.destroy_all

# 🌸 Bouquets Composés
Product.create!(
  name: "Bouquet rond",
  category: "compositions",
  product_type: "rond",
  color_options: "rose et blanc, vert et blanc, orange saumoné et blanc",
  price_cents: 2500,
  price_options: {
    "25€" => 2500,
  },
  custom_price_allowed: true,
  image_url: "bouquet.jpg"
)

Product.create!(
  name: "Bouquet bulle",
  category: "compositions",
  product_type: "rond",
  color_options: "rose et blanc, vert et blanc, orange saumoné et blanc",
  price_cents: 2500,
  price_options: {
    "25€" => 2500,
  },
  custom_price_allowed: true,
  image_url: "bouquet_bulle.jpg",
)

Product.create!(
  name: "Bouquet varié",
  category: "compositions",
  product_type: "varié",
  color_options: "rose et blanc, vert et blanc, orange saumoné et blanc",
  price_cents: 2500,
  price_options: {
    "25€" => 2500,
  },
  custom_price_allowed: true,
  image_url: "bouquet_varie.jpg",
)

# 🌹 Bouquets de Roses
Product.create!(
  name: "Bouquet de roses",
  category: "roses",
  product_type: "bouquet de roses",
  color_options: "rouge, blanche, rose",
  addons: "gypsophile, eucalyptus",
  price_options: {
    "5 roses" => 1750,
    "7 roses" => 2450,
    "9 roses" => 3150
  },
  price_cents: 1750,
  image_url: "roses.jpg"
)

# 🕊️ Deuil
Product.create!(
  name: "Coupe de plantes",
  category: "deuil",
  price_cents: 1800,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "coeur_deuil.jpg",
)

Product.create!(
  name: "Coussin Coeur",
  category: "deuil",
  price_cents: 7000,
  price_options: {
    "29 cm x 30 cm" => 7000,
    "38 cm x 40 cm" => 9000
  },
  size_options: "Petit (29x30),Grand (38x40)",
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "coeur_deuil.jpg",
)

Product.create!(
  name: "Dessus de Cercueil",
  category: "deuil",
  price_cents: 25000,
   price_options: {
    "80 cm" => 25000,
    "1 mètre" => 30000
  },
  size_options: "80 cm,1 mètre",
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "dessus_cercueil.jpg",
)

Product.create!(
  name: "Gerbe Piquée",
  category: "deuil",
  price_cents: 7000,
  customizable_price: true,
  min_price_cents: 7000,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "gerbe.jpg",
)

Product.create!(
  name: "Devant de Tombe",
  category: "deuil",
  price_cents: 1000,
  customizable_price: true,
  min_price_cents: 1000,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "coupe.jpg",
)

Product.create!(
  name: "Croix, 1 mètre",
  category: "deuil",
  price_cents: 35000,
  customizable_price: true,
  color_options: "Rouge et Blanc, Rose et Blanc, Vert et Blanc, Orange Saumoné et Blanc",
  image_url: "croix.jpg",
)

# 🌿 Plantes
Product.create!(
  name: "Orchidée 2 Branches avec Cache Pot",
  category: "orchidees",
  price_cents: 2700,
  image_url: "orchidees.jpg",
)
