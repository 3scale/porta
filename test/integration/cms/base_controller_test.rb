# frozen_string_literal: true

require 'test_helper'

class Admin::Api::CMS::BaseControllerTest < ActionDispatch::IntegrationTest

  include ApiRouting
  disable_transactional_fixtures!

  class ProviderAccountTest < Admin::Api::CMS::BaseControllerTest
    setup do
      @provider = FactoryGirl.create(:provider_account)
      host! @provider.admin_domain
    end

    test 'admin user with cms scope has permission' do
      token = FactoryGirl.create(:access_token, owner: @provider.admin_users.first, scopes: ['cms'], permission: 'rw')
      with_api_routes do
        get '/cms_api', access_token: token.value
        assert_response :ok
      end
    end

    test 'admin user without cms scope does not have permission' do
      with_api_routes do
        token = FactoryGirl.create(:access_token, owner: @provider.admin_users.first)
        get '/cms_api', access_token: token.value
        assert_response :forbidden
      end
    end

    test 'member user with admin_section portal and cms scope has permission' do
      member = FactoryGirl.create(:member, account: @provider, admin_sections: ['portal'])
      token  = FactoryGirl.create(:access_token, owner: member, scopes: ['cms'], permission: 'rw')
      with_api_routes do
        get '/cms_api', access_token: token.value
        assert_response :ok
      end
    end

    test 'member user without cms scope does not have permission' do
      member = FactoryGirl.create(:member, account: @provider, admin_sections: ['portal'])
      token  = FactoryGirl.create(:access_token, owner: member)
      with_api_routes do
        get '/cms_api', access_token: token.value
        assert_response :forbidden
      end
    end

    test 'member user without admin_section portal does not have permission' do
      member = FactoryGirl.create(:member, account: @provider)
      token  = FactoryGirl.create(:access_token, owner: member, scopes: ['cms'], permission: 'rw')
      with_api_routes do
        get '/cms_api', access_token: token.value
        assert_response :forbidden
      end
    end
  end

  class MasterAccountTest < Admin::Api::CMS::BaseControllerTest
    setup do
      host! master_account.admin_domain
    end

    class MasterAccountOnPremTest < MasterAccountTest
      setup do
        ThreeScale.stubs(master_on_premises?: true)
      end

      test 'user with cms scope does not have permission' do
        admin = master_account.admin_users.first
        member = FactoryGirl.create(:member, account: master_account, admin_sections: ['portal'])
        [admin, member].each do |user|
          token = FactoryGirl.create(:access_token, owner: user, scopes: ['cms'], permission: 'rw')
          with_api_routes do
            get '/cms_api', access_token: token.value
            assert_response :forbidden
          end
        end
      end

      test 'user with account_management scope does not have permission' do
        admin = master_account.admin_users.first
        member = FactoryGirl.create(:member, account: master_account, admin_sections: ['partners'])
        [admin, member].each do |user|
          token  = FactoryGirl.create(:access_token, owner: user, scopes: ['account_management'], permission: 'rw')
          with_api_routes do
            get '/cms_api', access_token: token.value
            assert_response :forbidden
          end
        end
      end
    end

    class MasterAccountSaasTest < MasterAccountTest
      test 'user with cms scope has permission' do
        admin = master_account.admin_users.first
        member = FactoryGirl.create(:member, account: master_account, admin_sections: ['portal'])
        [admin, member].each do |user|
          token  = FactoryGirl.create(:access_token, owner: user, scopes: ['cms'], permission: 'rw')
          with_api_routes do
            get '/cms_api', access_token: token.value
            assert_response :success
          end
        end
      end

      test 'user with account_management scope has permission' do
        admin = master_account.admin_users.first
        member = FactoryGirl.create(:member, account: master_account, admin_sections: ['partners'])
        [admin, member].each do |user|
          token  = FactoryGirl.create(:access_token, owner: user, scopes: ['account_management'], permission: 'rw')
          with_api_routes do
            get '/cms_api', access_token: token.value
            assert_response :success
          end
        end
      end
    end

  end
end
