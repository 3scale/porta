require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LayoutTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:provider_account)
  end

  test 'should not be deleted if has pages linking to it' do
    layout = Factory :cms_layout
    page = Factory :cms_page, :layout => layout
    layout.destroy
    assert layout.reload
  end

end
