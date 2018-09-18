class PostObserver < ActiveRecord::Observer
  observe Post

  include AfterCommitOn

  include Rails.application.routes.url_helpers

  def after_commit_on_create(post)
    account = post.forum.account

    return unless account.provider?

    if account.provider_can_use?(:new_notification_system)
      return publish_event!(post)
    end

    message = if user = post.user # normal post
      user.account.messages.build
              else # anonymous post
      post.forum.account.messages.build
              end
    message.to = post.forum.account
    message.subject = 'New Forum Post'
    message.system_operation = SystemOperation.for('new_forum_post')

    (post.topic.subscribers - [user]).each do |subscriber|
      TopicMailer.new_post(subscriber, post).deliver_now unless subscriber.email_unverified?
    end

    url = admin_forum_topic_url(post.topic, host: post.forum.account.self_domain)

    name = user ? user.account.org_name : 'Anonymous User'
    message.body = <<-MSG
#{name} has posted on your forum.

You can check the post here #{url}

The API Team.
    MSG

    message.save!
    message.deliver!
  end

  private

  def publish_event!(post)
    event = Posts::PostCreatedEvent.create(post)
    Rails.application.config.event_store.publish_event(event)
  end
end
