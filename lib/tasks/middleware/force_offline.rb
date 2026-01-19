# lib/middleware/force_offline.rb
class ForceOffline
  def initialize(app)
    @app = app
  end

  def call(_env)
    # Bloque tout le monde avec 500 Internal Server Error
    [500, { "Content-Type" => "text/plain" }, ["Site temporairement indisponible"]]
  end
end
