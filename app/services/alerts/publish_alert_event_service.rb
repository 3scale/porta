class Alerts::PublishAlertEventService

  attr_reader :alert

  def self.run!(alert)
    new(alert).publish_event!
  end

  def initialize(alert)
    @alert = alert
  end

  def publish_event!
    event = event_class.create(alert)

    Rails.application.config.event_store.publish_event(event)
  end

  private

  def event_class
    event_class_name.constantize
  end

  def event_class_name
    "alerts/limit_#{alert.kind}_reached_#{account_type}_event".classify
  end

  def account_type
    am_i_buyer? ? :buyer : :provider
  end

  def am_i_buyer?
    alert.account.id == alert.cinstance.buyer_account.id
  end
end
