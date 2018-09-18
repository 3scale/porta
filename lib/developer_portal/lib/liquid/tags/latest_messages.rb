module Liquid
  module Tags

    class LatestMessages < Liquid::Tags::Base

      example "Using latest_messages tag liquid", %{
         {% latest_messages %}
      }

      desc "Renders a HTML snippet with the latest messages for the user."
      def render(context)
        render_erb context, "developer_portal/dashboards/components/latest_messages"
      end

    end

  end
end
