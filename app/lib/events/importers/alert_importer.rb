require_dependency 'events/importers/base_importer'

module Events
  module Importers
    class AlertImporter < BaseImporter
      def save!
        return unless cinstance

        provider = service.account
        buyer    = cinstance.user_account

        provider_alert = new_alert(provider)
        buyer_alert    = new_alert(buyer)

        provider_alert.save! if check_levels?(:web_provider)
        buyer_alert.save!    if check_levels?(:web_buyer)

        if check_levels?(:email_provider) && cinstance.live?
          send_email(provider_alert)
          publish_events(provider_alert)
        end

        if check_levels?(:email_buyer) && cinstance.live?
          send_email(buyer_alert)
          publish_events(buyer_alert)
        end

        notify_segment if is_master_event? && notify_provider?
      end

      private

      def notify_provider?
        check_levels?(:email_provider) || check_levels?(:web_provider)
      end

      def notify_segment
        user = cinstance.user_account.admins.first

        unless user
          Rails.logger.error "Can't notify alert import because contract #{cinstance.id} does not have user"
          return
        end

        ThreeScale::Analytics.track(user, 'Alert'.freeze, properties)
      end

      def properties
        {
          alert_id:    object.id,
          level:       object.utilization,
          utilization: object.max_utilization,
          message:     object.limit,
          timestamp:   object.timestamp,
        }
      end

      def new_alert(account)
        ::Alert.new properties.merge(cinstance: cinstance, account: account, service_id: cinstance.service.try!(:id))
      end

      class InvalidAlertError < StandardError
        include Bugsnag::MetaData

        def initialize(alert)
          self.bugsnag_meta_data = {
            alert: {
              attributes: alert.attributes,
              errors:     alert.errors.messages
            }
          }
        end
      end

      def send_email(alert)
        if alert.valid?
          AlertMessenger.limit_message_for(alert).deliver
        else
          error = InvalidAlertError.new(alert)
          System::ErrorReporting.report_error(error)
          Rails.logger.info("unable to notify about alert, because it was invalid: '#{alert.inspect}'")
        end
      rescue Liquid::SyntaxError => error
        error.extend(Bugsnag::MetaData)
        error.bugsnag_meta_data = {
          alert: alert.as_json(root: false)
        }
        System::ErrorReporting.report_error(error)
      end

      def publish_events(alert)
        Alerts::PublishAlertEventService.run!(alert) if alert.persisted?
      end

      def check_levels?(level_type)
        settings[level_type] && settings[level_type].include?(object.utilization)
      end

      def settings
        @settings ||= (service.notification_settings || {}).symbolize_keys
      end

    end
  end
end

