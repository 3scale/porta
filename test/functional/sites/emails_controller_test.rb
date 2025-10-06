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
      assert assigns(:products)
    end

    test 'edit props' do
      service1 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 1')
      service2 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 2', support_email: 'custom@example.com')

      get :edit

      props = @controller.send(:props)
      assert props
      assert_equal 'Add a custom support email', props[:buttonLabel]
      assert_includes props[:exceptions].pluck(:id), service2.id
      assert_includes props[:products].pluck(:id), service1.id
      assert_not_includes props[:products].pluck(:id), service2.id
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

    test 'products without custom support email' do
      get :edit

      product_ids = @controller.send(:props)[:products].pluck(:id)

      assert_equal product_ids, [@service1, @service3].pluck(:id)
      assert_not_includes product_ids, @service2.id

      assert_equal 2, @controller.send(:props)[:productsCount]
    end

    test 'products with custom support emails' do
      get :edit

      exception_ids = @controller.send(:props)[:exceptions].pluck(:id)

      assert_equal exception_ids, [@service2.id]
      assert_not_includes exception_ids, [@service1, @service3].pluck(:id)
    end

    test 'products path when >20 products' do
      @controller.stubs(:total_products_without_support_email).returns(21)

      get :edit

      props = @controller.send(:props)
      assert_equal 21, props[:productsCount]
      assert_not_nil props[:productsPath]
      assert_match %r{/apiconfig/services}, props[:productsPath]
    end

    test 'products path when <20 products' do
      @controller.stubs(:total_products_without_support_email).returns(20)

      get :edit

      props = @controller.send(:props)
      assert_equal 20, props[:productsCount]
      assert_nil props[:productsPath]
    end
  end
end
