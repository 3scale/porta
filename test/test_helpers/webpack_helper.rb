# frozen_string_literal: true

module TestHelpers
  module WebpackHelper
    def self.included(base)
      base.setup do
        @controller.view_context_class.class_eval do
          def javascript_packs_with_chunks_tag(*_packs)
            ''.html_safe
          end

          def stylesheet_packs_chunks_tag(*_packs)
            ''.html_safe
          end
        end
      end
    end
  end
end

ActionController::TestCase.include TestHelpers::WebpackHelper
