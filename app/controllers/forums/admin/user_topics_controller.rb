class Forums::Admin::UserTopicsController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::UserTopics

  activate_menu :buyers, :forum
end
