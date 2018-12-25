require File.join(File.dirname(__FILE__), '/../../test_helper')

class TableOfContentsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test "Should be able to create new instance of a portlet" do
    assert TableOfContentsPortlet.create!(:provider => @provider, :portlet_type => 'TableOfContentsPortlet', :system_name => 'name', :section_id => @provider.provided_sections.first.id)
  end

end
