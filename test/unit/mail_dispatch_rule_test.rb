require 'test_helper'

class MailDispatchRuleTest < ActiveSupport::TestCase

  def test_fetch_with_retry
    expected = nil
    rule = MailDispatchRule.fetch_with_retry!(account_id: 1, system_operation_id: 1) do |rule|
      expected = rule.dup
      expected.save!
    end

    assert_equal expected , rule
  end

  test 'is unique' do
    rule = MailDispatchRule.create!(account_id: 1, system_operation_id: 1)

    assert_raises ActiveRecord::RecordNotUnique do
      rule.dup.save!
    end
  end
end
