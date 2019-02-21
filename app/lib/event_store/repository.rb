# frozen_string_literal: true


module EventStore
  class Repository < Delegator
    include ::ThreeScale::MethodTracing

    attr_reader :client, :facade

    # We don't want to extend the repository with this method.
    # So we are left with using private method to convert persisted record into
    # Event that we originally created.
    #
    # @param [String] event_id
    # @return RailsEventStore::Event

    class_attribute :repository, instance_accessor: false
    class_attribute :raise_errors, instance_accessor: false

    self.raise_errors = Rails.env.development?
    self.repository = RailsEventStoreActiveRecord::EventRepository.new(adapter: EventStore::Event)

    class << self
      delegate :adapter, to: :repository
    end

    def self.find_event(event_id)
      build_entity adapter.find_by(event_id: event_id)
    end

    def self.find_event!(event_id)
      build_entity adapter.find_by!(event_id: event_id)
    end

    # @param [RailsEventStoreActiveRecord::Event] event_record
    # @return [RailsEventStore::Event]
    def self.build_entity(event_record)
      repository.method(:build_event_entity).call(event_record)
    end

    class EventBroker < RailsEventStore::EventBroker
      delegate :logger, to: :Rails

      def notify_subscribers(event)
        logger.info("[EventBroker] notifying subscribers of #{event.class} #{event.event_id}")
        super
      end
    end

    class Facade < RubyEventStore::Facade
      delegate :logger, to: :Rails
      delegate :raise_errors, to: 'EventStore::Repository'

      class InvalidEventError < StandardError
        include Bugsnag::MetaData

        def initialize(event)
          return super unless event

          self.bugsnag_meta_data = {
            event: {
              event_id: id = event.event_id,
              name:     name = event.class.name,
              data:     event.data,
              metadata: event.metadata
            }
          }

          super "Event #{name} #{id} is invalid"
        end
      end

      def publish_event(event, stream_name = RubyEventStore::GLOBAL_STREAM, expected_version = :any)
        logger.debug { "[EventStore] publishing #{event.class} #{event.event_id}" } if event

        append_to_stream(stream_name, event, expected_version)
        event_broker.notify_subscribers(event)

        :ok
      rescue => exception
        raise if raise_errors
        System::ErrorReporting.report_error(exception)
        logger.error([exception, exception.backtrace].join("\n\t"))
        false
      end

      def append_to_stream(stream_name, event, expected_version = :any)
        validate_expected_version(stream_name, expected_version)

        create_event!(event, stream_name)
      end

      def create_event!(event, stream_name)
        data = event.to_h.merge!(stream: stream_name, event_type: event.class.name)

        if repository.adapter.create(data).valid?
          event
        else
          raise InvalidEventError, event
        end
      end
    end

    def initialize(repository = self.class.repository, event_broker = EventBroker.new)
      @client = ::RailsEventStore::Client.new(repository: repository, event_broker: event_broker)
      @facade = Facade.new(repository, event_broker)

      @client.subscribe_to_all_events(AfterCommitSubscriber.new)

      # applications/cinstances
      subscribe_for_notification(:application_created, Applications::ApplicationCreatedEvent)
      subscribe_for_notification(:cinstance_cancellation, Cinstances::CinstanceCancellationEvent)
      subscribe_for_notification(:cinstance_expired_trial, Cinstances::CinstanceExpiredTrialEvent)
      subscribe_for_notification(:cinstance_plan_changed, Cinstances::CinstancePlanChangedEvent)
      subscribe_for_notification(:application_plan_change_requested, Applications::ApplicationPlanChangeRequestedEvent)
      # accounts
      subscribe_for_notification(:account_created, Accounts::AccountCreatedEvent)
      subscribe_for_notification(:account_deleted, Accounts::AccountDeletedEvent)
      subscribe_for_notification(:account_plan_change_requested, Accounts::AccountPlanChangeRequestedEvent)
      subscribe_for_notification(:account_state_changed, Accounts::AccountStateChangedEvent)
      subscribe_for_notification(:expired_credit_card_provider, Accounts::ExpiredCreditCardProviderEvent)
      # alerts
      subscribe_for_notification(:limit_violation_reached_provider, Alerts::LimitViolationReachedProviderEvent)
      subscribe_for_notification(:limit_alert_reached_provider, Alerts::LimitAlertReachedProviderEvent)
      # invoices
      subscribe_for_notification(:unsuccessfully_charged_invoice_provider, Invoices::UnsuccessfullyChargedInvoiceProviderEvent)
      subscribe_for_notification(:unsuccessfully_charged_invoice_final_provider, Invoices::UnsuccessfullyChargedInvoiceFinalProviderEvent)
      subscribe_for_notification(:invoices_to_review, Invoices::InvoicesToReviewEvent)
      # service contracts
      subscribe_for_notification(:service_contract_cancellation, ServiceContracts::ServiceContractCancellationEvent)
      subscribe_for_notification(:service_contract_created, ServiceContracts::ServiceContractCreatedEvent)
      subscribe_for_notification(:service_contract_plan_changed, ServiceContracts::ServiceContractPlanChangedEvent)
      # plans
      subscribe_for_notification(:plan_downgraded, Plans::PlanDowngradedEvent)
      # messages
      subscribe_for_notification(:message_received, Messages::MessageReceivedEvent)
      # posts
      subscribe_for_notification(:post_created, Posts::PostCreatedEvent)
      # reports
      subscribe_for_notification(:csv_data_export, Reports::CsvDataExportEvent)
      # services
      subscribe_for_notification(:service_deleted, Services::ServiceDeletedEvent)
      subscribe_for_notification(:service_plan_change_requested, Services::ServicePlanChangeRequestedEvent)

      subscribe_event(SegmentSubscriber.new(:account_deleted), Accounts::AccountDeletedEvent)
      subscribe_event(PublishZyncEventSubscriber.new,
                      Applications::ApplicationCreatedEvent,
                      Applications::ApplicationUpdatedEvent,
                      Applications::ApplicationDeletedEvent,
                      Applications::ApplicationEnabledChangedEvent,
                      OIDC::ProxyChangedEvent,
                      OIDC::ServiceChangedEvent
                     )
      subscribe_event(ServiceTokenEventSubscriber.new, ServiceTokenDeletedEvent)
      subscribe_event(ServiceDeletionSubscriber.new, Services::ServiceScheduledForDeletionEvent)
      subscribe_event(ServiceDeletedSubscriber.new, Services::ServiceDeletedEvent)
      subscribe_event(ZyncSubscriber.new, ZyncEvent)
    end

    delegate :publish_event, to: :facade

    add_three_scale_method_tracer :publish_event, 'EventStore/publish_event'

    protected

    delegate :logger, to: :Rails

    attr_reader :client

    alias __getobj__ client

    private

    def subscribe_event(subscriber, *event_classes)
      client.subscribe(subscriber, event_classes.flatten)
    end

    def subscribe_for_notification(name, event_class)
      client.subscribe(PublishNotificationEventSubscriber.new(name), [event_class])
    end
  end
end
