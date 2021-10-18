# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyerAccountPlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan
    @buyer.reload

    @not_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service

    host! @provider.admin_domain
  end

  test 'account plans listing' do
    get admin_api_account_buyer_account_plan_path(:account_id => @buyer.id, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)

    assert  xml.xpath('.//plan/id').children.first.to_s == @buyer.bought_account_plan.id.to_s
    assert  xml.xpath('.//plan/name').children.first.to_s == @buyer.bought_account_plan.name.to_s
    assert  xml.xpath('.//plan/type').children.first.to_s == @buyer.bought_account_plan.class.to_s.underscore

    assert  xml.xpath(".//plans/plan[@id='#{@not_plan.id}']").empty?
  end

  test 'account plans for an inexistent buyer replies 404' do
    get admin_api_account_buyer_account_plan_path(0, :format => :xml), params: { :provider_key => @provider.api_key }
    assert_xml_404
  end

  test 'security wise: buyers account plans is access denied in buyer side' do
    host! @provider.domain
    get admin_api_account_buyer_account_plan_path(@buyer, :format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :forbidden
  end

end
