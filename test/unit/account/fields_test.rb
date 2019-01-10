require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Account::FieldsTest < ActiveSupport::TestCase

  def setup
    @user_attrs = { :username => 'buyer', :email => 'email@buyer.com', :password => 'password', :password_confirmation => 'password' }
  end

  context 'source of field definitions for buyer' do

    should 'built by normal association' do
      @provider = FactoryBot.create(:simple_provider)
      buyer = @provider.buyers.build :org_name => 'buyer'
      assert_equal @provider, buyer.fields_definitions_source_root

      user = buyer.users.build_with_fields(@user_attrs)
      assert_equal @provider, user.fields_definitions_source_root

      buyer.save!
      assert_equal @provider, Account.find_by_org_name!('buyer').fields_definitions_source_root
    end

    should 'buit with fields' do
      @provider = FactoryBot.create(:simple_provider)
      buyer = @provider.buyers.build_with_fields :org_name => 'buyer'
      assert_equal @provider, buyer.fields_definitions_source_root

      user = buyer.users.build_with_fields(@user_attrs)
      assert_equal @provider, user.fields_definitions_source_root

      buyer.save!

      assert_equal @provider, Account.find_by_org_name!('buyer').fields_definitions_source_root
      assert_equal @provider, User.find_by_username!('buyer').fields_definitions_source_root
    end

    should 'which exists' do
      buyer = FactoryBot.create(:simple_buyer)
      assert_equal buyer.provider_account, buyer.fields_definitions_source_root

      user = buyer.users.build(@user_attrs)
      assert_equal buyer.provider_account, user.fields_definitions_source_root
    end
  end

  context 'source of field definitions for provider' do
    setup do
      @master = master_account
    end

    should 'buit by normal association' do
      provider = @master.buyers.build :org_name => 'provider'
      assert_equal @master, provider.fields_definitions_source_root
      provider.save!
      assert_equal @master, Account.find_by_org_name!('provider').fields_definitions_source_root
    end

    should 'built with fields' do
      provider = @master.buyers.build_with_fields :org_name => 'provider'
      assert_equal @master, provider.fields_definitions_source_root
      provider.save!
      assert_equal @master, Account.find_by_org_name!('provider').fields_definitions_source_root
    end

    should 'which exists' do
      provider = FactoryBot.create(:simple_provider)
      assert_equal provider.provider_account, provider.fields_definitions_source_root
    end
  end

  test 'source of field definitions for master' do
    master = master_account
    assert_equal master, master.fields_definitions_source_root
  end
end
