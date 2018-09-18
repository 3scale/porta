require 'test_helper'

class LatestForumPostsTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:provider_account)
    @forum = Factory(:forum)
  end

  test "Should be able to create new instance of a portlet" do
    assert LatestForumPostsPortlet.create!(:provider => @provider, :portlet_type => 'LatestForumPostsPortlet', :system_name => 'name', :posts => @forum.posts.count)
  end

end