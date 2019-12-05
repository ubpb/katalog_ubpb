require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KatalogUbpb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set time zone
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
  end
end
