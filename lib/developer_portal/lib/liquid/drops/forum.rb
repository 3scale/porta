module Liquid
  module Drops
    class Forum < Drops::Base
      allowed_name :forum

      def initialize(provider)
        @provider = provider
      end

      desc "Returns true if you have forum functionality enabled."
      example %{
        {% if forum.enabled? %}
          <a href="/forum">Check out our forum!</a>
        {% endif %}
      }
      def enabled?
        @provider.settings.forum_enabled?
      end

      def latest_posts
        # TODO: use standard drop collection wrapper
        @latest ||= @provider.forum.latest_posts.limit(5)
        ::Liquid::Drops::Post.wrap(@latest)
      end
    end
  end
end
