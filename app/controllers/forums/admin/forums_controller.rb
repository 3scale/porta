class Forums::Admin::ForumsController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::Forums

  activate_menu :buyers, :forum, :threads
end
