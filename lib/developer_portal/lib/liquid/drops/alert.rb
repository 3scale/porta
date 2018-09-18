module Liquid
  module Drops
    class Alert < Drops::Model
      drop_example "Using alert drop in liquid.", %{
        <h1>Alert details</h1>
        <div>Level {{ alert.level }}</div>
        <div>Message {{ alert.message }}</div>
        <div>Utilization {{ alert.utilization }}</div>
      }

      allowed_name :alert, :alerts

      privately_include do
        include AlertsHelper
      end

      # TODO: grab the level dynamically
      desc "The alert level can be 50, 80, 90, 100, 120, 150, 200, or 300."
      def level
        @model.level
      end

      desc "Text message describing the alert, for example 'SMS check status per minute: 5 of 5'."
      def message
        @model.friendly_message
      end

      desc "Decimal number marking the actual utilization that triggered the alert (1.0 is equal to 100%)."
      example %{
        Used by {{ alert.utilization | times: 100 }} percent.
      }
      def utilization
        @model.utilization
      end

      hidden

      desc "Timestamp of the alert."
      def timestamp
        @model.timestamp
      end

      desc "Whether the alert has been read or not (boolean)"
      def unread?
        @model.unread?
      end

      desc "The current state of the alert ('unread', 'read' or 'deleted')"
      def state
        @model.state
      end

      desc "The URL that marks the alert as read"
      example %{
        {{ 'Read' | update_button: alert.read_alert_url, class: 'mark-as-read', disable_with: 'Marking...', title: 'Mark as read' }}
      }
      def read_alert_url
        read_admin_application_alert_path(@model.cinstance, @model)
      end

      desc "A dom-friendly level identifier of the alert, for example 'above-100'"
      def dom_level
        "above-#{utilization_range(@model.level)}"
      end

      desc "The formatted utilization level of the alert, for example '≥ 100 '"
      def formatted_level
        format_utilization(@model.level)
      end

      desc "The URL that deletes the alert"
      example %{
        {{ '<i class="fa fa-trash"></i>' | html_safe | link_to:  alert.delete_alert_url, title: 'Delete alert', method: 'delete' }}
      }
      def delete_alert_url
        admin_application_alert_path(@model.cinstance, @model)
      end
    end
  end
end
