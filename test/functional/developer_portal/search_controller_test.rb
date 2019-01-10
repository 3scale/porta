require 'test_helper'

class DeveloperPortal::SearchControllerTest < DeveloperPortal::ActionController::TestCase

  test 'index forbidden' do
    provider = FactoryBot.create(:provider_account)
    provider.settings.update_attribute(:public_search, false)
    request.host = provider.domain

    get :index, format: 'json', q: 'stuff'

    assert_json 'status' => 'Forbidden'
  end

  test 'index as json' do
    provider = FactoryBot.create(:provider_account)
    provider.settings.update_attribute(:public_search, true)
    request.host = provider.domain
    SearchPresenters::IndexPresenter.any_instance.stubs(search_results: [ 'stuff' ])

    get :index, format: 'json', q: 'stuff'

    assert_json [ 'stuff' ]
  end
end
