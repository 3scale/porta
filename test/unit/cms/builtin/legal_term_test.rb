require 'test_helper'

class CMS::Builtin::LegalTermsTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:simple_provider)
    @root_sec = Factory(:root_cms_section, provider: @provider)
  end


  test 'limit system_names to the hard-wired ones' do
    lt = @provider.builtin_legal_terms.create(system_name: 'signup_licence')
    assert_empty lt.errors[:system_name]
  end

  test 'cannot use arbitrary system_names' do
    lt = @provider.builtin_legal_terms.create(system_name: 'some_other_name')
    assert_not_empty lt.errors[:system_name]
  end

  test 'cannot use builtin partials system_name' do
    lt = @provider.builtin_legal_terms.create(system_name: 'applications/form')
    assert_not_empty lt.errors[:system_name]
  end

end
