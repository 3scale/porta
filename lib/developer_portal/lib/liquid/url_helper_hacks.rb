module Liquid
  module UrlHelperHacks
    # This is the same as the original implementation, except the controller here is accessed
    # through method, not variable. This way it's more hackable.
    def current_page?(options)
      url_string = CGI.unescapeHTML(url_for(options))
      request = controller.request

      request_uri = if url_string.index("?")
        request.request_uri
                    else
        request.request_uri.split('?').first
                    end

      url_string == if url_string =~ /^\w+:\/\//
        "#{request.protocol}#{request.host_with_port}#{request_uri}"
                    else
        request_uri
                    end
    end

    private

    # Semi-hacky way to access controller from within liquid's filters and tags.
    def controller
      @context.registers[:controller]
    end
  end
end
