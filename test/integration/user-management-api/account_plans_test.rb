# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountPlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    FactoryBot.create :account_plan,     :issuer => @provider
    FactoryBot.create :application_plan, :issuer => @provider.default_service
    FactoryBot.create :service_plan,     :issuer => @provider.default_service

    host! @provider.admin_domain

  end

  # Access token

  test 'index (access_token)' do
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    # no token
    get(admin_api_account_plans_path(format: :xml))
    assert_response :forbidden

    # member does not have the plans permission
    get(admin_api_account_plans_path(format: :xml), params: { access_token: token.value })
    assert_response :forbidden

    user.admin_sections = ['partners', 'plans']
    user.save!

    get(admin_api_account_plans_path(format: :xml), params: { access_token: token.value })
    assert_response :success

    user.admin_sections = []
    user.role = 'admin'
    user.save!

    # provider admin
    get(admin_api_account_plans_path(format: :xml), params: { access_token: token.value })
    assert_response :success

    Account.any_instance.expects(:master?).returns(true).at_least_once

    # master admin
    get(admin_api_account_plans_path(format: :xml), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'index' do
    get(admin_api_account_plans_path(:format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_only_account_plans xml
  end

  test 'security wise: index is access denied in buyer side' do
    host! @provider.domain
    get(admin_api_account_plans_path(:format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :forbidden
  end

  pending_test 'apis can be behind the site_access code' do
    host! @provider.admin_domain
    Account.master.update_attribute :site_access_code, "123456"

    get(admin_api_account_plans_path(:format => :xml), params: { :provider_key => @provider.api_key })

    assert @response.body =~ /Access code/
  end

  test 'show' do
    # admin_account_plan
    get("/admin/api/account_plans/#{@provider.account_plans.first.id}", params: { :format => :xml, :provider_key => @provider.api_key })

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    #TODO: move this to account_plan_test#to_xml
    assert_an_account_plan xml, @provider
  end

  test 'create' do
    post(admin_api_account_plans_path(:format => :xml), params: { :name => 'awesome account plan', :state_event => 'publish', :provider_key => @provider.api_key })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_plan xml, @provider
    assert xml.xpath('.//plan/name').children.first.to_s  == 'awesome account plan'
    assert xml.xpath('.//plan/state').children.first.to_s == 'published'
    #TODO: this should also check if actually the object was created
  end

  test 'update' do
    plan = FactoryBot.create :account_plan, :issuer => @provider, :name => 'namy'

    put("/admin/api/account_plans/#{plan.id}.xml", params: { :state_event => 'publish', :name => 'new name', :provider_key => @provider.api_key })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_plan xml, @provider
    #TODO: this should check the account_plan was updated (see features test)
    assert xml.xpath('.//plan/name').children.first.to_s  == 'new name'
    assert xml.xpath('.//plan/state').children.first.to_s == 'published'
  end

  test 'default' do
    plan = FactoryBot.create :account_plan, :issuer => @provider, :name => 'namy'
    @provider.update_attribute(:default_account_plan, plan)
    plan.publish!

    put default_admin_api_account_plan_path(plan,
                                                 :provider_key => @provider.api_key,
                                                 :format => :xml)

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_plan xml, @provider
    assert !xml.xpath('.//plan[@default="true"]').empty?
  end

  pending_test 'hidden plan cannot be mark as default' do
  end

  test 'destroy' do
    account_plan = FactoryBot.create :account_plan, :issuer => @provider

    delete("/admin/api/account_plans/#{account_plan.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :success
    refute @response.body.presence

    assert_raise ActiveRecord::RecordNotFound do
      account_plan.reload
    end
  end

  test 'destroy returns error when deletion failed' do
    #TODO: move this to some setup
    account_plan = FactoryBot.create :account_plan, :issuer => @provider
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    buyer.buy! account_plan

    delete("/admin/api/account_plans/#{account_plan.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :forbidden
    assert_xml_error(@response.body, "This account plan cannot be deleted")
  end

end
