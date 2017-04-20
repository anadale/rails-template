def source_paths
  path = File.expand_path(File.dirname(__FILE__))

  [path, File.join(path, 'shared')]
end

def remove_unused_files
  remove_file 'Gemfile'
  remove_file 'app/controllers/application_controller.rb'
  remove_file 'app/controllers/concerns/.keep'
  remove_file 'config/locales/en.yml'
  remove_file 'config/database.yml'
end

def copy_content
  directory 'config'
  directory 'lib'

  template 'database.yml', 'config/database.yml'

  %w(.dockerignore .gitignore .rspec .rubocop.yml .ruby-version).each do |file|
    copy_file file
  end
end

def configure_application
  code = <<-RUBY
config.time_zone = 'Moscow'

    config.i18n.available_locales = %i(ru en)
    config.i18n.default_locale = :ru
    config.i18n.fallbacks = true

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       routing_specs: false, controller_specs: false, request_specs: true

      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.integration_tool :rspec
    end
  RUBY

  application code
end

def prepare_gemfile
  template 'Gemfile'
end

remove_unused_files
copy_content
configure_application
prepare_gemfile
