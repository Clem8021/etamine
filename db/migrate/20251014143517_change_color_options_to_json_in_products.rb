class ChangeColorOptionsToJsonInProducts < ActiveRecord::Migration[8.0]
  def up
    # 🔹 Convertit les anciennes valeurs texte en JSON valide
    say_with_time "Cleaning and converting color_options to valid JSON" do
      Product.reset_column_information
      Product.find_each do |product|
        value = product.read_attribute(:color_options)

        next if value.blank? || value.is_a?(Array) || value.is_a?(Hash)

        begin
          # Si c’est du texte simple, on le transforme en tableau JSON
          formatted = value.split(",").map(&:strip)
          product.update_column(:color_options, formatted.to_json)
        rescue => e
          puts "⚠️ Skipped product #{product.id} (invalid color_options: #{value})"
        end
      end
    end

    # 🔹 Maintenant, on peut changer le type en jsonb
    change_column :products, :color_options, :jsonb, using: 'color_options::jsonb'
  end

  def down
    change_column :products, :color_options, :string
  end
end
