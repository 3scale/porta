module UserTopicsHelper
  def link_to_view_my_posts
    url = if current_account.provider? && request.host == current_account.admin_domain
            my_admin_forum_topics_path
          else
            my_forum_topics_path
          end
    link_to_unless_current_styled 'My threads', url
  end
end
