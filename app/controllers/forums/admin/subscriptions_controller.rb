class Forums::Admin::SubscriptionsController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::UserTopics

  activate_menu :buyers, :forum
end
