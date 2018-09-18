module Liquid
  module Drops
    class BillingAddressField < Drops::Base

      def initialize(billing_address, field_name)
        @billing_address = billing_address
        @field_name = field_name
      end

      def input_name
        "#{object_name}[#{name}]"
      end

      def label
      ::I18n.t @field_name, scope: "activerecord.attributes.account.billing_address"
      end

      def choices
        if @field_name == :country
          ::Country.all.map do | country |
            Liquid::Drops::Field::Choice.new(country.name, country.code)
          end
        end
      end

      def errors
        Drops::Errors.new(@billing_address)[@field_name]
      end

      def html_id
        # we replace all brackets by underscores and cut the last one
        self.input_name.tr_s("[]", "_")[0..-2]
      end

      def hidden?
        false
      end

      def visible?
        true
      end

      def read_only?
        false
      end

      def name
        @field_name.to_s
      end

      def value
        @billing_address.send @field_name
      end

      def required
        [:name, :address1, :address2, :city, :country].include?(@field_name)
      end

      private
        def object_name
          "account[billing_address]"
        end

    end
  end
end

