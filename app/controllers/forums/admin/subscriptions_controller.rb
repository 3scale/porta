class Forums::Admin::SubscriptionsController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::UserTopics

  activate_menu :buyers, :forum
end
