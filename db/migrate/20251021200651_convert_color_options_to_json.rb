class ConvertColorOptionsToJson < ActiveRecord::Migration[7.1]
  def up
    Product.find_each do |product|
      next if product.color_options.blank? || product.color_options.is_a?(Hash) || product.color_options.is_a?(Array)

      json_value = product.color_options.split(",").map(&:strip)
      product.update_column(:color_options, json_value.to_json)
    end
  end

  def down
    Product.find_each do |product|
      next unless product.color_options.is_a?(Array)
      product.update_column(:color_options, product.color_options.join(", "))
    end
  end
end
