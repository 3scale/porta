require 'test_helper'

class User::SignupTypeTest < ActiveSupport::TestCase

  def test_partner
    assert signup_type(type: 'partner').partner?
    assert_not signup_type(type: 'new_signup').partner?
  end

  test 'open_id' do
    assert signup_type(open_id: 'foo').open_id?
    assert signup_type(open_id: 'foo').machine?
  end

  test 'sample_data? returns true for sample_data signup_type' do
    assert signup_type(type: 'sample_data').sample_data?
  end

  test 'sample_data? returns false for other signup_types' do
    assert_not signup_type(type: 'new_signup').sample_data?
    assert_not signup_type(type: 'minimal').sample_data?
    assert_not signup_type(type: 'api').sample_data?
  end

  test 'machine? returns true for sample_data signup_type' do
    assert signup_type(type: 'sample_data').machine?
  end

  test 'by_user? returns false for sample_data signup_type' do
    assert_not signup_type(type: 'sample_data').by_user?
  end

  private

  def signup_type(type: '', open_id: nil)
    User::SignupType.new(stub(signup_type: type.to_sym, open_id: open_id, any_sso_authorizations?: false, authentication_id: nil, cas_identifier: nil))
  end
end
