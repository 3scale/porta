module Liquid
  module Docs
    extend ActiveSupport::Concern

    included do
      extend DSL
      extend Help
    end

    # These classes are for parts of documentation.
    # Like Heading, Text, Method (with description), Example
    #
    # Now they implement #to_markdown method so they can be easily converted to markdown.
    # In the future we can generate anything from it.
    #
    # Markdown can be really sensitive to new lines, so plenty of objects add "\n" to output
    # But don't do too much, because it would create blank paragraphs.

    class Lines
      attr_reader :items

      delegate :<<, :push, :each, :unshift, :to => :@items

      include Enumerable

      def initialize(*items)
        @items = items.flatten
      end

      def to_markdown
        items.compact.map{|item| item.respond_to?(:to_markdown) ? item.to_markdown : Text.new(item) }.join("\n")
      end
    end

    class Text < String
      def initialize(str)
        super(str.strip_heredoc.strip + "\n")
      end

      alias to_markdown to_s

    end

    class Method
      def initialize(name, options)
        @name = Heading.new(name, 2)
        @descriptions = Description.new options[:descriptions]
        @deprecated = options[:deprecated].presence

        if examples = options[:examples].presence
          @examples = Lines.new( Heading.new("Examples", 3), examples )
        end
      end

      def to_markdown
        Lines.new(@name, @deprecated, @descriptions, @examples).to_markdown
      end
    end

    class Heading
      delegate :to_s, :to => :@text

      def initialize(text, level)
        @text = text
        @level = level
      end

      def to_markdown
        Text.new("#{'#'*@level} #{@text}")
      end
    end

    class Description
      def initialize(*messages)
        @messages = messages.flatten
      end

      def to_markdown
        if @messages.present?
          Lines.new(@messages).to_markdown
        else
          Text.new('No description')
        end
      end
    end

    class Deprecated
      def initialize(message)
        @message = message
      end

      def to_markdown
        Text.new("This method is **deprecated**.  \n" + @message)
      end
    end

    class Code
      def initialize(text)
        @text = Text.new(text).strip
      end

      def to_markdown
        ['```', @text, '```', nil].join("\n")
      end
    end

  end
end
