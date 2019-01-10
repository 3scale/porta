require 'test_helper'

class Logic::CMSTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'cms_toolbar_intro_visible?' do
    # john still exists
    # no change has been made to main_layout
  end

end
