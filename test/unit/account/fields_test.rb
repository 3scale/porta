# frozen_string_literal: true

require 'test_helper'

class Account::FieldsTest < ActiveSupport::TestCase
  class BuyerTest < Account::FieldsTest
    def setup
      @user_attrs = { username: 'buyer', email: 'email@buyer.com', password: 'superSecret1234#', password_confirmation: 'superSecret1234#' }

      @provider = FactoryBot.create(:simple_provider)
      @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider, org_name: 'buyer')
    end

    attr_reader :buyer

    test 'built by normal association' do
      assert_equal @provider, buyer.fields_definitions_source_root

      user = buyer.users.build_with_fields(@user_attrs)
      assert_equal @provider, user.fields_definitions_source_root

      buyer.save!
      assert_equal @provider, Account.find_by!(org_name: 'buyer').fields_definitions_source_root
    end

    test 'built with fields' do
      assert_equal @provider, buyer.fields_definitions_source_root

      user = buyer.users.build_with_fields(@user_attrs)
      assert_equal @provider, user.fields_definitions_source_root

      buyer.save!

      assert_equal @provider, Account.find_by!(org_name: 'buyer').fields_definitions_source_root
      assert_equal @provider, User.find_by!(username: 'buyer').fields_definitions_source_root
    end

    test 'which exists' do
      assert_equal buyer.provider_account, buyer.fields_definitions_source_root

      user = buyer.users.build(@user_attrs)
      assert_equal buyer.provider_account, user.fields_definitions_source_root
    end
  end

  class ProviderTest < Account::FieldsTest
    def setup
      super
      @master = master_account
      @provider = FactoryBot.create(:simple_provider, provider: master_account, org_name: 'provider')
    end

    attr_reader :provider

    test 'built by normal association' do
      assert_equal @master, provider.fields_definitions_source_root
      provider.save!
      assert_equal @master, Account.find_by!(org_name: 'provider').fields_definitions_source_root
    end

    test 'built with fields' do
      assert_equal @master, provider.fields_definitions_source_root
      provider.save!
      assert_equal @master, Account.find_by!(org_name: 'provider').fields_definitions_source_root
    end

    test 'which exists' do
      assert_equal provider.provider_account, provider.fields_definitions_source_root
    end

    test 'source of field definitions for master' do
      assert_equal @master, @master.fields_definitions_source_root
    end
  end
end
