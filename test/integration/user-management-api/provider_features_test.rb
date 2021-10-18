# frozen_string_literal: true

require 'test_helper'

class EnterpriseApiProviderFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'


    host! @provider.admin_domain
  end

  test 'index' do
    FactoryBot.create :feature, :featurable => @provider

    get(admin_api_features_path, params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_all_account_features xml, @provider
  end

  test 'show' do
    feature = FactoryBot.create :feature, :featurable => @provider

    get(admin_api_feature_path(feature), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_feature xml

    assert_equal  @provider.id.to_s, xml.xpath('.//feature/account_id').children.first.text
  end

  test 'create' do
    post(admin_api_features_path, params: { :provider_key => @provider.api_key, :format => :xml, :name => 'example', :system_name => 'system_example' })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_feature xml
    assert_equal  'example', xml.xpath('.//feature/name').children.first.to_s
    assert_equal  'system_example', xml.xpath('.//feature/system_name').children.first.to_s
    assert_equal  @provider.id.to_s, xml.xpath('.//feature/account_id').children.first.to_s

    feature = @provider.features.reload.last
    assert_equal "example", feature.name
    assert_equal "system_example", feature.system_name
  end

  pending_test 'create errors xml'
  pending_test 'create features with scope is ignored'

  test 'update' do
    feature = FactoryBot.create(:feature, :featurable => @provider,
                      :name => 'old name', :system_name => 'old_system_name')

    put("/admin/api/features/#{feature.id}", params: { :provider_key => @provider.api_key, :format => :xml, :name => 'new name', :system_name => 'new_system_name' })

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_an_account_feature xml
    assert_equal  'new name', xml.xpath('.//feature/name').children.first.to_s
    assert_equal  'new_system_name', xml.xpath('.//feature/system_name').children.first.to_s

    feature.reload
    assert_equal  "new name", feature.name
    assert_equal  "new_system_name", feature.system_name
  end

  pending_test 'update with wrong id'
  pending_test 'update errors xml'

  test 'destroy' do
    feature = FactoryBot.create :feature, :featurable => @provider

    delete("/admin/api/features/#{feature.id}",
                :provider_key => @provider.api_key,
                :format => :xml, :method => "_destroy")

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      feature.reload
    end
  end

  pending_test 'destroy with wrong id'

end
