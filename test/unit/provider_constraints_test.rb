require 'test_helper'

class ProviderConstraintsTest < ActiveSupport::TestCase

  class FakeProvider < Account
    %I[user_count service_count].each do |count|
      raise "#{superclass} does not define #{count}" unless method_defined?(count)
    end

    attr_accessor :user_count, :service_count
  end

  def test_can_create_user?
    provider = FakeProvider.new
    constraint = ProviderConstraints.new(provider: provider)

    provider.user_count = nil
    constraint.max_users = nil
    refute constraint.can_create_user?

    provider.user_count = 1
    assert constraint.can_create_user?

    constraint.max_users  = 1
    refute constraint.can_create_user?

    constraint.max_users += 1
    assert constraint.can_create_user?
  end

  def test_can_create_service?
    provider = FakeProvider.new
    constraint = ProviderConstraints.new(provider: provider)

    provider.service_count = nil
    constraint.max_services = nil
    refute constraint.can_create_service?

    provider.service_count = 1
    assert constraint.can_create_service?

    constraint.max_services = 1
    refute constraint.can_create_service?

    constraint.max_services += 1
    assert constraint.can_create_service?
  end

  def test_can_create?
    refute ProviderConstraints::Limit.new(nil, 1).can_create?,
           'cant create when value is unknown'

    assert ProviderConstraints::Limit.new(999, nil).can_create?,
           'cant create when no limit'

    assert ProviderConstraints::Limit.new(0, 1).can_create?,
           'should create when current is 0'

    refute ProviderConstraints::Limit.new(1, 1).can_create?,
           'not create when current is the limit'

    refute ProviderConstraints::Limit.new(3, 1).can_create?,
           'not create when current is more than the limit'
  end
end
