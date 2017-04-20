def source_paths
  path = File.expand_path(File.dirname(__FILE__))

  [path, File.join(path, 'full')]
end

def remove_unused_files
  remove_file 'app/helpers/application_helper.rb'

  remove_file 'app/assets/javascripts/application.js'
  remove_file 'app/assets/stylesheets/application.css'

  remove_file 'app/views/layouts/application.html.erb'
end

def copy_content
  directory 'app'
  directory 'spec'
end

def setup_routes
  route "root to: 'home#index'"
end

remove_unused_files
copy_content
setup_routes
