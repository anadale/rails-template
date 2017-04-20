require 'rails_helper'

<% module_namespacing do
  -%>
RSpec.describe <%= class_name %> do
  subject { build(:<%= singular_table_name %>) }

  describe 'Factory' do
    it { is_expected.to be_valid }
  end

  describe 'ActiveRecord associations' do
  end

  describe 'ActiveModel validations' do
  end
end
<% end -%>
