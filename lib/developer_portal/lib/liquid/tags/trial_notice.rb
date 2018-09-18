module Liquid
  module Tags

    class TrialNotice < Liquid::Tags::Base
      nodoc!

      def render(context)
        render_erb context, "developer_portal/dashboards/components/trial"
      end

    end

  end
end
