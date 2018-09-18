module Liquid
  module Drops
    class PaymentTransaction < Drops::Model
      allowed_name :payment_transaction, :payment_transactions

      example %{
        {% for payment_transaction in invoice.payment_transactions %}
          <tr>
            <td> {% if payment_transaction.success? %} Success {% else %} Failure {% endif %} </td>
            <td> {{ payment_transaction.created_at }} </td>
            <td> {{ payment_transaction.reference }} </td>
            <td> {{ payment_transaction.message }} </td>
            <td> {{ payment_transaction.amount }} {{ payment_transaction.currency }} </td>
          </tr>
        {% endfor %}
      }

      def initialize(payment_transaction)
        @payment_transaction = payment_transaction
        super
      end

      desc "Returns the currency."
      def currency
        @payment_transaction.currency
      end

      desc "Returns the amount."
      def amount
        @payment_transaction.amount.to_s
      end

      desc "Returns the creation date."
      def created_at
        @payment_transaction.created_at
      end

      desc "Returns true if successful."
      def success?
        @payment_transaction.success?
      end

      desc "Returns the message of the transaction."
      def message
        @payment_transaction.message
      end

      desc "Returns the reference."
      def reference
        @payment_transaction.reference
      end
    end
  end
end
