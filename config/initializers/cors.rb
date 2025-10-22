Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.configuration.app_config['cors_origins']&.split(',') || []

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
