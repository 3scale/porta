module Liquid
  module Filters
    # DEPRECATED
    module UrlHelpers
      include Liquid::Filters::Base
      include Rails.application.routes.url_helpers

      # TODO: consider allowing more parameters
      desc """
        This filter creates a URL for a message that leads either to inbox or outbox,
        depending on where it comes from.
      """
      def message_url(message)
        admin_messages_outbox_path(message.id)
      end

      private

      def default_url_options
        {}
      end

    end
  end
end
