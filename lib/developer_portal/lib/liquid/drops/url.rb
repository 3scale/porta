module Liquid
  module Drops
    class Url < Drops::Base
      def initialize(url, title = nil, section = nil)
        @url = URI(url)
        @title = title
        @section = section
      end

      def to_s
        to_str
      end

      def to_str
        @url.to_s
      end

      def title
        @title.to_s
      end

      desc """
        True if the path of the current page is the same as this one
        or it's a subpath of it (i.e. extended by ID). For
        example with `{{ urls.messages_outbox }}` these will return true:

         - /admin/sent/messages/sent
         - /admin/sent/messages/sent/42

        But not these:

         - /admin/sent/messsages/new
         - /admin/sent/messsages/received/2

        See also '#active?', '#current?'.
      """

      def current_or_subpath?
        if request = context.registers[:request]
          request.path.start_with?(@url.path)
        else
          false
        end
      end

      desc """
        True if the URL's path is the the same as of the current. Parameters
        and other components are not taken into account. See also '#active?'.
      """
      example """
        {% assign url = urls.messages_inbox %}
        <!-- => http://awesome.3scale.net/admin/messages/sent -->

        <!-- Current page: http://awesome.3scale.net/admin/messages/sent?unread=1 -->
        {{ url.current? }} => true

        <!-- Current page: http://awesome.3scale.net/admin/messages -->
        {{ url.current? }} => false
      """
      def current?
        if request = context.registers[:request]
          request.path == @url.path
        else
          false
        end
      end

      desc """
        True if the current page is in the same menu structure
        as this URL. See also '#current?'.
      """
      example """
        {% assign url = urls.messages_inbox %}
        <!-- => http://awesome.3scale.net/admin/messages/sent -->

        <!-- Current page: http://awesome.3scale.net/admin/messages -->
        {{ url.active? }} => true

        <!-- Current page: http://awesome.3scale.net/admin/messages/trash -->
        {{ url.active? }} => true

        <!-- Current page: http://awesome.3scale.net/admin/stats -->
        {{ url.active? }} => false
      """
      def active?
        if view = context.registers[:view]
          view.current_page?(@url.to_s) || view.active_menu?(:submenu, @title)
        else
          false
        end
      end
    end
  end
end
