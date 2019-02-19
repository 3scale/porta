# frozen_string_literal: true

require 'test_helper'

class ApiDocsServicePresenterTest < ActiveSupport::TestCase
  test '#host_with_port' do
    service = FactoryBot.build(:proxy, endpoint: 'http://example.com:8080').service
    spec = FactoryBot.build(:api_docs_service, service: service, account: service.account)
    spec_presenter = ApiDocsServicePresenter.new(spec)
    assert_equal 'example.com:8080', spec_presenter.host_with_port
  end
end
