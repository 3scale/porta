require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TopicCategoryTest < ActiveSupport::TestCase
  def setup
    @forum = FactoryBot.create(:forum)
  end

  test 'with_topics returns only categories that have at least one topic' do
    category_with_topics    = @forum.categories.create!(:name => 'With topics')
    category_without_topics = @forum.categories.create!(:name => 'Without topics')

    FactoryBot.create(:topic, :forum => @forum, :category => category_with_topics)

    assert @forum.categories.with_topics.include? category_with_topics
    assert !@forum.categories.with_topics.include?(category_without_topics)
  end
end
