require 'test_helper'

class Liquid::Drops::SearchTest < ActiveSupport::TestCase

  def setup
    @topic = FactoryBot.create(:topic, title: 'RIP')
    @post = FactoryBot.create(:post, body: 'Can we delete the forum, please?', topic: @topic)
  end

  test 'post found' do
    search = stub(search_results: [ @post ], results: [ @post ])
    drop = Liquid::Drops::Search.new(search)
    assert_equal '/forum/topics/rip', drop.results[0].url
  end

  test 'topic found' do
    search = stub(search_results: [ @topic ], results: [ @topic ])
    drop = Liquid::Drops::Search.new(search)
    assert_equal '/forum/topics/rip', drop.results[0].url
  end

end
