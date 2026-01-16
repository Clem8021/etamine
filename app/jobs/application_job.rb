# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  # Tous les jobs héritent de cette classe
  # Par défaut, les jobs utilisent l'adapter configuré dans config/application.rb
  # Par exemple : config.active_job.queue_adapter = :async (dev) ou :sidekiq (prod)
end
