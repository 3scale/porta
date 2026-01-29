# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  attr_accessor :current_user

  delegate :can?, to: :ability

  class DocsBaseUrlTest < ActionView::TestCase
    setup do
      ThreeScale.config.stubs(onpremises: false)
      System::Deploy.load_info!
    end

    test 'docs base url' do
      assert_equal 'https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2-saas/html', docs_base_url
    end
  end

  private

  def ability
    Ability.new(current_user)
  end

  def account
    @account ||= FactoryBot.build_stubbed(:simple_provider)
  end
end
