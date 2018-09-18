
require 'test_helper'

class SignupFormTest < ActiveSupport::TestCase
  SignupForm = Fields::SignupForm

  def setup

  end

  def signup_fields(fields)
    provider = mock('provider')
    user = mock('user')
    SignupForm.new(provider, user, fields)
  end

  def test_default_signup_fields
    @signup_fields = signup_fields(nil)

    assert @signup_fields.user_fields.include?(:email)
    assert @signup_fields.account_fields.include?(:self_subdomain)
  end

  def test_user_fields
    @signup_fields = signup_fields(%w{ account[user][email] account[self_subdomain] })
    assert @signup_fields.user_fields.include?(:email)
    refute @signup_fields.user_fields.include?(:self_subdomain)
  end

  def test_account_fields
    @signup_fields = signup_fields(%w{ account[user][email] account[self_subdomain] })
    refute @signup_fields.account_fields.include?(:email)
    assert @signup_fields.account_fields.include?(:self_subdomain)
  end

  def test_account_extra_field_names
    @signup_fields = signup_fields(%w{ account[extra_fields][some_field]
                                       account[user][email]
                                       account[#user][extra_fields][other_field] })

    assert_equal %w{ some_field },
                 @signup_fields.account_fields.extra_field_names
  end

  def test_focused_user_extra_field_names
    @signup_fields = signup_fields(%w{ account[#user][extra_fields][fake_field] })
    assert_equal %w{ fake_field },
                 @signup_fields.user_fields.extra_field_names
  end

  def test_extra_fields
    @signup_fields  = signup_fields([])
    @signup_fields.account.stubs(
      defined_extra_fields: [ fake_field = FieldsDefinition.new(name: 'fake_field')]
    )
    assert_equal({ 'fake_field' => fake_field }, @signup_fields.extra_fields)
  end

  def test_account_extra_fields
    @signup_fields = signup_fields(%w{ account[extra_fields][fake_field] })
    @signup_fields.account.stubs(
      defined_extra_fields: [ fake_field = FieldsDefinition.new(name: 'fake_field')]
    )
    assert_equal({ 'fake_field' => fake_field }, @signup_fields.account_fields.signup_fields.extra_fields)
  end

  def test_user_extra_fields
    @signup_fields = signup_fields(%w{ account[#user][extra_fields][fake_field] })
    @signup_fields.account.stubs(
      defined_extra_fields: [ fake_field = FieldsDefinition.new(name: 'fake_field')]
    )
    assert_equal({ 'fake_field' => fake_field }, @signup_fields.user_fields.signup_fields.extra_fields)
  end

  def test_missing_user_extra_fields
    @signup_fields = signup_fields(%w{ account[#user][extra_fields][fake_field] })
    @signup_fields.account.stubs(defined_extra_fields: [])

    assert_equal([], @signup_fields.user_fields.extra_fields)
  end

  def test_missing_account_extra_fields
    @signup_fields = signup_fields(%w{ account[extra_fields][fake_field] })
    @signup_fields.account.stubs(defined_extra_fields: [])

    assert_equal([], @signup_fields.account_fields.extra_fields)
  end
end
