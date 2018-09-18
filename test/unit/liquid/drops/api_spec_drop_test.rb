# frozen_string_literal: true
require 'test_helper'

class Liquid::Drops::ApiSpecDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    provider = FactoryGirl.create(:provider_account)
    spec = provider.api_docs_services.create!(:name => 'Das Paella', :body => '{"basePath":"http://paella4guiris", "apis":[]}', :published => true)
    @api_spec = Drops::ApiSpec.new(spec)
  end

  test 'Returns the correct url of the API spec' do
    assert_equal'/swagger/spec/das_paella.json', @api_spec.url
  end
end
