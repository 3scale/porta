require 'test_helper'

class Liquid::Drops::PostTest < ActiveSupport::TestCase

  test 'body and url' do
    topic = FactoryBot.create(:topic, title: 'IMPORTANT')
    post = FactoryBot.create(:post, body: 'very good point', topic: topic)
    drop = ::Liquid::Drops::Post.new(post)

    assert_equal 'very good point', drop.body
    assert_equal "/forum/topics/important#post_#{post.id}", drop.url
  end
end
