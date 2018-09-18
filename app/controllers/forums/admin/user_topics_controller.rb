class Forums::Admin::UserTopicsController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::UserTopics

  activate_menu :buyers, :forum
end
