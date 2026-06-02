require 'test_helper'

class User::SignupTypeTest < ActiveSupport::TestCase

  test 'created_by_provider? is true for :created_by_provider' do
    assert signup_type(type: 'created_by_provider').created_by_provider?
    assert_not signup_type(type: 'new_signup').created_by_provider?
  end

  test 'machine? is true for :created_by_provider' do
    assert signup_type(type: 'created_by_provider').machine?
    assert_not signup_type(type: 'new_signup').machine?
  end

  test 'by_user? is false for :created_by_provider' do
    assert_not signup_type(type: 'created_by_provider').by_user?
    assert signup_type(type: 'new_signup').by_user?
  end

  test 'open_id' do
    assert signup_type(open_id: 'foo').open_id?
    assert signup_type(open_id: 'foo').machine?
  end

  private

  def signup_type(type: '', open_id: nil)
    User::SignupType.new(stub(signup_type: type.to_sym, open_id: open_id, any_sso_authorizations?: false, authentication_id: nil, cas_identifier: nil))
  end
end
