module Liquid
  module Docs
    module DSL
      module Tags
        include Liquid::Docs::DSL::Base

        Documentation = Struct.new(:name, :info, :deprecated) do
          attr_reader :builder, :examples

          def initialize(*)
            super
            @builder = {}
            @examples = []
          end


          def to_markdown
            pieces = [ "# Tag '#{name}'" , self.info ]

            if deprecated.present?
              pieces << "__DEPRECATED__: #{deprecated}"
            end

            @examples.each do |e|
              pieces << e.to_markdown
            end

            pieces.compact.join("\n\n")
          end
        end

        def deprecated(why)
          documentation.deprecated = why
        end

        def nodoc!
          # ignore
        end

        def tag(name = nil)
          if name.present?
            # set
            @name = name
          else
            # get
            @name or self.to_s.split("::").last.underscore
          end
        end

        def example(*args)
          documentation.examples << Example.new(*args)
        end

        def info(text)
          documentation.info = text.strip_heredoc
        end

        alias desc info

        def documentation
          @documentation ||= Documentation.new(self.tag, @info)
        end

        private
      end
    end
  end
end
