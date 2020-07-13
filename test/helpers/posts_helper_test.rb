require 'test_helper'

class PostsHelperTest < ActionView::TestCase
  test '#display_author_name' do
    post_with_known_author = FactoryBot.create(:post)
    assert_equal post_with_known_author.user.decorate.display_name.truncate(30), display_author_name(post_with_known_author)

    post_without_author = Post.new
    assert_equal 'Anonymous User', display_author_name(post_without_author)

    post_with_anonymous_author = FactoryBot.create(:post, anonymous_user: true)
    assert_equal 'Anonymous User', display_author_name(post_with_anonymous_author)
  end
end
