# frozen_string_literal: true

require 'test_helper'

class Sites::EmailsControllerTest < ActionController::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @admin = FactoryBot.create(:admin, account: @provider)
    @request.host = @provider.internal_admin_domain
  end

  class AuthorizationTest < Sites::EmailsControllerTest
    test 'provider required' do
      get :edit
      assert_redirected_to provider_login_url(host: @request.host)
    end

    test 'denies on premises for master' do
      login_as(@admin)
      ThreeScale.stubs(:master_on_premises?).returns true

      get :edit

      assert_response :forbidden
    end
  end

  class AuthenticatedTest < Sites::EmailsControllerTest
    def setup
      super
      login_as(@admin)
    end

    test 'edit' do
      get :edit

      assert_response :success
      assert_template :edit
    end

    test 'update account support email only' do
      patch :update, params: { account: { support_email: 'new@example.com' } }

      assert_redirected_to action: :edit
      assert_equal 'new@example.com', @provider.reload.support_email
      assert_equal 'new@example.com', @provider.reload.finance_support_email
      assert_equal 'Your support emails have been updated', flash[:success]
    end

    test 'update account and finance support emails' do
      patch :update, params: { account: { support_email: 'support@example.com',
                                          finance_support_email: 'finance@example.com' } }

      assert_redirected_to action: :edit
      assert_equal 'support@example.com', @provider.reload.support_email
      assert_equal 'finance@example.com', @provider.reload.finance_support_email
      assert_equal 'Your support emails have been updated', flash[:success]
    end

    test 'update with an invalid email' do
      patch :update, params: { account: { support_email: 'invalid-email' },
                               finance_support_email: 'also@wrong@.com' }

      assert_response :success
      assert_template :edit
      assert_equal "Couldn't update your support emails", flash[:error]
      assert_not_equal 'invalid-email', @provider.reload.support_email
      assert_not_equal 'also@wrong@.com', @provider.finance_support_email
    end

    test 'update permitted params' do
      original_name = @provider.org_name
      patch :update, params: { account: { org_name: 'Hacked Name' } }

      assert_redirected_to action: :edit
      assert_equal original_name, @provider.reload.org_name
    end
  end

  class CustomSupportEmailsTest < Sites::EmailsControllerTest
    def setup
      super
      login_as(@admin)
      @service1 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 1')
      @service2 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 2', support_email: 'beta@example.com')
      @service3 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 3')

      @provider.services = [@service1, @service2, @service3]
    end

    test 'edit props' do
      props = @controller.send(:props)
      assert props
      assert_equal I18n.t('sites.emails.edit.add_exception'), props[:buttonLabel]
      assert_equal I18n.t('sites.emails.remove_confirmation'), props[:removeConfirmation]
      assert_same_elements props[:exceptions].pluck(:id), [@service2.id]
      assert_same_elements props[:products].pluck(:id), [@service1.id, @service3.id]
      assert_equal 2, props[:productsCount]
      assert_not_empty props[:productsPath]
    end

    test 'products are paginated to 20 per page' do
      FactoryBot.create_list(:simple_service, 25, account: @provider)

      props = @controller.send(:props)
      assert_equal 20, props[:products].size
      assert_equal 27, props[:productsCount] # 25 + 2 from setup
    end

    test 'products are ordered by name' do
      FactoryBot.create(:simple_service, account: @provider, name: 'Z Service')
      FactoryBot.create(:simple_service, account: @provider, name: 'A Service')
      FactoryBot.create(:simple_service, account: @provider, name: 'M Service')

      props = @controller.send(:props)
      product_names = props[:products].pluck(:name)

      assert_equal 'A Service', product_names.first
      assert product_names.index('M Service') < product_names.index('Z Service')
    end

    test 'only exceptions include support_email in JSON' do
      props = @controller.send(:props)
      assert props[:exceptions].pluck(:supportEmail).all?
      assert props[:products].pluck(:supportEmail).none?
    end

    test 'only accessible services are included' do
      other_provider = FactoryBot.create(:provider_account)
      other_service = FactoryBot.create(:simple_service, account: other_provider,
                                                         name: 'Other Provider Service')

      props = @controller.send(:props)
      product_ids = props[:products].pluck(:id)
      exception_ids = props[:exceptions].pluck(:id)

      assert_not_includes product_ids, other_service.id
      assert_not_includes exception_ids, other_service.id
    end
  end
end
