class Forums::Admin::TopicsController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::Topics

  activate_menu :buyers, :forum, :threads
end
