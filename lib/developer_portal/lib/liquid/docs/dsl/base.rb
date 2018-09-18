module Liquid
  module Docs
    module DSL
      module Base

        DocumentedMethod = Struct.new(:name, :description, :example, :deprecated) do
          def initialize(name, builder)
            self.name = name
            self.description = builder[:description]
            self.example = builder[:example]
            self.deprecated = builder[:deprecated]
          end
        end

        Example = Struct.new(:title, :text) do
          def initialize(*args)
            if args.length == 2
              self.title = args.first.strip
              self.text = args.last.strip_heredoc.strip
            elsif args.length == 1
              self.title = nil
              self.text = args.first.strip_heredoc.strip
            else
              raise 'Example.new can only take 1 or 2 parameters.'
            end
          end

          def to_markdown
            code = "```liquid\n#{self.text}\n```"

            if title
              "__Example:__ #{title}\n#{code}"
            else
              code
            end
          end
        end

        def hidden
          @hidden = true
        end

        def deprecated(message)
          documentation.builder[:deprecated] = true
        end

        def desc(text)
          documentation.builder[:description] = text
        end

        def example(*args)
          documentation.builder[:example] = Example.new(*args)
        end

        private

        # Adds method with description and example gathered so far and
        # then clears the builder.
        #
        def method_added(name)
          super
          return unless public_method_defined?(name)

          unless @hidden || @all_hidden
            if documentation.respond_to?(:add_method)
              documentation.add_method(name.to_s)
            end
          end

          @hidden = false
        end

      end
    end
  end
end
