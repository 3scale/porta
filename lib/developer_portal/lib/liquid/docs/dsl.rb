# -*- coding: utf-8 -*-
module Liquid
  module Docs
    module DSL

      # Returns last part of name
      #
      # Example:
      # Liquid::Drops::Account.name => "Account"
      def name
        parts.last
      end

      def human_name(value = nil)
        if value
          @human_name = value
        else
          @human_name or name.humanize
        end
      end

      def nodoc?
        @nodoc
      end

      # This object will not be documented and will not respond to 'help' method
      def nodoc!
        # undefine class help method if it is defined
        # so it will not be shown in debug:help
        singleton_class.send(:undef_method, :help) if respond_to?(:help)
        @nodoc = true
      end

      # Add class level information
      #
      # Example:
      #
      # class Drops::Account < Drops::Base
      #   info "Account holds all information about selected buyer account."
      # end
      #
      # Output:
      #
      # Drops::Account.documentation.to_markdown =>
      #
      # # Account
      #
      # Account holds all information abount selected buyer account.
      #
      def info(text)
        documentation << Text.new(text)
      end


      # Sets deprecated flag and text
      # This is used by GeneratorHook module.
      #
      # Example:
      #
      # class Drops::Account < Drops::Base
      #
      #   deprecated 'Use #name instead'
      #   desc "Org. Name"
      #
      #   def org_name
      #     @account.org_name
      #   end
      # end

      def deprecated(label)
        @deprecated = label
      end

      # Adds method level description. Subsequent 'descriptions' will be
      # concatenated to the following method descriptions.
      #
      # (GeneratorHook module pops all stored description, when new method is defined.)
      #
      # Example:
      #
      # desc "Name of Account"
      # desc "For example: ..."
      # def name
      #   # return name
      # end
      def desc(label)
        @descriptions << Description.new(label)
      end

      # Adds example
      # Example:
      #
      # example %{
      #   Some example code.
      # }
      #
      # example "This is title of example", %{
      #   And some example again.
      # }
      def example(*args)
        @examples << Example.new(*args)
      end

      # Hides next method
      # Example:
      #
      # hidden
      # def to_ary
      #   # return array
      # end
      def hidden
        @hidden = true
      end

      # hides all methods defined in the block
      # Example:
      #
      # all_hidden do
      #   def a; end
      #   def b; end
      # end
      def all_hidden(&block)
        @all_hidden = true
        yield
      ensure
        @all_hidden = nil
      end
      private

      def deprecated?
        if msg = @deprecated
          @deprecated = false
          Deprecated.new(msg)
        else
          false
        end
      end

      def hidden?
        return true if @all_hidden

        if @hidden
          @hidden = false
          true
        else
          false
        end
      end

      def parts
        self.to_s.split("::")
      end

      def last(attr)
        values = instance_variable_get("@#{attr}")
        values.shift(values.length)
      end
    end
  end
end
