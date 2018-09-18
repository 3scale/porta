module Liquid
  module Tags

    class LatestForumPosts < Liquid::Tags::Base

      deprecated 'Use `forum` drop instead.'

      example "Using latest_forum_posts tag liquid", %{
         {% latest_forum_posts %}
      }

      desc "An HTML table with latest forum posts."
      def render(context)
        render_erb context, "developer_portal/dashboards/components/latest_forum_posts"
      end

    end

  end
end
