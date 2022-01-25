class Forums::Admin::PostsController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::Posts

  activate_menu :buyers, :forum
end
