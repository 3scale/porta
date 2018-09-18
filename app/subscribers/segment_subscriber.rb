class SegmentSubscriber

  def initialize(name)
    @method = method(name)
    freeze
  end

  def call(event)
    @method.call(event)
  end

  # @param [Accounts::AccountDeletedEvent] event
  def account_deleted(event)
    account = Account.new({ id: event.account_id, provider: !event.buyer }, without_protection: true)
    user = User.new({id: event.user_id, account: account }, without_protection: true)

    deleted = { state: 'deleted' }.freeze
    user_tracking = ThreeScale::Analytics.user_tracking(user,
                                                        basic_traits: deleted,
                                                        group_traits: deleted)
    return unless user_tracking.can_send?

    user_tracking.track('Account Deleted')
    user_tracking.group
  end
end
