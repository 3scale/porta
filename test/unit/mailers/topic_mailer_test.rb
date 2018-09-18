require 'test_helper'

class TopicMailerTest < ActionMailer::TestCase
  def setup
    @provider  = FactoryGirl.build_stubbed(:provider_account)
    @buyer     = FactoryGirl.build_stubbed(:buyer_account, :provider_account => @provider)
  end

  test 'send mails' do
    sender = FactoryGirl.build_stubbed(:simple_user, account: @provider)
    post =  FactoryGirl.create(:post, user: sender)
    subscriber =  FactoryGirl.build_stubbed(:simple_user, account: @buyer)

    TopicMailer.new_post(subscriber, post).deliver_now
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test 'send from provider' do
    sender =  FactoryGirl.build_stubbed(:simple_user, account: @provider)
    post = FactoryGirl.create(:post, user: sender)
    subscriber = FactoryGirl.build_stubbed(:simple_user, account: @buyer)

    email = TopicMailer.new_post(subscriber, post)
    assert_equal [post.user.account.from_email], email.from
    assert_equal [subscriber.email], email.to
  end

  test 'send from buyer' do
    sender =  FactoryGirl.build_stubbed(:simple_user, account: @buyer)
    post = FactoryGirl.create(:post, user: sender)
    subscriber = FactoryGirl.build_stubbed(:simple_user, account: @buyer)

    email = TopicMailer.new_post(subscriber, post)
    assert_equal [post.user.account.provider_account.from_email], email.from
    assert_equal [subscriber.email], email.to
  end
end
