# frozen_string_literal: true

module Liquid
  module Tags
    class EssentialAssets < Liquid::Tags::Base
      deprecated 'This is outdated and should not be use anymore.'

      # This exists for backwards compatibility. Some very old dev portals may still be using tag
      # {% essential_assets %} and thus loading old libraries and overriding our updates.
      def render(context); end
    end
  end
end
