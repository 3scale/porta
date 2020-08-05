# frozen_string_literal: true

require 'test_helper'

module Abilities
  class AbilityTest < ActiveSupport::TestCase
    test 'can? works the same way for models than for decorators' do
      user = FactoryBot.create(:simple_user)
      ability = Ability.new(user)
      ability.can :read, Account
      ability.cannot :read, Service

      FactoryBot.create_list(:simple_account, 2)
      assert_can ability, :read, Account.last!
      assert_can ability, :read, Account.all
      assert_can ability, :read, Account.last!.decorate
      assert_can ability, :read, Account.all.decorate

      FactoryBot.create_list(:simple_service, 2)
      assert_cannot ability, :read, Service.last!
      assert_cannot ability, :read, Service.all
      assert_cannot ability, :read, Service.last!.decorate
      assert_cannot ability, :read, Service.all.decorate
    end
  end
end
