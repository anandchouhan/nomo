require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you"ve limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Nomofomo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = "Central Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join("my", "locales", "*.{rb,yml}").to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.

    config.action_view.automatically_disable_submit_tag = false

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/uploaders #{config.root}/app/api)
    config.assets.paths << Rails.root.join("node_modules")
    config.autoload_paths << Rails.root.join("lib")
    # Only generates JavaScript files.
    config.generators do |g|
      g.javascript_engine :js
    end

    config.middleware.use Rack::Deflater
  end
end
