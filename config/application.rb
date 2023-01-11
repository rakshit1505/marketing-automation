require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MarketingManagement
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.before_configuration do

      env_file = if Rails.env.production?
        'env_production.yml'
      else
        'env_development.yml'
      end

      env_file = File.join(Rails.root, 'config/env_variables', env_file)
      if File.exists?(env_file)
        YAML.load(File.open(env_file)).each do |key, value|
          ENV[key.to_s] = value
        end
      end

      env_variables = [
        'SMTP_ADDRESS',
        'SMTP_PORT',
        'SMTP_USERNAME',
        'SMTP_PASSWORD',
        'JWT_SECRET'
      ]
    end
    config.active_record.observers = :audit_observer
    config.session_store :disabled

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
