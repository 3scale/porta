class Forums::Public::ForumsController < FrontendController
  self.builtin_template_scope = 'forum/forums'

  include ForumSupport::Public
  include ForumSupport::Forums

end
