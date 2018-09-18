class Forums::Admin::PostsController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::Posts

  activate_menu :buyers, :forum
end
