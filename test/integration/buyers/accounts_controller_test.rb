# frozen_string_literal: true

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

      post admin_buyers_accounts_path, params: {
          account: {
              org_name: 'Alaska',
              user: { email: 'foo@example.com', extra_fields: { created_by: 'hi' }, password: 'superSecret1234#', username: 'hello' }
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
      WebHook.delete_all
      FactoryBot.create(:webhook, account: @provider, account_created_on: true, active: true)

      assert_difference @provider.buyers.method(:count) do
        assert_equal 0, WebHookWorker.jobs.size
        post admin_buyers_accounts_path, params: {
          account: {
            org_name: 'hello', org_legaladdress: 'address',
            user: { username: 'hello', email: 'foo@example.com', password: 'superSecret1234#'}
          }
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
      @user = FactoryBot.create(:active_user, account: provider, role: :member, member_permission_ids: [:partners])
      login! provider, user: user
    end

    attr_reader :user, :provider

    def test_show
      buyer = FactoryBot.create(:buyer_account, provider_account: provider)
      service = FactoryBot.create(:service, account: provider)
      plan  = FactoryBot.create(:application_plan, issuer: service)
      plan.publish!
      buyer.buy! plan
      cinstance = service.cinstances.last
      cinstance.update(name: 'Alaska Application App')

      assert_nil user.member_permission_service_ids
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_match 'Alaska Application App', response.body

      user.update(member_permission_service_ids: [])
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_not_match 'Alaska Application App', response.body

      user.update(member_permission_service_ids: [service.id])
      get admin_buyers_account_path(buyer)
      assert_response :success
      assert_match 'Alaska Application App', response.body
    end

    test 'member user without billing permission cannot manage invoice' do
      buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
      provider.settings.allow_finance!

      get admin_buyers_account_invoices_path(buyer)
      assert_response :forbidden

      assert_no_difference -> { Invoice.count } do
        post admin_buyers_account_invoices_path(buyer)
        assert_response :forbidden
      end

      invoice = FactoryBot.create(:invoice, buyer_account: buyer, provider_account: provider)
      get edit_admin_buyers_account_invoice_path(buyer, invoice)
      assert_response :forbidden
    end

    test 'member user with billing permission can manage invoice' do
      user.member_permission_ids = %i[partners finance]
      user.save!
      buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
      provider.settings.allow_finance!

      get admin_buyers_account_invoices_path(buyer)
      assert_response :success

      assert_difference -> { Invoice.count }, 1 do
        post admin_buyers_account_invoices_path(buyer)
        assert_response :redirect
      end

      invoice = FactoryBot.create(:invoice, buyer_account: buyer, provider_account: provider)
      get edit_admin_buyers_account_invoice_path(buyer, invoice)
      assert_response :success
    end

    test "can't manage buyer accounts" do
      user.member_permission_ids = []
      user.save!

      get admin_buyers_accounts_path
      assert_response :forbidden

      get new_admin_buyers_account_path
      assert_response :forbidden

      buyer = FactoryBot.create(:simple_buyer, provider_account: provider, name: 'bob')

      get admin_buyers_account_path(buyer)
      assert_response :forbidden

      get edit_admin_buyers_account_path(buyer)
      assert_response :forbidden

      put admin_buyers_account_path(buyer), params: {account: {name: 'carl'}}
      assert_response :forbidden
      assert_equal 'bob', buyer.reload.name

      delete admin_buyers_account_path(buyer)
      assert_response :forbidden
      assert Account.exists?(buyer.id)

      assert_no_difference(Account.method(:count)) do
        post admin_buyers_accounts_path, params: {
          account: {
            name: 'secret agent',
            user: { username: 'johndoe', email: 'user@example.org', password: 'secretpassword' }
          }
        }
      end
      assert_response :forbidden
    end
  end

  class ProviderLoggedInTest < Buyers::AccountsControllerTest
    def setup
      @buyer = FactoryBot.create(:buyer_account, name: 'bob')
      @provider = @buyer.provider_account
      login! @provider
    end

    test '#new and #create redirects if it has a non-default application plan' do
      @provider.account_plans.delete_all
      @provider.account_plans.create!(name: 'non default account plan')

      post admin_buyers_accounts_path, params: {
        account: {
          org_name: 'Alaska',
          user: { email: 'foo@example.com', password: '123456', username: 'hello' }
        }
      }

      assert_redirected_to admin_buyers_account_plans_path
      assert_equal 'Please, create an Account Plan first', flash[:danger]
    end

    test 'POST with an error outside account or user is shown as a flash error' do
      errors = ActiveModel::Errors.new(Plan.new)
      errors.add(:base, 'error that is not in "user" or "account"')
      errors.add(:base, 'another error')
      Signup::Result.any_instance.stubs(errors: errors)

      post admin_buyers_accounts_path, params: {
        account: {
          org_name: 'Alaska',
          user: { email: 'foo@example.com', password: '123456', username: 'hello' }
        }
      }

      assert_equal 'error that is not in "user" or "account". another error', flash[:danger]
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

      assert_select %(td a[href="#{admin_buyers_account_applications_path(@buyer)}"]), text: '5'
    end

    test 'checks if link under number of applications is correct as member' do
      @provider.settings.allow_multiple_applications!
      service = FactoryBot.create(:service, account: @provider)
      plan  = FactoryBot.create(:published_application_plan, issuer: service)

      FactoryBot.create_list(:application, 2, user_account: @buyer)
      FactoryBot.create_list(:application, 3, service: service, plan: plan, user_account: @buyer)

      # Testing member permissions
      member = FactoryBot.create(:member, account: @provider)
      member.activate!
      member.member_permissions.create(admin_section: :partners)
      member.member_permission_service_ids = [service.id]
      member.save!
      login! @provider, user: member
      get admin_buyers_accounts_path
      assert_response :success

      assert_select %(td a[href="#{admin_buyers_account_applications_path(@buyer)}"]), text: '3'
    end

    test '#create' do
      assert_no_difference(-> { @provider.buyers.count }) do
        post admin_buyers_accounts_path, params: {
          account: {
            org_name: 'My organization'
          }
        }
        assert_select '.pf-m-error'
        assert_response :success
      end

      assert_difference(-> { @provider.buyers.count }) do
        post admin_buyers_accounts_path, params: {
          account: {
            org_name: 'My organization',
            user: {
                username: 'johndoe',
                email: 'user@example.org',
                password: 'superSecret1234#'
            }
          }
        }
        assert_select '.pf-m-error', false
        assert_response :redirect
      end
    end

    test "can't manage buyer's of other providers" do
      another_provider = FactoryBot.create(:provider_account)
      login! another_provider

      get admin_buyers_accounts_path
      assert assigns(:presenter).buyers
      assert_equal 0, assigns(:presenter).buyers.size

      get admin_buyers_account_path(@buyer)
      assert_response :not_found

      get edit_admin_buyers_account_path(@buyer)
      assert_response :not_found

      put admin_buyers_account_path(@buyer), params: {account: {name: 'mike'}}
      assert_response :not_found
      assert_equal 'bob', @buyer.reload.name

      delete admin_buyers_account_path(@buyer)
      assert_response :not_found
      assert Account.exists?(@buyer.id)
    end

    test 'index/search & show display the admin_user_display_name' do
      get admin_buyers_accounts_path

      page = Nokogiri::HTML4::Document.parse(response.body)
      expected_display_names = @provider.buyer_accounts.map { |buyer| buyer.decorate.admin_user_display_name }
      assert_same_elements expected_display_names, page.xpath('//tbody/tr/td[2]/a').map(&:text)


      get admin_buyers_accounts_path(id: @buyer.id)
      assert_xpath('//tbody/tr/td[2]/a', @buyer.decorate.admin_user_display_name)
    end

    test 'User with invalid data shows an flash error' do
      post admin_buyers_accounts_path, params: {
        account: {
          org_name: 'My organization',
          user: {
            username: 'hello'
          }
        }
      }
      assert_equal 'Users invalid', flash[:danger]
    end

    # This situation is not normal, but can happen in case some account data is corrupted (maybe an incomplete deletion).
    # The idea is that the index page should not throw a 500 Internal Server Error when a single account is broken
    test 'load the index page successfully when an account has no admin users' do
      @invalid_buyer = FactoryBot.create(:buyer_account, name: 'invalid', provider_account: @provider)
      @invalid_buyer.users.first.make_member
      assert @invalid_buyer.reload.users.first.member?

      get admin_buyers_accounts_path
      assert_response :success
      assert_xpath "//tr[@id='account_#{@invalid_buyer.id}']//td[contains(@class,'actions')]//i[contains(@class,'fa-exclamation-triangle')]", 1
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

    test 'suspend button is displayed only when account is not deleted or marked for deletion' do
      ThreeScale.config.stubs(onpremises: false)
      get admin_buyers_account_path(@provider)
      assert_select %(td a.button-to.action.suspend), true

      @provider.suspend
      get admin_buyers_account_path(@provider)
      assert_select %(td a.button-to.action.suspend), false

      delete admin_buyers_account_path(@provider)
      assert_select %(td a.button-to.action.suspend), false

    end

  end

  class NotLoggedInTest < ActionDispatch::IntegrationTest
    test "anonymous users can't manage buyer accounts" do
      provider = FactoryBot.create(:provider_account)
      host! provider.external_admin_domain

      get admin_buyers_accounts_path
      assert_redirected_to provider_login_path

      get new_admin_buyers_account_path
      assert_redirected_to provider_login_path

      buyer = FactoryBot.create(:simple_buyer, provider_account: provider, name: 'bob')

      get admin_buyers_account_path(buyer)
      assert_redirected_to provider_login_path

      get edit_admin_buyers_account_path(buyer)
      assert_redirected_to provider_login_path

      put admin_buyers_account_path(buyer), params: {account: {name: 'carl'}}
      assert_redirected_to provider_login_path
      assert_equal 'bob', buyer.reload.name

      delete admin_buyers_account_path(buyer)
      assert_redirected_to provider_login_path
      assert Account.exists?(buyer.id)

      assert_no_difference(Account.method(:count)) do
        post admin_buyers_accounts_path, params: {
          account: {
            name: 'secret agent',
            user: { username: 'johndoe', email: 'user@example.org', password: 'secretpassword' }
          }
        }
      end
      assert_redirected_to provider_login_path
    end
  end

  class ManyAccountsTest < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:provider_account)
      login! @provider
    end

    test 'no N+1 problems in the index' do
      populate = ->(n) {FactoryBot.create_list(:buyer_account, n, provider_account: @provider)}

      assert_perform_constant_number_of_queries(populate: populate) do
        perform
      end
    end

    # needs to be a method (https://github.com/palkan/n_plus_one_control/pull/58)
    # must be public for n_plus_one_control to detect it
    def perform
      get admin_buyers_accounts_path
    end
    alias warmup perform
  end
end
