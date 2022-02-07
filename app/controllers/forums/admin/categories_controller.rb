class Forums::Admin::CategoriesController < Forums::Admin::HidenForumController
  include ForumSupport::Admin
  include ForumSupport::Categories

  activate_menu :buyers, :forum, :categories
end
