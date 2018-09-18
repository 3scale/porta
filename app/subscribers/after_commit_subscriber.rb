class AfterCommitSubscriber

  class AfterCommitCallback

    attr_reader :event, :subscriber

    def initialize(event, subscriber)
      @event      = event
      @subscriber = subscriber
    end

    def committed!(*)
      event.try(:after_commit)

      subscriber.after_commit(event)
    end

    def rolledback!(*)
      event.try(:after_rollback)

      subscriber.after_rollback(event)
    end

    def has_transactional_callbacks?
      true
    end

    delegate :logger, to: :Rails
  end

  # @param [AfterCommitEvent] event
  def call(event)
    callback = AfterCommitCallback.new(event, self)

    if transaction_open? && transaction_not_finalized?
      connection.add_transaction_record(callback)
    else
      callback.committed!
    end
  end

  def after_commit(event)
  end

  def after_rollback(event)
  end

  delegate :connection, to: 'ActiveRecord::Base'

  private

  def transaction_open?
    connection.try! :transaction_open?
  end

  def transaction_not_finalized?
    !connection.current_transaction.state.finalized?
  end
end
