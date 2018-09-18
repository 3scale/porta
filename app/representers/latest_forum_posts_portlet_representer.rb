module LatestForumPostsPortletRepresenter
  include ThreeScale::JSONRepresenter
  include CMS::PortletRepresenter

  property :posts

end
