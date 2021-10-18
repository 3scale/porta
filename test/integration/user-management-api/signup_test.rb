# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SignupTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')

    @account_plan1 = @provider.account_plans.first
    @provider.account_plans.default! @account_plan1

    @application_plan1 = FactoryBot.create :application_plan, issuer: @provider.default_service
    @application_plan1.publish!
    @provider.default_service.application_plans.default! @application_plan1

    @application_plan2 = FactoryBot.create :application_plan, issuer: @provider.default_service
    @application_plan2.publish!

    @service_plan1 = FactoryBot.create :service_plan, issuer: @provider.default_service
    @service_plan1.publish!
    @provider.default_service.service_plans.default! @service_plan1

    @service_plan2 = FactoryBot.create :service_plan, issuer: @provider.default_service
    @service_plan2.publish!

    host! @provider.admin_domain

    stub_backend_get_keys
  end

  # Access token
  test 'create (access_token)' do
    user  = FactoryBot.create(:member, account: @provider)
    token = FactoryBot.create(:access_token, owner: user)

    post(admin_api_signup_path, params: { format: :xml, access_token: token.value, org_name: 'fiona', username: 'fiona' })
    assert_response :forbidden

    user.admin_sections = ['partners']
    user.save!
    token.scopes = ['account_management']
    token.save!

    post(admin_api_signup_path, params: { format: :xml, access_token: token.value, org_name: 'fiona', username: 'fiona' })
    assert_response :created
  end

  # Provider key

  #TODO: move this sort of tests to a generic_test file or so
  test 'api should access deny on missing provider_key param' do
    post(admin_api_signup_path, format: :xml)

    assert_response :forbidden
  end

  test 'successful api signup creates app with default fields' do
    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona' })

    assert_response :created
    buyer = Account.buyers.find_by_org_name('fiona')

    assert_equal 1, buyer.bought_cinstances.size
    cinstance = buyer.bought_cinstances.first

    assert_equal 'API signup', cinstance.name
    assert_equal 'API signup', cinstance.description
    assert_equal 'api', cinstance.create_origin
  end

  test 'successful api signup with country' do
    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona', country: 'Spain' })

    assert_response :created
    buyer = Account.buyers.find_by_org_name('fiona')

    assert_equal 1, buyer.bought_cinstances.size
    cinstance = buyer.bought_cinstances.first

    assert buyer.country, 'missing country'
    assert_equal buyer.country.name, "Spain"
  end

  test 'api signup successful with minimal fields (default plans)' do
    UserMailer.expects(:deliver_signup_notification).never

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona' })

    assert_response :created

    xml = Nokogiri::XML::Document.parse @response.body

    assert xml.xpath('.//account').present?
    assert xml.xpath('.//account/users/user').present?
    assert xml.xpath('.//account/applications/application').present?
    plan_ids = xml.xpath('.//account/plans/plan/id').map{|node| node.text.to_i}
    provider_default_plans = [
      @provider.default_account_plan_id,
      @provider.first_service!.default_application_plan_id,
      @provider.first_service!.default_service_plan_id
    ]
    assert_same_elements provider_default_plans, plan_ids

    # are these assertions testing too much!?
    buyer = Account.buyers.find_by_org_name('fiona')
    assert @provider.buyers(true).include? buyer
    assert buyer.admins.include? User.find_by_username('fiona')
    assert_equal @provider.default_account_plan, buyer.bought_account_plan
  end

  test 'api signup successful with lots of fields even extra fields for account and user' do
    UserMailer.expects(:deliver_signup_notification).never

    field_defined(@provider,
                  { target: "Account", "name" => "account_extra_field" })
    field_defined(@provider,
                  { target: "User", "name" => "user_extra_field" })

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', org_legaladdress: "account address", account_extra_field: "account extra value", username: 'fiona', email: "mail@example.com", user_extra_field: "user extra value", vat_rate: 33 })

    assert_response :created

    xml = Nokogiri::XML::Document.parse @response.body
    #we do not assert :org_legaladdress because api does not return that field
    assert_account(@response.body, { org_name: 'fiona',
                     extra_fields: {
                       account_extra_field: "account extra value"
                     }
                   })

    assert_user(@response.body,
                { username: 'fiona', email: "mail@example.com",
                  extra_fields: {
                    user_extra_field: "user extra value"
                }})

    # testing objects creation
    # are these assertions testing too much!?
    buyer = Account.buyers.find_by_org_name('fiona')
    assert @provider.buyers(true).include? buyer
    assert_equal  "account address", buyer.org_legaladdress
    assert_equal "account extra value", buyer.extra_fields["account_extra_field"]
    assert_equal 33, buyer.vat_rate

    buyer_admin = buyer.admins.first
    assert_equal  'fiona', buyer_admin.username
    assert_equal  'mail@example.com', buyer_admin.email
    assert_equal "user extra value", buyer_admin.extra_fields["user_extra_field"]
  end

  test 'api signup with field called address works without error' do
    field_defined(@provider,
                  { target: "User", name: "address", required: true })

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona', email: "mail@example.com", address: "Rue del Percebe, 13" })

    assert_response :created

    assert_account(@response.body, { org_name: 'fiona',
                     extra_fields: {}
                   })

    assert_user(@response.body,
                { username: 'fiona', email: "mail@example.com",
                  extra_fields: {
                    address: "Rue del Percebe, 13"
                }})

    buyer = Account.buyers.find_by_org_name('fiona')
    user = buyer.users.first
    assert user
    assert_equal(user.extra_fields, { 'address' =>  "Rue del Percebe, 13" })
    assert_nil buyer.org_legaladdress.presence
  end

  test 'api signup with plans params passed' do
    UserMailer.expects(:deliver_signup_notification).never

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, account_plan_id: @account_plan1.id, service_plan_id: @service_plan1.id, application_plan_id: @application_plan1.id, org_name: 'fiona', username: 'fiona' })

    assert_response :created

    xml = Nokogiri::XML::Document.parse @response.body

    assert_equal  @account_plan1.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'account_plan']]/id").text
    assert_equal  @service_plan1.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'service_plan']]/id").text
    assert_equal  @application_plan1.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'application_plan']]/id").text
  end

  # Regression test for https://www.pivotaltracker.com/story/show/16598981
  #
  test 'supplied plan has priority over default plan' do
    service = @provider.services.first
    service.update_attribute :default_application_plan, @application_plan1

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, application_plan_id: @application_plan2.id, org_name: 'fiona', username: 'fiona' })

    assert_response :created

    xml = Nokogiri::XML::Document.parse @response.body

    assigned_plan_id = xml.xpath('/account/plans/plan/id[../type/text() ="application_plan"]').text.to_i
    default_plan_id = @provider.services.first.application_plans.default.id

    assert_equal @application_plan2.id, assigned_plan_id
    assert_not_equal  default_plan_id, assigned_plan_id
  end

  test 'api signup should not raise if cinstance validations are enforced' do
    @application_plan1.service.update_attribute :intentions_required, true
    assert @application_plan1.service.intentions_required?

    @provider.settings.allow_multiple_applications

    UserMailer.expects(:deliver_signup_notification).never

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, application_plan_id: @application_plan1.id, org_name: 'fiona', username: 'fiona' })

    assert_response :created
  end

  test 'api signup failure and account and user errors' do
    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: nil, username: nil })

    assert_response :unprocessable_entity

    xml = Nokogiri::XML::Document.parse @response.body
    # is it better to loose the cond? =~ /Org.*/
    assert_match "Organization/Group Name can't be blank", xml.xpath('.//errors/error').text
    assert_match "Username is too short", xml.xpath('.//errors/error').text
  end

  test 'security wise: api signup is access denied in buyer side' do
    host! @provider.domain # buyer domain
    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona' })

    assert_response :forbidden
  end

  test 'api signup on non default account plan replies 404' do
    @provider.account_plans.destroy_all
    assert @provider.account_plans.empty?

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona' })

    assert_xml_404
  end

  test 'api signup on non existant account plan replies 404' do
    @provider.account_plans.destroy_all
    assert @provider.account_plans.empty?

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, org_name: 'fiona', username: 'fiona', plan_id: 0 })

    assert_xml_404
  end

  test 'api signup on a plan with eternity limits' do
    UserMailer.expects(:deliver_signup_notification).never

    application_plan_local = FactoryBot.create :application_plan, issuer: @provider.default_service
    application_plan_local.publish!

    metric_local = application_plan_local.service.metrics.create!(friendly_name: 'CPU ticks', unit: 'tick')

    usage_limit1 = application_plan_local.usage_limits.new(period: :month, value: 10)
    usage_limit1.metric = metric_local
    usage_limit1.save!
    usage_limit2 = application_plan_local.usage_limits.new(period: :eternity, value: 50)
    usage_limit2.metric = metric_local
    usage_limit2.save!

    post(admin_api_signup_path, params: { format: :xml, provider_key: @provider.api_key, account_plan_id: @account_plan1.id, service_plan_id: @service_plan1.id, application_plan_id: application_plan_local.id, org_name: 'fiona', username: 'fiona' })

    xml = Nokogiri::XML::Document.parse @response.body

    assert_response :created

    assert_equal @account_plan1.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'account_plan']]/id").text
    assert_equal @service_plan1.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'service_plan']]/id").text
    assert_equal application_plan_local.id.to_s, xml.xpath(".//account/plans/plan[type[text() = 'application_plan']]/id").text

    assert xml.xpath('.//account/applications/application').present?
  end

end
