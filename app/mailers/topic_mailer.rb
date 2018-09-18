class TopicMailer < ActionMailer::Base

  def new_post(subscriber, post)
    @post = post
    @sender = @post.user
    @subscriber = subscriber
    @domain = domain(@post)

    headers({'Return-Path' => from_address(@sender), 'X-SMTPAPI' => '{"category": "New Post"}'})


    mail(:from => from_address(@sender),
         :to =>  [@subscriber.email],
         :subject =>  'New post in topic')
  end

  private

  def domain(post)
    post.forum.account.domain
  end

  def from_address(sender)
    if sender.account.provider?
      sender.account.from_email
    elsif sender.account.provider_account
      sender.account.provider_account.from_email
    end
  end
end
