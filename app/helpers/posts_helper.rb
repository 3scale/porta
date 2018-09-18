module PostsHelper
  def display_author_name(post)
    name = if post.user.nil? || post.anonymous_user?
             "Anonymous User"
           else
             post.user.display_name
           end

    h(truncate(name, :length => 30))
  end
end
