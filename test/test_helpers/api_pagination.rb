module TestHelpers
  class TestVariables
    include Singleton
    attr_reader :previous_pagination_config

    def initialize
      super
      @previous_pagination_config = Concurrent::Hash.new
    end
  end

  module ApiPagination

    extend ActiveSupport::Concern

    included do
      # need to set it back on teardown if it was modified
      teardown(:reset_pagination_config!)
    end

    def test_variables
      ::TestHelpers::TestVariables.instance
    end

    def set_api_pagination_max_per_page(opts)
      config = test_variables.previous_pagination_config

      Admin::Api::BaseController.class_eval do
        config[:per_page_range] = self.per_page_range
        config[:default_per_page] = self.default_per_page

        self.per_page_range = 1..opts[:to]
        self.default_per_page = opts[:to]
      end

      opts[:to]
    end

    def reset_pagination_config!
      config = test_variables.previous_pagination_config
      return if config.blank?

      Admin::Api::BaseController.class_eval do
        config.each_pair do |key, value|
          self.send("#{key}=", value)
        end
      end
    ensure
      config.clear
    end

  end
end
