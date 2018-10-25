class Forums::Admin::ForumsController < FrontendController
  include ForumSupport::Admin
  include ForumSupport::Forums

  activate_menu :buyers, :forum, :threads
end
