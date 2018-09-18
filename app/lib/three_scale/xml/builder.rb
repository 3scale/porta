require 'builder'
require 'active_support/proxy_object'

module ThreeScale
  module XML
    class Builder < ActiveSupport::ProxyObject
      delegate :is_a?, :respond_to?, :to_xml, :to => :@builder
      delegate :as_json, :to_s, :to_str, :to => :to_xml

      # @@builder = ::Nokogiri::XML::Builder
      @@builder = ::Builder::XmlMarkup

      def initialize(options = {}, &block)
        @builder = @@builder.new(options)

        instruct! unless options[:skip_instruct]

        yield(self) if block
      end

      def method_missing(method, *args, &block)
        method = method.to_s.sub(/_\Z/, '')

        tag!(method, *args, &block)
      end

      def instruct!
        @builder.instruct!
      end

      def to_xml
        @builder.target!
      end

      def <<(xml)
        @builder << xml

        self
      end

      def tag!(*args, &block)
        args = __normalized_args__(args)

        if block
          __tag__(*args) do |xml|
            yield(self)
          end
        else
          __tag__(*args)
        end

        self
      end

      private

      # this is required as passing symbol to builder
      # makes namespaced elements and we are passing some symbol values

      def __normalized_args__(args)
        args.map do |arg|
          case arg
          when ::Symbol
            arg.to_s
          else
            arg
          end
        end
      end

      def __tag__(*args, &block)
        @builder.__send__(:method_missing, *args, &block)
      end

    end
  end
end
