module TestHelpers
  module ApiPagination
    extend ActiveSupport::Concern

    included do
      # need to set it back on teardown if it was modified
      teardown(:reset_pagination_config!)
    end

    def set_api_pagination_max_per_page(opts)
      config = @previous_pagination_config = {}

      Admin::Api::BaseController.class_eval do
        config[:per_page_range] = self.per_page_range
        config[:default_per_page] = self.default_per_page

        self.per_page_range = 1..opts[:to]
        self.default_per_page = opts[:to]
      end

      opts[:to]
    end

    def reset_pagination_config!
      config = @previous_pagination_config
      return unless config

      Admin::Api::BaseController.class_eval do
        config.each_pair do |key, value|
          self.send("#{key}=", value)
        end
      end
    end

  end
end
