def setup_devise
  generate 'devise:install'
  generate 'devise User'
end

def setup_simple_form
  generate 'simple_form:install', '--bootstrap'

  inside 'config/initializers' do
    gsub_file 'simple_form_bootstrap.rb', "'has-error'", "'has-danger'"
    gsub_file 'simple_form_bootstrap.rb',
              "{ tag: 'span', class: 'help-block' }",
              "{ tag: 'div', class: 'form-control-feedback' }"
    gsub_file 'simple_form_bootstrap.rb',
              "{ tag: 'p', class: 'help-block' }",
              "{ tag: 'small', class: 'form-text text-muted' }"
  end
end

setup_simple_form
setup_devise

