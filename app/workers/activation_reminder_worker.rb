class ActivationReminderWorker
  include Sidekiq::Worker

  THREE_DAYS = 72.hours.freeze

  def self.enqueue(user)
    perform_in(THREE_DAYS, user.id)
  end

  def perform(user_id)
    user = User.find(user_id)

    if user.pending?
      ProviderUserMailer.activation_reminder(user).deliver_now
    end
  rescue ActiveRecord::RecordNotFound
    # nothing, user was deleted
  end
end
