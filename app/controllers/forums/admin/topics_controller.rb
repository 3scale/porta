class Forums::Admin::TopicsController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::Topics

  activate_menu :buyers, :forum, :my_threads
end
