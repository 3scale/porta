module Liquid
  module Filters
    module GoogleAnalytics
      include Liquid::Filters::Base

      def embed_google_tracker(code)
        return '<!-- Google Tracker code not present: set it in /admin/site/settings/edit -->' unless code.present?

        "<script type=\"text/javascript\">
            var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");
            document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));
          </script>
          <script type=\"text/javascript\">
            try {
              var pageTracker = _gat._getTracker(\"#{code}\");
              pageTracker._trackPageview();
            } catch(err) {}
         </script>"
      end
    end
  end
end
