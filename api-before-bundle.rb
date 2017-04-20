def source_paths
  path = File.expand_path(File.dirname(__FILE__))

  [path, File.join(path, 'api')]
end

def copy_content
  directory 'app'
  directory 'spec'
end

def setup_routes
  routing_code = <<-RUBY
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # jsonapi_resources :resource
    end
  end
  RUBY

  in_root do
    inject_into_file 'config/routes.rb', routing_code, after: /\.routes\.draw do\s*\n/m,
                     verbose: false, force: false
  end
end

copy_content
setup_routes
