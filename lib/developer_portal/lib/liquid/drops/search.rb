# encoding: UTF-8

module Liquid
  module Drops
    class Search < Drops::Model

      allowed_name :search

      example %{
        <h2>{{ search.token }}</h2>
        <p>found on {{ search.total_found }} {{ search.item | pluralize }} </p>
        <dl>
          {% for result in search.results %}
            <dt>
              <span class="kind"> [ {{ result.kind | capitalize}} ] </span>
              {{ result.title | link_to: result.url }}
            </dt>
            <dd>
              {{ result.description }}
            </dd>
          {% endfor %}
        </dl>
      }

      def initialize(presenter)
        @presenter = presenter
        super
      end

      desc "Returns the searched string."
      def query
        @presenter.search_token
      end

      desc "Returns the number of matching elements."
      def total_found
        @presenter.total_found
      end

      desc "Returs an array of results for the search."
      def results
        @presenter.search_results.compact.map do |result|
          case result.class.name
          when "CMS::Page"
            Result::Page.new(result, @presenter)
          when "Topic"
            Result::Topic.new(result, @presenter)
          when "Post"
            Result::Post.new(result, @presenter)
          end
        end
      end

      module Result
        class Base < Drops::Model

          def initialize(result, presenter)
            @result = result
            @presenter = presenter
          end

          desc "Returns the title of result."
          def title; end

          desc "Returns the kind of result; can be 'topic' or 'page'."
          def kind; end

          desc "Returns the resource URL of the result."
          def url; end

          desc "Returns a descriptive string for the result."
          def description; end

          private

          def highlight(object = nil)
            @presenter.highlight(object || @result)
          end
        end

        class Post < Base
          def title
            highlight(@result.topic).title
          end

          def kind
            "post"
          end

          def url
            "/forum/topics/#{@result.topic.to_param}"
          end

          def description
            highlight.body
          end
        end

        class Topic < Base

          def title
            highlight.title
          end

          def kind
            "topic"
          end

          def url
            "/forum/topics/#{@result.to_param}"
          end

          def description
           "#{ highlight(@result.forum).name } &ndash; #{ highlight.title }".html_safe
          end
        end

        class Page < Base
          def title
            highlight.title
          end

          def kind
            "page"
          end

          def url
            @result.path
          end

          def description
            highlight.content
          end
        end
      end
    end
  end
end
