require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PurpleOctopus
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.middleware.use Oink::Middleware, :logger => Hodel3000CompliantLogger.new(STDOUT)
    config.middleware.use Rack::SslEnforcer, :only_hosts => ['api.yero.co']
    config.assets.precompile += %w( vendor/modernizr )

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end

    AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: 'us-west-2')
    config.action_controller.allow_forgery_protection = false
    # set rspec as the default test framework when generating controllers
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories' 

      g.view_specs false
      g.helper_specs false
    end

    Timezone::Configure.begin do |c|
      c.username = 'your_geonames_username_goes_here'
    end

    Timezone::Configure.begin do |c|
      c.google_api_key = 'AIzaSyCN5wCxkgGWj9v9hr0auqmEGi1I-nxSoUQ'
    end
    
    
    config.action_dispatch.default_headers.merge!({
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    })

  end
end
