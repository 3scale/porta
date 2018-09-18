module Liquid
  module Drops
    class Pagination < Drops::Base
      example %{
      <div class="pagination">
        {% for part in pagination.parts %}
          {% if part.is_link %}
            {% case part.rel %}
            {% when 'previous' %}
              {% assign css_class = 'previous_page' %}
            {% when 'next' %}
              {% assign css_class = 'next_page' %}
            {% else %}
              {% assign css_class = '' %}
            {% endcase %}

            <a class="{{ css_class }}" rel="{{ part.rel}}" href="{{ part.url }}">{{ part.title }}</a>
          {% else %}
            {% case part.rel %}
            {% when 'current' %}
               <em class="current">{{ part.title }}</em>
            {% when 'gap' %}
               <span class="gap">&#x2026;</span>
            {% else %}
               <span>{{ part.title }}</span>
            {% endcase %}
          {% endif %}
        {% endfor %}
      </div>


      <!-- Outputs:
        ============================================
      <div class="pagination">
        <a class="previous_page" rel="prev" href="?page=7">&#x2190; Previous</a>
        <a rel="start" href="?page=1">1</a>
        <a href="?page=2">2</a>
        <a href="?page=3">3</a>
        <a href="?page=4">4</a>
        <a href="?page=5">5</a>
        <a href="?page=6">6</a>
        <a rel="prev" href="?page=7">7</a>
        <em class="current">8</em>
        <a rel="next" href="?page=9">9</a>
        <a href="?page=10">10</a>
        <a href="?page=11">11</a>
        <a href="?page=12">12</a>
        <span class="gap">&#x2026;</span>
        <a href="?page=267">267</a>
        <a href="?page=268">268</a>
        <a class="next_page" rel="next" href="?page=9">Next &#x2192;</a>
      </div>
      =======================================
      -->
      }

      allowed_name :pagination

      # items - a paginated collection
      # url_builder - responds to #url_for (ussualy a controller)
      #
      def initialize(items, url_builder)
        @items = items
        @helper = PartsRenderer.new(items, url_builder)
      end

      desc "Number of items on one full page."
      def page_size
        @items.per_page
      end

      desc "Number of the currently selected page."
      def current_page
        @items.current_page
      end

      # items skipped so far
      desc "Items skipped so far."
      def current_offset
        @items.offset
      end

      desc "Total number of pages."
      def pages
        @items.total_pages
      end

      desc "Total number of items in all pages."
      def items
        @items.total_entries
      end

      desc "Number of the previous page or empty."
      def previous
        @items.previous_page
      end

      desc "Number of the next page or empty."
      def next
        @items.next_page
      end


      desc "Elements that render a user-friendly pagination. See the [part drop](#part-drop) for more information."
      def parts
        @parts ||= @helper.make_parts
      end

      class PartsRenderer < WillPaginate::ViewHelpers::LinkRenderer
        def initialize(items, url_builder)
          super()

          @items = items
          @url_builder = url_builder

          # last parameter is the view but we don't need it as we won't use
          # the helper for rendering
          self.prepare(items, { page_links: true }, nil)
        end

        def make_parts
          pagination.map do |item|
            case item
            when Fixnum
              page_number(item)
            when :previous_page, :next_page
              send(item)
            when :gap
              make_part('…', nil, 'gap')
            end
          end
        end

        protected

        def make_url(options = {})
          @url_builder.url_for(@url_builder.params.merge(options))
        end

        def make_part(title, link = nil, rel = nil)
          Part.new(@items, title, link, rel)
        end

        def previous_page
          if @collection.current_page > 1 && @collection.current_page - 1
            link = make_url(page: @collection.current_page - 1)
            make_part('Previous', link, 'previous')
          else
            make_part('Previous')
          end
        end

        def next_page
          if @collection.current_page < total_pages && @collection.current_page + 1
            link = make_url(page: @collection.current_page + 1)
            make_part('Next', link, 'next')
          else
            make_part('Next')
          end
        end

        def page_number(number)
          if number == @collection.current_page
            make_part(number)
          else
            link = make_url(page: number)

            rel = case number
                  when @items.current_page - 1 then 'prev'
                  when @items.current_page + 1 then 'next'
                  when @items.current_page then 'current'
                  end

            make_part(number, link, rel)
          end
        end
      end
    end

    private

    class Part < Drops::Base
      attr_reader :url, :rel

      def initialize(items, title, url, rel)
        @items = items
        @title = title.to_s
        @url = url
        @rel = rel
      end

      def current?
        @current == true
      end

      def is_link
        @url.present?
      end

      def title
        @title.to_s
      end

      def to_s
        @title.to_s
      end
    end
  end
end
