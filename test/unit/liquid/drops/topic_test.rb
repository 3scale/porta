require 'test_helper'

class Liquid::Drops::TopicTest < ActiveSupport::TestCase

  test 'title and url' do
    topic = FactoryBot.create(:topic, title: 'IMPORTANT')
    drop = ::Liquid::Drops::Topic.new(topic)

    assert_equal 'IMPORTANT', drop.title
    assert_equal "/forum/topics/important", drop.url
  end
end
