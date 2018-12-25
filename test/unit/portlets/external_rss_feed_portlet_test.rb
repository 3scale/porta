require File.join(File.dirname(__FILE__), '/../../test_helper')

class ExternalRssFeedTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test "Should be able to create new instance of a portlet" do
    assert ExternalRssFeedPortlet.create!(:provider => @provider, :portlet_type => 'ExternalRssFeedPortlet', :system_name => 'name', :url_feed => 'http://feed.example.com/rss')
  end

end
