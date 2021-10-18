# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersApplicationsTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    host! @provider.admin_domain

    @service = @provider.default_service

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan

    @buyer.bought_service_contracts.create! :plan => @service.service_plans.first

    @app_plan = FactoryBot.create :application_plan, :issuer => @service
    @app_plan.publish!
    @buyer.buy! @app_plan

    @published_app_plan = FactoryBot.create :application_plan, :issuer => @service
    @published_app_plan.publish!
    @hidden_app_plan = FactoryBot.create :application_plan, :issuer => @service

    @buyer.reload

    ReferrerFilter.enable_backend!
    stub_backend_get_keys
  end

  test 'index' do
    get admin_api_account_applications_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success

    assert_applications(response.body,
                        { "plan/id" => @app_plan.id, :user_account_id => @buyer.id })
  end

  #TODO: test extra fields in index

  test 'index states' do
    #TODO: dry these setups outta the examples
    pending_plan = FactoryBot.create :application_plan, :issuer => @service, :approval_required => true
    @buyer.buy! pending_plan
    @buyer.reload
    assert @buyer.bought_cinstances.find_by_plan_id(pending_plan.id).pending?

    suspend_plan = FactoryBot.create :application_plan, :issuer => @service, :approval_required => true
    @buyer.buy! suspend_plan
    @buyer.reload
    @buyer.bought_cinstances.last.accept!
    @buyer.bought_cinstances.last.suspend!
    assert @buyer.bought_cinstances.find_by_plan_id(suspend_plan.id).suspended?

    [:pending, :live, :suspended].each do |state|
      get(admin_api_account_applications_path(@buyer, :format => :xml), params: { :state => state, :provider_key => @provider.api_key })

      assert_response :success

      assert_applications(response.body,
                          { :state => state, :user_account_id => @buyer.id })
    end
  end

  pending_test 'index returns fields defined'

  test 'security wise: buyers applications is access denied in buyer side' do
    host! @provider.domain
    get admin_api_account_applications_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :forbidden
  end

  test 'show' do
    application = @buyer.bought_cinstances.last

    get(admin_api_account_application_path(@buyer, :id => application.id, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success

    assert_application(response.body,
                       { :id => application.id,
                         :user_account_id => @buyer.id,
                         :created_at => application.created_at.xmlschema,
                         :updated_at => application.updated_at.xmlschema })
  end

  test 'show returns defined fields' do
    application = @buyer.bought_cinstances.last
    application.update_attributes :name => "tomatoes < > &", :description => "rotten < > &"

    get(admin_api_account_application_path(@buyer, :id => application.id, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success

    assert_application(response.body, { :name => "tomatoes &lt; &gt; &amp;", :description => "rotten &lt; &gt; &amp;" })
  end

  test 'show returns defined fields for json' do
    application = @buyer.bought_cinstances.last
    application.update_attributes :name => "CoinBase", :description => "Mining bitcoins in your screesaver like a boss"

    get(admin_api_account_application_path(@buyer, :id => application.id, :format => :json), params: { :provider_key => @provider.api_key })

    assert_response :success

    application = JSON.parse(@response.body)["application"]

    assert_equal "CoinBase", application["name"]
    assert_match "like a boss", application["description"]
  end

  test 'show returns extra fields escaped' do
    field_defined(@provider, { :target => "Cinstance", "name" => "some_extra_field" })
    app = @buyer.bought_cinstances.last
    app.extra_fields = { :some_extra_field => "< > &" }
    app.save

    get(admin_api_account_application_path(@buyer, :id => app.id, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, :extra_fields => { :some_extra_field => '&lt; &gt; &amp;' })
  end

  test 'show json with extra fields' do
    field_defined(@provider, { :target => "Cinstance", "name" => "mind-control" })
    field_defined(@provider, { :target => "Cinstance", "name" => "spiciness_level" })

    app = @buyer.bought_cinstances.last
    app.extra_fields = { "mind-control" => "", "spiciness_level" => "Habanero" }
    app.save

    get(admin_api_account_application_path(@buyer, id: app.id, format: :json), params: { provider_key: @provider.api_key })

    assert_response :success

    application = JSON.parse(@response.body)["application"]

    assert_equal "", application["mind-control"]
    assert_equal "Habanero", application["spiciness_level"]
  end

  test 'show returns referrer filters' do
    application = @buyer.bought_cinstances.last
    application.service.update_attribute :referrer_filters_required, true

    expect_backend_create_referrer_filter(application, "foo.example.org")
    application.referrer_filters.add('foo.example.org')

    get(admin_api_account_application_path(@buyer, :id => application.id, :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, { :id => application.id, "referrer_filters/referrer_filter" => "foo.example.org" })
  end

  #TODO: clean the tests
  test 'create referrer filters' do
    application = @buyer.bought_cinstances.last
    application.service.update_attribute :referrer_filters_required, true
    stub_backend_referrer_filters("foo.example.org")
    expect_backend_create_referrer_filter(application, "foo.example.org")

    post(admin_api_account_application_referrer_filters_path(@buyer, application, :referrer_filter => "foo.example.org", :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, { :id => application.id, "referrer_filters/referrer_filter" => "foo.example.org" })
  end

  context 'find' do
    setup do
      @application = @buyer.bought_cinstances.last
      host! @provider.admin_domain
    end

    should 'return 404 on non found app' do
      get(find_admin_api_account_applications_path(@buyer.id, :format => :xml), params: { :user_key => "SHAWARMA", :provider_key => @provider.api_key })
      assert_xml_404
    end

    should 'find by user_key on backend v1' do
      @service.backend_version = '1'
      @service.save!

      get(find_admin_api_account_applications_path(@buyer.id,
                                                   :format => :xml), params: { :user_key => @application.user_key, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :user_key => @application.user_key })
    end

    should 'find by app_id on backend v2' do
      @service.backend_version = '2'
      @service.save!

      get(find_admin_api_account_applications_path(@buyer.id,
                                                   :format => :xml), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })
    end

    should 'find by app_id on backend oauth' do
      @service.backend_version = 'oauth'
      @service.save!

      get(find_admin_api_account_applications_path(@buyer.id,
                                                   :format => :xml), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })
    end

  end # find

  test 'create' do
    post(admin_api_account_applications_path(@buyer,
                                             :format => :xml), params: { :plan_id => @hidden_app_plan.id, :name => "chucky", :description => "rocks awesome", :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, { :name => "chucky",
                       :description => "rocks awesome" })

    created_app = @buyer.bought_cinstances.last
    assert_equal "chucky",        created_app.name
    assert_equal "rocks awesome", created_app.description
    assert_equal 'api',           created_app.create_origin
  end

  test 'create forces the subscription to service' do
    @buyer.bought_service_contracts.map &:destroy

    post(admin_api_account_applications_path(@buyer,
                                             :format => :xml), params: { :plan_id => @hidden_app_plan.id, :name => "chucky", :description => "rocks awesome", :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, { :name => "chucky",
                       :description => "rocks awesome" })

    created_app = @buyer.bought_cinstances.last
    assert_equal "chucky",        created_app.name
    assert_equal "rocks awesome", created_app.description
    assert_equal 'api',           created_app.create_origin
  end

  test 'create with custom app id' do
    @service.update_attribute(:backend_version, '2')

    post(admin_api_account_applications_path(@buyer,
                                             :format => :xml), params: { :plan_id => @hidden_app_plan.id, :name => "chucky", :description => "rocks awesome", :application_id => "superawesomeid", :provider_key => @provider.api_key })

    assert_response :success
    assert_application(response.body, { :name => "chucky",
                       :description => "rocks awesome", :application_id => "superawesomeid" })

    created_app = @buyer.bought_cinstances.last
    assert "chucky" == created_app.name
    assert "superawesomeid" == created_app.application_id
  end

  pending_test 'create errors'

  test 'create with extra fields' do
    field_defined(@provider,
                  { :target => "Cinstance", "name" => "some_extra_field" })
    field_defined(@provider,
                  { :target => "Cinstance", "name" => "some_other_extra_field" })

    post(admin_api_account_applications_path(@buyer,
                                             :format => :xml), params: { :plan_id => @hidden_app_plan.id, :name => "extra app", :description => "extra app", "some_extra_field" => 'extra value', "some_other_extra_field" => 'other extra value', :provider_key => @provider.api_key })

    extra_fields = {
      "some_extra_field" => 'extra value',
      "some_other_extra_field" => 'other extra value'}

      assert_response :success
      assert_application(response.body, :name => "extra app",
                         :extra_fields => extra_fields)

      app = @buyer.bought_cinstances.last
      assert_equal "extra app", app.name
      assert_equal extra_fields, app.extra_fields.slice("some_extra_field",
                                                        "some_other_extra_field")
  end

  test 'update' do
    app = @buyer.bought_cinstances.last
    put(admin_api_account_application_path(@buyer, id: app.id, format: :xml), params: { name: "descriptive", provider_key: @provider.api_key, redirect_url: 'http://example.com' })

    assert_response :success
    assert_application response.body, { :name => "descriptive" }

    app.reload
    assert_equal 'descriptive', app.name
    assert_equal 'http://example.com', app.redirect_url
  end

  test 'update with long user_key' do
    @service.backend_version = '1'
    @service.save!

    app = @buyer.bought_cinstances.last
    key = "k"*256

    put(admin_api_account_application_path(@buyer, :id => app.id,
                                           :format => :xml), params: { :user_key => key, :provider_key => @provider.api_key })

    assert_response :success

    assert_application response.body, { :user_key => key }

    app.reload
    assert app.user_key, key

  end

  test 'update extra_fields' do
    field_defined(@provider,
                  { :target => "Cinstance", "name" => "some_extra_field" })
    field_defined(@provider,
                  { :target => "Cinstance", "name" => "some_other_extra_field" })
    extra_fields = {
      "some_extra_field" => 'extra value',
      "some_other_extra_field" => 'other extra value'}

      app = @buyer.bought_cinstances.last
      put(admin_api_account_application_path(@buyer, :id => app.id, :format => :xml), params: extra_fields.merge(:provider_key => @provider.api_key))

      assert_response :success
      assert_application(response.body, :extra_fields => extra_fields)
      app.reload
      assert_equal extra_fields, app.extra_fields.slice("some_extra_field",
                                                        "some_other_extra_field")
  end

  test 'customize_plan' do
    application = @buyer.application_contracts.first
    plan = application.plan

    assert_difference plan.method(:contracts_count), -1 do
      put(customize_plan_admin_api_account_application_path(@buyer, application), params: { provider_key: @provider.api_key, format: :xml })

      assert_response :success
      plan.reload
    end

    xml = Nokogiri::XML::Document.parse(response.body)

    assert_an_application_plan xml, @service

    assert xml.xpath('.//plan[@custom="true"]').present?
    assert_equal 'hidden', xml.xpath('.//plan/state').children.first.to_s
    refute_equal plan.id.to_s, xml.xpath('.//plan/id').children.first.to_s
    assert_equal 1, application.reload.plan.contracts_count
  end

  pending_test 'customized_plan one does nothing'

  test 'decustomize_plan' do
    application = @buyer.application_contracts.first
    plan = application.customize_plan!
    original = plan.original.reload

    assert_difference original.method(:contracts_count), +1 do
      put(decustomize_plan_admin_api_account_application_path(@buyer, application), params: { provider_key: @provider.api_key, format: :xml })
      assert_response :success
      original.reload
    end

    xml = Nokogiri::XML::Document.parse(response.body)

    assert_an_application_plan xml, @service

    assert xml.xpath('.//plan[@custom="true"]').empty?
    assert_equal original.id.to_s, xml.xpath('.//plan/id').children.first.to_s
  end

  pending_test 'not custom one does nothing'

  test 'change plan to existing plan should not trigger 500 error' do
    put change_plan_admin_api_account_application_path(@buyer, @buyer.application_contracts.first,
          :provider_key => @provider.api_key, "plan_id" => @published_app_plan.id, :format => :xml)
    assert_response :success

    put change_plan_admin_api_account_application_path(@buyer, @buyer.application_contracts.first,
          :provider_key => @provider.api_key, "plan_id" => @published_app_plan.id, :format => :json)
    assert_response :success
  end

  test 'change application plan' do
    put change_plan_admin_api_account_application_path(@buyer,
                                                       @buyer.application_contracts.first,
                                                       :provider_key => @provider.api_key,
                                                       "plan_id" => @published_app_plan.id,
                                                       :format => :xml)

    assert_response :success

    assert @buyer.application_contracts.first.plan == @published_app_plan

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(response.body)
    assert  xml.xpath('.//plan/id').children.first.to_s == @published_app_plan.id.to_s
  end

  test 'change application plan to a non-published one is permitted' do
    assert @buyer.application_contracts.first.plan == @app_plan

    put change_plan_admin_api_account_application_path(@buyer,
                                                       @buyer.application_contracts.first,
                                                       :provider_key => @provider.api_key,
                                                       "plan_id" => @hidden_app_plan.id,
                                                       :format => :xml)

    assert_response :success
    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(response.body)
    assert  xml.xpath('.//plan/id').children.first.to_s == @hidden_app_plan.id.to_s
  end

  test 'change application plan for an inexistent contract replies 404' do
    put change_plan_admin_api_account_application_path(@buyer, :id => 0,
                                                       :provider_key => @provider.api_key,
                                                       "plan_id" => 0,
                                                       :format => :xml)

    assert_xml_404
  end

  #TODO: is this one needed?
  test 'security wise: applications plan change is access denied in buyer side' do
    host! @provider.domain
    put change_plan_admin_api_account_application_path(@buyer,
                                                       @buyer.application_contracts.first,
                                                       :provider_key => @provider.api_key,
                                                       "plan_id" => @hidden_app_plan.id,
                                                       :format => :xml)

    assert_response :forbidden
  end

  test 'accept' do
    @published_app_plan.update_attribute :approval_required, true
    @buyer.buy! @published_app_plan
    @buyer.reload
    app_contract = @buyer.application_contracts.last
    assert app_contract.pending?

    put accept_admin_api_account_application_path(@buyer, app_contract,
                                                  :provider_key => @provider.api_key,
                                                  :format => :xml)

    assert_response :success

    assert_application response.body, :id => app_contract.id, :state => :live
  end

  test 'nothing happens on already accepted one' do
    application = @buyer.application_contracts.first
    assert application.live?

    put accept_admin_api_account_application_path(@buyer, application,
                    :provider_key => @provider.api_key, :format => :json)

    assert_response 422
  end

  test 'suspend' do
    @published_app_plan.update_attribute :approval_required, true
    @buyer.buy! @published_app_plan
    @buyer.reload
    app_contract = @buyer.application_contracts.last
    app_contract.accept!
    assert app_contract.live?

    put suspend_admin_api_account_application_path(@buyer, app_contract,
                                                   :provider_key => @provider.api_key,
                                                   :format => :xml)

    assert_response :success
    assert_application response.body, :id => app_contract.id, :state => :suspended
  end

  pending_test 'nothing happens on already suspended one'

  test 'resume' do
    @published_app_plan.update_attribute :approval_required, true
    @buyer.buy! @published_app_plan
    @buyer.reload
    app_contract = @buyer.application_contracts.last
    app_contract.accept!
    app_contract.suspend!
    assert app_contract.suspended?

    put resume_admin_api_account_application_path(@buyer, app_contract,
                                                  :provider_key => @provider.api_key,
                                                  :format => :xml)

    assert_response :success
    assert_application response.body, :id => app_contract.id, :state => :live
  end

  test 'resume live apps' do
    @published_app_plan.update_attribute :approval_required, true
    @buyer.buy! @published_app_plan
    @buyer.reload
    app_contract = @buyer.application_contracts.last
    app_contract.accept!
    assert app_contract.live?

    put resume_admin_api_account_application_path(@buyer, app_contract,
                                                  :provider_key => @provider.api_key,
                                                  :format => :xml)

    assert_response :unprocessable_entity
  end

  pending_test 'nothing happens on already resumed one'
end
