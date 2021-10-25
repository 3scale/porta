# frozen_string_literal: true
module Liquid
  module Tags
    class CdnAsset < Liquid::Tags::Base

      attr_reader :file

      example 'Using cdn_asset tag in liquid', " %{ cdn_asset '/swagger/2.1.3/swagger.js' %} "

      # {% cdn_asset /swagger-ui/2.2.10/swagger-ui.js %}        => loads '/swagger-ui/2.2.10/swagger-ui.js' from 3scale CDN
      # {% cdn_asset /swagger-ui/2.2.10/swagger-ui.min.js %}    => loads '/swagger-ui/2.2.10/swagger-ui.min.js' from 3scale CDN
      # {% cdn_asset /swagger-ui/2.2.10/swagger-ui.css %}       => loads '/swagger-ui/2.2.10/swagger-ui.css' from 3scale CDN

      def initialize(tag_name, file, tokens)
        super
        @file = File.join(cdn_host, file).strip # strip because we are allowing the path not enclosed between quotes
      end

      desc %{
        Provides the desired asset file.

        The assets you can use here are limited to:

        Font Awesome:
        - font-awesome/4.3.0/css/font-awesome.css
        - font-awesome/4.3.0/css/font-awesome.min.css

        jQuery 1.11.4:
        - jquery-ui/1.11.4/jquery-ui.css
        - jquery-ui/1.11.4/jquery-ui.min.js

        jQuery 3.5.0:
        - jquery/3.5.0/jquery.min.js
      }

      def render(context)
        action_view = context.registers[:controller].view_context
        case Pathname.new(@file).extname
        when '.css'
          action_view.stylesheet_link_tag @file
        when '.js'
          action_view.javascript_include_tag @file
        else
          raise SyntaxError, 'should be a JS or CSS file'
        end

      end

      private

      def cdn_host
        hosted_cdn = Rails.configuration.three_scale.assets_cdn_host
        hosted_cdn ? hosted_cdn : '/_cdn_assets_'
      end
    end
  end
end
