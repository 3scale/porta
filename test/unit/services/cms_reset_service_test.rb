require 'test_helper'

class CMSResetServiceTest < ActiveSupport::TestCase
  def setup
    @cms_reset = CMSResetService.new
  end

  def test_call
    provider = FactoryGirl.create(:simple_provider)

    refute_operator provider.pages.count, :>, 1

    SimpleLayout.new(provider).import!
    assert_operator provider.pages.count, :>, 1

    page = provider.pages.first!

    assert @cms_reset.call(provider)

    refute_equal page, provider.pages.first!
  end
end
