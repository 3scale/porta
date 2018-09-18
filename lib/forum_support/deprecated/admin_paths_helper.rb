module Forum::AdminPathsHelper

  def forum_home
    admin_forum_path
  end

  def forum_topic_posts(topic)
   admin_forum_topic_posts_path(topic)
  end

  def edit_forum_topic(topic)
   edit_admin_forum_topic_path(topic)
  end

  def new_forum_topic
    new_admin_forum_topic_path
  end

  def forum_topic(topic, options = {})
    admin_forum_topic_path(topic, options)
  end
  alias path_to_forum_topic forum_topic

  def forum_topics
    admin_forum_topics_path
  end

  def show_forum_topic(topic, options)
   admin_forum_topic_path(topic, options)
  end

  def edit_forum_topic_post(topic, post)
    edit_admin_forum_topic_post_path(topic, post)
  end

  def forum_topic_post(post)
    admin_forum_topic_post_path(post.topic, post)
  end

  def delete_forum_topic_post(post)
    admin_forum_topic_post_path(post.topic, post)
  end

end

