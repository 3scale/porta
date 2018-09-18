module Liquid
  module Drops
    class Request < Drops::Base
      allowed_name :request

      drop_example "Using request drop in liquid.", %{
        <h1>Request details</h1>
        <div>URI {{ request.request_uri }}</div>
        <div>Host {{ request.host }}</div>
        <div>Host and port {{ request.host_with_port }}</div>
      }

      def initialize(request)
        @request = request
      end

      # http://stackoverflow.com/questions/2165665/how-do-i-get-the-current-url-in-ruby-on-rails/17426958#answer-17426958
      desc "Returns the URI of the request."
      def request_uri
        @request.original_url
      end

      desc "Returns the host with port of the request."
      def host_with_port
        @request.host_with_port
      end

      desc "Returns the host part of the request URL."
      def host
        @request.host
      end

      desc "Returns the path part of the request URL."
      example """
       {% if request.path == '/' %}
         Welcome on a landing page!
       {% else %}
         This is just an ordinary page.
       {% endif %}
       """
      def path
        @request.path
      end
    end
  end
end
