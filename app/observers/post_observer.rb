class PostObserver < ActiveRecord::Observer
  observe Post

  include AfterCommitOn

  include System::UrlHelpers.system_url_helpers

  def after_commit_on_create(post)
    account = post.forum.account

    return unless account.provider?

    publish_event!(post)
  end

  private

  def publish_event!(post)
    event = Posts::PostCreatedEvent.create(post)
    Rails.application.config.event_store.publish_event(event)
  end
end
