require 'test_helper'

class MailDispatchRuleTest < ActiveSupport::TestCase

  def test_create_or_find_by
    assert_nil MailDispatchRule.find_by(account_id: 1, system_operation_id: 1)

    dispatch_rule = MailDispatchRule.create!(account_id: 1, system_operation_id: 1)

    assert_equal dispatch_rule, MailDispatchRule.create_or_find_by!(account_id: 1, system_operation_id: 1)
    assert_not_equal dispatch_rule, MailDispatchRule.create_or_find_by!(account_id: 1, system_operation_id: 2)
  end

  def test_create_or_find_by_within_transaction
    assert_nil MailDispatchRule.find_by(account_id: 1, system_operation_id: 1)

    dispatch_rule = MailDispatchRule.create!(account_id: 1, system_operation_id: 1)

    MailDispatchRule.transaction do
      assert_equal dispatch_rule, MailDispatchRule.create_or_find_by!(account_id: 1, system_operation_id: 1)
      assert_not_equal dispatch_rule, MailDispatchRule.create_or_find_by!(account_id: 1, system_operation_id: 2)
    end
  end

  test 'is unique' do
    rule = MailDispatchRule.create!(account_id: 1, system_operation_id: 1)

    assert_raises ActiveRecord::RecordNotUnique do
      rule.dup.save!
    end
  end
end
