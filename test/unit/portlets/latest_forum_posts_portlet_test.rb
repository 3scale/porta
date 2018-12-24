require 'test_helper'

class LatestForumPostsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @forum = FactoryBot.create(:forum)
  end

  test "Should be able to create new instance of a portlet" do
    assert LatestForumPostsPortlet.create!(:provider => @provider, :portlet_type => 'LatestForumPostsPortlet', :system_name => 'name', :posts => @forum.posts.count)
  end

end