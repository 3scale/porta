require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CountryTest < ActiveSupport::TestCase
  def setup
    @country = Country.create!(:name => 'Thailand', :code => 'th',
      :currency => 'THB', :tax_rate => 7.0)
  end

  subject { @country }

  should validate_presence_of :name
  should validate_presence_of :code
  should validate_uniqueness_of :code

  test 'default_scope' do
    cuba = Country.create!(code: "CU", name: "Cuba", currency: 'CUP', tax_rate: 0.0, enabled: false)
    assert_nil Country.find_by(id: cuba.id)
  end
end
