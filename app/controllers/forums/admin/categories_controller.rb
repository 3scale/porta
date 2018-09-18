class Forums::Admin::CategoriesController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::Categories

  activate_menu :buyers, :forum
end
