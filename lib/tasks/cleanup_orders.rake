namespace :orders do
  desc "Nettoie uniquement les paniers vides et anciens"
  task cleanup: :environment do
    deleted = Order
      .left_joins(:order_items)
      .where(status: "en_attente")
      .where(order_items: { id: nil })
      .where("orders.created_at < ?", 2.days.ago)
      .destroy_all

    puts "🧹 #{deleted.size} paniers vides supprimés"
  end
end
