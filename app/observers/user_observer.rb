class UserObserver < ActiveRecord::Observer
  include AfterCommitOn

  def after_commit_on_create(user)
    if user.account
      # probably to ignore master in tests?
      return if user.account.provider_account.nil?

      return unless user.new_signup? && !user.invitation

      if user.account.provider?
        ProviderUserMailer.activation(user).deliver_later
        ActivationReminderWorker.enqueue(user)
      else
        UserMailer.signup_notification(user).deliver_later
      end
    end
  end
end
