class UserObserver < ActiveRecord::Observer
  include AfterCommitOn

  def after_commit_on_create(user)
    if user.account
      # probably to ignore master in tests?
      return if user.account.provider_account.nil?

      if user.new_signup?
        if user.account.provider?
          ProviderUserMailer.activation(user).deliver_now
          ActivationReminderWorker.enqueue(user)
        else
          UserMailer.signup_notification(user).deliver_now
        end
      end
    end
  end
end
