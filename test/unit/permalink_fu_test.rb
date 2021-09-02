# frozen_string_literal: true

require 'test_helper'

class PermalinkFuTest < ActiveSupport::TestCase
  DATA = [
    {name: 'This IS a Tripped out title!!.!1  (well/ not really)',
      expected_permalink: 'this-is-a-tripped-out-title-1-well-not-really'},
    {name: '////// meph1sto r0x ! \\\\\\', expected_permalink: 'meph1sto-r0x'},
    {name: 'āčēģīķļņū', expected_permalink: 'acegiklnu'},
    {name: 'LatinзҖҨرقضعم龟绘乐only', expected_permalink: 'latin-only'},
    {name: 'some-)()()-ExtRa!/// .data==?>    to \/\/test', expected_permalink: 'some-extra-data-to-test'}
  ]

  class ForumPermalink < ActiveSupport::TestCase
    test 'forum generates the permalink correctly' do
      DATA.each do |forum_data|
        forum = Forum.new(name: forum_data[:name])
        assert forum.valid?
        assert_equal forum_data[:expected_permalink], forum.permalink
      end
    end

    test 'forum has the right error when permalink is generated empty for invalid characters' do
      forum = Forum.new(name: 'зҖҨ')
      refute forum.valid?
      assert_equal '', forum.permalink
      assert_match /Name must contain latin characters/, forum.errors.full_messages.to_sentence
    end

    test 'forum creates the permalink without repeating it' do
      forum_1, forum_2, forum_3 = FactoryBot.create_list(:forum, 3, name: 'my example')
      assert_equal 'my-example',   forum_1.permalink
      assert_equal 'my-example-2', forum_2.permalink
      assert_equal 'my-example-3', forum_3.permalink
    end

    test 'forum does not check itself for unique permalink' do
      forum_1 = FactoryBot.create(:forum, name: 'my example')
      forum_2 = FactoryBot.build(:forum, name: 'my example', id: forum_1.id)
      assert forum_2.valid?
      assert_equal 'my-example', forum_1.permalink
      assert_equal 'my-example', forum_2.permalink
    end

    test 'forum always auto-generates permalinks and it is never written from the outside' do
      forum = FactoryBot.build(:forum, name: 'my example')

      forum.permalink = 'permalink'
      assert forum.valid?
      assert_equal 'my-example', forum.permalink

      forum.name = 'my name is 危険 foo'
      assert forum.valid?
      assert_equal 'my-name-is-foo', forum.permalink
    end

    test 'forum permalink validates that it contains maximum 255 characters' do
      forum = FactoryBot.build(:forum)

      forum.name = 'a' * 255
      assert forum.valid?

      forum.name = 'a' * 256
      refute forum.valid?
      assert_match /too long/, forum.errors[:permalink].to_sentence
    end
  end

  class TopicPermalink < ActiveSupport::TestCase
    test 'topic generates the permalink correctly' do
      DATA.each do |topic_data|
        topic = FactoryBot.build(:topic, title: topic_data[:name], forum: FactoryBot.create(:forum), user: FactoryBot.create(:simple_user))
        assert topic.valid?
        assert_equal topic_data[:expected_permalink], topic.permalink
      end
    end

    test 'topic has the right error when permalink is generated empty for invalid characters' do
      topic = FactoryBot.build(:topic, title:'зҖҨ', forum: FactoryBot.create(:forum), user: FactoryBot.create(:simple_user))
      refute topic.valid?
      assert_equal '', topic.permalink
      assert_match /Title must contain latin characters/, topic.errors.full_messages.to_sentence
    end

    test 'topic creates the permalink without repeating it under the scope of the forum' do
      forum = FactoryBot.create(:forum)
      topic_1, topic_2, topic_3 = FactoryBot.create_list(:topic, 3, title: 'my example', forum: forum)
      assert_equal 'my-example',   topic_1.permalink
      assert_equal 'my-example-2', topic_2.permalink
      assert_equal 'my-example-3', topic_3.permalink
    end

    test 'topic creates the same permalink if they belong to different forums' do
      topic_1, topic_2 = FactoryBot.create_list(:topic, 2, title: 'my example')
      assert_equal 'my-example', topic_1.permalink
      assert_equal 'my-example', topic_2.permalink
    end

    test 'topic does not check itself for unique permalink' do
      forum = FactoryBot.create(:forum)
      topic_1 = FactoryBot.create(:topic, title: 'my example', forum: forum)
      topic_2 = FactoryBot.build(:topic, title: 'my example', forum: forum, id: topic_1.id, user: FactoryBot.create(:simple_user))
      assert topic_2.valid?
      assert_equal 'my-example', topic_1.permalink
      assert_equal 'my-example', topic_2.permalink
    end

    test 'topic always auto-generates permalinks and it is never written from the outside' do
      topic = FactoryBot.build(:topic, title: 'my example', forum: FactoryBot.create(:forum), user: FactoryBot.create(:simple_user))

      topic.permalink = 'permalink'
      assert topic.valid?
      assert_equal 'my-example', topic.permalink

      topic.title = 'my name is 危険 foo'
      assert topic.valid?
      assert_equal 'my-name-is-foo', topic.permalink
    end

    test 'topic permalink validates that it contains maximum 255 characters' do
      topic = FactoryBot.build(:topic, forum: FactoryBot.create(:forum), user: FactoryBot.create(:simple_user))

      topic.title = 'a' * 255
      assert topic.valid?

      topic.title = 'a' * 256
      refute topic.valid?
      assert_match /too long/, topic.errors[:permalink].to_sentence
    end
  end
end
