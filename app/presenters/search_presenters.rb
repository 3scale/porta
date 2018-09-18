module SearchPresenters
  class SearchAbstractPresenter
    MAX_MATCHES = 1_000

    DEFAULT_PER_PAGE = 7
    MAX_PER_PAGE = 20

    #this class groups common behaviour but it lack the search itself
    def initialize(params, request, tenant_id)
      @params = params
      @request = request
      @tenant_id = tenant_id
    end

    def search_token
      ThinkingSphinx::Query.escape(@params[:q].presence || ''.freeze)
    end

    def total_found
      @total_found ||= search.context[:total_found] || 0
    end

    def search_results
      search
    end

    def search_path
      @request.path
    end

    def search
      @search ||= sphinx
    end

    def options
      default_options
    end

    def default_options
      {
        :with => { :tenant_id => @tenant_id },
        :page => page, :per_page => per_page,
        :star => @params[:star].present?,
        :retry_stale => 1 # this should prevent nil results
      }
    end

    def page
      params_page = @params[:page].to_s.to_i

      if params_page.zero?
        1
      elsif per_page * params_page > MAX_MATCHES
        (MAX_MATCHES / per_page).to_i
      else
        params_page
      end
    end

    def per_page
      param = @params.fetch(:per_page, DEFAULT_PER_PAGE).presence.try(:to_i)

      [ param || DEFAULT_PER_PAGE, MAX_PER_PAGE ].min
    end

    def as_json(options = {})
      # this mutates sphinx options, but there is no other way around :(
      search_results.options[:excerpt_options] = { :limit => 100 }

      search_results.map do |result|
        SearchResult.new(self, result).as_json(options)
      end
    end

    def highlight object
      Highlighter.new(search, object)
    end

    def sphinx
      @sphinx ||= ThinkingSphinx.search(search_token, options)
    end

  end

  class Highlighter
    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods

    # @param [ThinkingSphinx::Search] search
    # @param [ActiveRecord::Base] object
    def initialize(search, object)
      @object = object
      @index = search.context.configuration.indices.find { |index| index.model == @object.class }
      @excerpter = ThinkingSphinx::Excerpter.new(@index.try(:name), search.query)
    end

    def method_missing(method, *args, &block)
      value = @object.public_send(method, *args, &block)

      value = @excerpter.excerpt!(value) if @excerpter.index

      sanitize(value, tags: %w(span), attributes: %w(class))
    end
  end

  class SearchResult
    def initialize(presenter, result)
      @presenter, @result = presenter, result
    end

    def as_json(options)
      case @result
      when CMS::Page
        {:title => @presenter.highlight(@result).name, :path => @result.path, :content => @presenter.highlight(@result).content }
      when Topic
        nil # we dont care about these now
      end
    end
  end

  class IndexPresenter < SearchAbstractPresenter
    def item
      'document'
    end

    def options
      super.merge(:classes => [Topic, CMS::Page])
    end

    def search
      super

      # We do not want to display pages not accessible by the user
      @rejected ||= @search.select do |result|
        result.is_a?(CMS::Page) && !result.accessible_by?(User.current.try!(:account))
      end

      # and now delete the rejected ones from the search
      # if you figure out how to make Array drop elements and return the rejected ones,
      # I'll buy you a beer.
      Array(@rejected).each(&@search.context[:results].method(:delete))

      @search.context[:total_found] = @search.total_entries - @rejected.size if @search.present? && @search.to_a
      @search
    end
  end

  class ForumPresenter < SearchAbstractPresenter
    def item
      'forum document'
    end

    def options
      super.merge(:classes => [Topic])
    end
  end

end
