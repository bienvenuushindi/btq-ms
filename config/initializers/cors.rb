# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "*"
#     resource '*',
#              expose: ["Authorization"],
#              headers: :any,
#              methods: [:get, :post, :put, :patch, :delete, :options, :head, :show]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development?
    # Allow local web clients and Expo web running over a private LAN/hotspot.
    # The port is intentionally flexible because Metro may move from 8081 when
    # another development server is already running.
    development_origins = [
      %r{\Ahttps?://(?:localhost|127\.0\.0\.1)(?::\d+)?\z},
      %r{\Ahttps?://192\.168\.\d{1,3}\.\d{1,3}(?::\d+)?\z},
      %r{\Ahttps?://10\.\d{1,3}\.\d{1,3}\.\d{1,3}(?::\d+)?\z},
      %r{\Ahttps?://172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}(?::\d+)?\z}
    ].freeze
    allow do
      origins(*development_origins)
      resource '*',
               headers: :any,
               expose: ["Authorization"],
               credentials: true,
               methods: [:get, :post, :put, :patch, :delete, :options, :head, :show]
    end
  else
    origins = %w[staging.xyz.com www.xyz.com].freeze
    allow do
      origins origins
      resource '*',
               headers: :any,
               expose: ["Authorization"],
               credentials: true,
               methods: [:get, :post, :put, :patch, :delete, :options, :head, :show]
    end
  end
end
