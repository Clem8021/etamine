namespace :orders do
  desc "Nettoie les anciens paniers en attente"
  task cleanup: :environment do
    deleted = Order.where(status: "en_attente")
                   .where("created_at < ?", 2.days.ago)
                   .destroy_all
    puts "🧹 #{deleted.size} paniers supprimés"
  end
end
