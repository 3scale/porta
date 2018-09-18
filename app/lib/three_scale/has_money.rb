require_dependency File.dirname(__FILE__) + '/money'

module ThreeScale
  module HasMoney
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Define attribute (or attributes) that should act as money. You should
      # specify and attribute or proc that will return currency for them and
      # optionaly other one that returns date of which the historic exchange
      # rates should be used.
      #
      # == Examples
      #
      #     # Use +price+ attribute for amount and implicit +currency+
      #     # attribute for currency.
      #     has_money :price
      #
      #     # Use two attributes: +price_with_tax+ and +price_without_tax+
      #     has_money :price_with_tax, :price_without_tax
      #
      #     # Use custom currency attribute
      #     has_money :price, :currency => :foo_currency
      #
      #     # Use proc for currency
      #     has_money :price, :currency => lambda { |record| record.user.currency }
      #
      def has_money(*attributes)
        options = attributes.extract_options!
        options.reverse_merge!(:currency => :currency)

        attributes.each do |name|
          # Define reader
          define_method(name) do
            convert_money(read_attribute(name), options)
          end

          # Define writer
          define_method("#{name}=") do |value|
            write_attribute(name, convert_money(value, options))
          end
        end
      end
    end

    private

    def convert_money(value, options)
      currency = read_money_attribute(options[:currency])
      date     = read_money_attribute(options[:date])

      if value && currency
        value.to_has_money(currency, date)
      else
        value
      end
    end

    def read_money_attribute(attribute)
      if attribute.respond_to?(:call)
        attribute.call(self)
      elsif attribute
        send(attribute)
      end
    end
  end
end
