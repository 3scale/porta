module Liquid
  module Docs
    module DSL
      module Filters
        include Liquid::Docs::DSL::Base

        class FilterMethod < DocumentedMethod
          def to_markdown
            [ "## #{name} filter",
              description.try(:strip_heredoc),
              example.try(:to_markdown)
            ].compact.join("\n")
          end
        end

        Documentation = Struct.new(:category, :filters) do
          attr_reader :builder

          def initialize(category)
            super
            self.category = category
            self.filters = []
            @builder = {}
          end

          def add_method(name)
            self.filters << FilterMethod.new(name, @builder)
            @builder = {}
          end

          def to_markdown
            <<-EOS
# #{category} filters

#{filters.map(&:to_markdown).join("\n\n")}
-----------
            EOS
          end
        end

        def documentation
          @documentation ||= begin
                               category = if self == Liquid::Filters::RailsHelpers
                                            'Common'
                                          else
                                            self.to_s.split("::").last
                                          end

                               Documentation.new(category)
                             end
        end

        private

        def method_added(name)
          super
          return unless public_method_defined?(name)
          documentation
        end
      end
    end
  end
end
