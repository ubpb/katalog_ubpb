require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KatalogUbpb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Berlin"

    # Locale setup
    I18n.backend = I18n::Backend::Advanced.new
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]
    config.i18n.default_locale = :de
    config.i18n.available_locales = [:de]

    # Setup the host to make full URLs work for the mailer.
    routes.default_url_options = {
      host: ENV["KATALOG_HOST"] || "localhost:3000"
    }

    # Sentry error reporting
    Raven.configure do |config|
      config.dsn = 'https://247cd30d993c4750bb05736e0a59f3a8:e64935fb134948c2841b41497e65214c@sentry.io/272525'
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end
  end
end
