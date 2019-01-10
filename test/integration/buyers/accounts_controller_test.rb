require 'test_helper'

class Buyers::AccountsControllerTest < ActionDispatch::IntegrationTest

  class WebhookCreationTest < ActionDispatch::IntegrationTest
    disable_transactional_fixtures!

    def setup
      @buyer = FactoryBot.create :buyer_account
      @provider = @buyer.provider_account
      login! @provider
    end

    test 'POST creates the user and the account also when extra_fields are sent' do
      FactoryBot.create(:fields_definition, account: @provider, target: 'User', name: 'created_by')

      post admin_buyers_accounts_path, {
          account: {
              org_name: 'Alaska',
              user: { email: 'foo@example.com', extra_fields: { created_by: 'hi' }, password: '123456', username: 'hello' }
          }
      }

      account = Account.last
      user = User.last

      assert_equal 'Alaska', account.org_name
      assert_equal 'foo@example.com', user.email
      assert_equal 'hello', user.username
      assert_equal 'hi', user.extra_fields['created_by']
    end

    test 'billing address extra field and webhooks' do
      FactoryBot.create(:fields_definition, account: @provider,
                         target: 'Account', name: 'billing_address', read_only: true)

      @provider.settings.allow_web_hooks!
      FactoryBot.create(:webhook, account: @provider, account_created_on: true, active: true)

      assert_difference @provider.buyers.method(:count) do
        assert_equal 0, WebHookWorker.jobs.size
        post admin_buyers_accounts_path, account: {
            org_name: 'hello', org_legaladdress: 'address',
            user: { username: 'hello', email: 'foo@example.com', password: 'password'}
        }
        assert_equal 1, WebHookWorker.jobs.size

        assert_response :redirect
      end

      account = Account.last!

      assert account.approved?
      assert_equal 'hello', account.org_name
      assert_equal 'address', account.org_legaladdress
    end
  end

  class MemberPermissionsTest < Buyers::AccountsControllerTest
    def setup
      @provider = FactoryBot.create(:provider_account)
      user = FactoryBot.create(:active_user, account: @provider, role: :member, member_permission_ids: [:partners])
      login! @provider, user: user
    end

    def test_show
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      service = FactoryBot.create(:service, account: @provider)
      plan  = FactoryBot.create(:application_plan, issuer: service)
      plan.publish!
      buyer.buy! plan
      cinstance = service.cinstances.last
      cinstance.update_attributes(name: 'Alaska Application App')

      User.any_instance.expects(:has_access_to_all_services?).returns(true).at_least_once
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_match 'Alaska Application App', response.body

      User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_not_match 'Alaska Application App', response.body

      User.any_instance.expects(:member_permission_service_ids).returns([service.id]).at_least_once
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_match 'Alaska Application App', response.body
    end
  end

  class ProviderLoggedInTest < Buyers::AccountsControllerTest
    def setup
      @buyer = FactoryBot.create :buyer_account
      @provider = @buyer.provider_account
      login! @provider
    end

    # regression test for: https://github.com/3scale/system/issues/2567
    test "not raise exception on update if params[:account] is nil" do
      put admin_buyers_account_path @buyer
      assert_equal "Required parameter missing: account", response.body
    end

    test 'checks if link under number of applications is correct' do
      @provider.settings.allow_multiple_applications!

      service = FactoryBot.create(:service, account: @provider)
      FactoryBot.create_list(:application, 2, user_account: @buyer, service: @provider.default_service)
      FactoryBot.create_list(:application, 3, service: service, user_account: @buyer)

      get admin_buyers_accounts_path

      assert_select %{td a[href="#{admin_buyers_account_applications_path(@buyer)}"]}, text: '5'
    end

    test 'checks if link under number of applications is correct as member' do
      @provider.settings.allow_multiple_applications!
      service = FactoryBot.create(:service, account: @provider)

      FactoryBot.create_list(:application, 2, user_account: @buyer)
      FactoryBot.create_list(:application, 3, service: service, user_account: @buyer)

      # Testing member permissions
      member = FactoryBot.create(:member, account: @provider)
      member.member_permission_service_ids = [service.id]
      member.save!
      login! @provider, user: member
      get admin_buyers_accounts_path

      assert_select %{td a[href="#{admin_buyers_account_applications_path(@buyer)}"]}, text: '3'
    end

    test '#create' do
      assert_no_difference(-> { @provider.buyers.count }) do
        post admin_buyers_accounts_path, account: {
            org_name: 'My organization'
        }
        assert_select '#account_user_username_input.required.error'
        assert_response :success
      end

      assert_difference(-> { @provider.buyers.count }) do
        post admin_buyers_accounts_path, account: {
            org_name: 'My organization',
            user: {
                username: 'johndoe',
                email: 'user@example.org',
                password: 'secretpassword'
            }
        }
        assert_response :redirect
      end
    end
  end

  class MasterLoggedInTest < Buyers::AccountsControllerTest
    def setup
      @master = master_account
      @provider = FactoryBot.create(:provider_account, provider_account: @master)
      login! @master
    end

    test 'show plan for SaaS' do
      ThreeScale.config.stubs(onpremises: false)
      get admin_buyers_account_path(@provider)
      assert_xpath( './/div[@id="applications_widget"]//table[@class="list"]//tr', 4)
      assert_xpath( './/div[@id="applications_widget"]//table[@class="list"]//tr', /plan/i )
    end

    test 'do not show plan for on-prem' do
      ThreeScale.config.stubs(onpremises: true)
      get admin_buyers_account_path(@provider)
      assert_xpath( './/div[@id="applications_widget"]//table[@class="list"]//tr', 2)
      refute_xpath( './/div[@id="applications_widget"]//table[@class="list"]//tr', /plan/i )
    end
  end
end
