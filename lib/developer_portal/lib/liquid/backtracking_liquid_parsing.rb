# frozen_string_literal: true

module Liquid
  module BacktrackingLiquidParsing
    module TagExtension
      def self.prepended(_klass)
        attr_accessor :previous_tag
      end

      module ClassMethods
        def parse(tag_name, markup, tokens, options, previous_tag = nil)
          tag = new(tag_name, markup, options)
          tag.previous_tag = previous_tag
          tag.parse(tokens)
          tag
        end
      end
    end

    module BlockExtension
      def parse(tokens)
        @blank = true
        @nodelist ||= []
        @nodelist.clear

        while token = tokens.shift
          begin
            unless token.empty?
              case
              when token.start_with?(Liquid::Block::TAGSTART)
                if token =~ Liquid::Block::FullToken

                  # if we found the proper block delimiter just end parsing here and let the outer block
                  # proceed
                  return if block_delimiter == $1

                  # fetch the tag from registered blocks
                  if tag = Liquid::Template.tags[$1]
                    markup = token.is_a?(Liquid::Token) ? token.child($2) : $2
                    new_tag = tag.parse($1, markup, tokens, @options, self)
                    new_tag.line_number = token.line_number if token.is_a?(Liquid::Token)
                    @blank &&= new_tag.blank?
                    @nodelist << new_tag
                  else
                    # this tag is not registered with the system
                    # pass it to the current block for special handling or error reporting
                    unknown_tag($1, $2, tokens)
                  end
                else
                  raise Liquid::SyntaxError.new(options[:locale].t("errors.syntax.tag_termination".freeze, :token => token, :tag_end => Liquid::TagEnd.inspect))
                end
              when token.start_with?(Liquid::Block::VARSTART)
                new_var = create_variable(token)
                new_var.line_number = token.line_number if token.is_a?(Liquid::Token)
                @nodelist << new_var
                @blank = false
              else
                @nodelist << token
                @blank &&= (token =~ /\A\s*\z/)
              end
            end
          rescue Liquid::SyntaxError => e
            e.set_line_number_from_token(token)
            raise
          end
        end

        # Make sure that it's ok to end parsing in the current block.
        # Effectively this method will throw an exception unless the current block is
        # of type Document
        assert_missing_delimitation!
      end
    end
  end
end

Liquid::Tag.singleton_class.prepend Liquid::BacktrackingLiquidParsing::TagExtension::ClassMethods
Liquid::Tag.prepend Liquid::BacktrackingLiquidParsing::TagExtension
Liquid::Block.prepend Liquid::BacktrackingLiquidParsing::BlockExtension
