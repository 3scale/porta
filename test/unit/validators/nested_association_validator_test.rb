# frozen_string_literal: true

require 'test_helper'

class NestedAssociationValidatorTest < ActiveSupport::TestCase

  class User < ApplicationRecord
    validates :username, length: { within: 3..40, allow_blank: false }
  end

  class Account < ApplicationRecord
    has_one :admin, class_name: 'User'

    # We need to define the method `local_alias`, so that the Errors module can find it (as it searches for actual attributes)
    alias local_alias admin

    validates :admin, nested_association: { report: { username: :local_alias } }, associated: true
  end

  test 'errors are merged' do
    account = Account.new(admin: User.new(username: 'valid'))
    assert account.valid?

    user = User.new(username: '1')
    account = Account.new(admin: user)

    assert_not account.valid?
    assert_equal user.errors.messages_for(:username), account.errors.messages_for(:local_alias)
  end
end
