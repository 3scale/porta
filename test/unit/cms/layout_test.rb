require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LayoutTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'should not be deleted if has pages linking to it' do
    layout = FactoryBot.create :cms_layout
    page = FactoryBot.create :cms_page, :layout => layout
    layout.destroy
    assert layout.reload
  end

end
