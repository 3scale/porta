# -*- coding: utf-8 -*-
module Liquid
  module Docs
    module DSL
      module Drops
        include Base

        attr_reader :documentation

        class DropMethod < DocumentedMethod
          def to_markdown
             [ "### #{name}", description.try(:strip_heredoc), example.try(:to_markdown) ].compact.join("\n")
          end
        end

        Documentation = Struct.new(:name, :allowed_names, :info, :methods, :example) do
          attr_reader :builder

          def initialize(*)
            super
            self.methods = []
            @builder = {}
          end

          def add_method(name)
            return if [ :eql?, :==, :hash ].include?(name.to_sym)

            # replace an overrided method or add a new one
            if i = methods.find_index { |m| m.name == name }
              self.methods[i] = DropMethod.new(name, @builder)
            else
              self.methods << DropMethod.new(name, @builder)
            end

            @builder = {}
          end

          def uri
            "##{name}-drop"
          end


          # Formatted markdown documentation of the drop.
          #
          # Also interpolates '<model>' with the model name (i.e. 'account').
          def to_markdown
            str = <<-EOS
# #{name} drop

#{info}

#{example.try(:to_markdown)}

## Methods
#{methods.map(&:to_markdown).join("\n\n")}

-----------
            EOS

            str.gsub(/<model>/,name.underscore)
          end
        end

        # used just once, consider removing it
        def all_hidden(&block)
          @all_hidden = true
          yield
        ensure
          @all_hidden = nil
        end

        def info(text)
          documentation.info = text
        end

        def drop_example(*args)
          documentation.example = Example.new(*args)
        end

        def documentation
          @documentation ||= begin
                               name = self.to_s.split("::").last
                               Documentation.new(name, allowed_names)
                             end
        end

        private

        def inherited(subclass)
          super

          documentation.methods.each do |method|
            subclass.documentation.methods << method
          end


          # TODO
          # put all methods that super-class has to the child's docs
          # child.documentation.push *documentation.select{ |doc| doc.is_a?(Liquid::Docs::Method) }
        end
      end
    end
  end
end
