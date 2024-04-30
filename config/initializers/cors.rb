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
    origins = %w[localhost:3000 localhost:3001 localhost:5000 192.168.70.49:8081 www.xyz.com].freeze
    allow do
      origins origins
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
