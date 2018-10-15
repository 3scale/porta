require 'test_helper'

class Provider::Admin::ApiDocsControllerTest < ActionController::TestCase

  setup do
    @provider = FactoryGirl.create(:provider_account)
    login_provider(@provider)
  end

  test 'should not show secondary navigation' do
    get :show
    assert_select 'ul[id="tabs"]' do |elements|
      elements.each {|element| assert_select("li a", 0)}
    end
  end
end
