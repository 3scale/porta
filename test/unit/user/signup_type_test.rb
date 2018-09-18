require 'test_helper'

class User::SignupTypeTest < ActiveSupport::TestCase

  def test_partner
    assert signup_type(type: 'partner:heroku').partner?
    assert signup_type(type: 'partner').partner?
    refute signup_type(type: 'new_signup').partner?
  end

  test 'open_id' do
    assert signup_type(open_id: 'foo').open_id?
    assert signup_type(open_id: 'foo').machine?
  end

  private

  def signup_type(type: '', open_id: nil)
    User::SignupType.new(stub(signup_type: type.to_sym, open_id: open_id))
  end
end
