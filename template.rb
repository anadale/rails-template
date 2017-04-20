def source_paths
  path = File.expand_path(File.dirname(__FILE__))

  [path]
end

def api?
  options[:api]
end

apply 'shared-before-bundle.rb'
apply "#{api? ? 'api' : 'full'}-before-bundle.rb"

after_bundle do
  apply 'shared-after-bundle.rb'
  apply "#{api? ? 'api' : 'full'}-after-bundle.rb"
end
