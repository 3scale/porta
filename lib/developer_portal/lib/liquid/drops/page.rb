module Liquid
  module Drops
    class Page < Drops::Model
      allowed_name :page

      def initialize(page)
        @page = page
        super
      end

      example %{
        <title>{{ page.title }}</title>
      }
      desc "Returns the title of the page."
      def title
        @page.title
      end


      example %{
        {% if page.system_name == 'my_page' %}
          {% include 'custom_header' %}
        {% endif %}
      }
      desc "Returns system name of the page."
      def system_name
        @page.system_name.presence
      end

      # example %{
      #  <meta name="description" content="{{ page.description }}"/>
      # }
      # desc "Returns the description of the page"
      # def description
      #   @page.description
      # end

      # desc %{
      #  <meta name="keywords" content="{{ page.keywords }}"/>
      # }
      # desc "Returns the keywords of the page"
      # def keywords
      #   @page.keywords
      # end
    end
  end
end
