# frozen_string_literal: true
require 'test_helper'

class Liquid::Drops::ApiSpecDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    @spec = provider.api_docs_services.create!(:name => 'Das Paella', :body => '{"basePath":"http://paella4guiris", "apis":[]}', :published => true)
  end

  test 'Returns the correct url of the API spec' do
    assert_equal'/swagger/spec/das_paella.json', api_spec.url
  end

  test 'Returns the right service drop' do
    @spec.service = @service
    @spec.save!
    service_drop = api_spec.service
    assert_instance_of Liquid::Drops::Service, service_drop
    assert_equal @service.name, service_drop.name

    @spec.service = nil
    @spec.save!
    assert_nil api_spec.service
  end

  test 'Returns the service endpoint' do
    refute api_spec.api_product_production_public_base_url

    @spec.service = @service
    @spec.save!
    assert_equal @service.proxy.endpoint, api_spec.api_product_production_public_base_url
  end

  test '#published? returns the state of API spec' do
    @spec.update(published: true)
    assert_equal true, api_spec.published?

    @spec.update(published: false)
    assert_equal false, api_spec.published?
  end

  def api_spec
    Drops::ApiSpec.new(@spec)
  end
end
