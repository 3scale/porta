module Liquid
  module Drops
    class Invoice < Drops::Model

      allowed_name :invoice, :invoices

      example %{
        <td> {{ invoice.friendly_id }} </td>
        <td> {{ invoice.name }} </td>
        <td> {{ invoice.state }} </td>
        <td> {{ invoice.cost }} {{ invoice.currency }} </td>
     }

      privately_include do
        include  ActionView::Helpers::NumberHelper
      end

      def initialize(invoice)
        @invoice = invoice
        super
      end

      desc 'Returns a friendly id'
      def friendly_id
        @invoice.friendly_id
      end

      alias id friendly_id

      desc "Returns a string composed of month and year."
      def name
        @invoice.name
      end

      def state
        @invoice.state
      end

      desc "Returns a number with two decimals."
      example %{
          23.00
      }
      def cost
        money_to_s @invoice.cost
      end

      def currency
        @invoice.cost.currency
      end

      desc "Returns cost without VAT."
      def cost_without_vat
        money_to_s @invoice.cost(vat_included: false)
      end

      desc "Returns VAT rate."
      def vat_rate
        @invoice.vat_rate
      end

      desc "Returns VAT ammount."
      def vat_amount
        money_to_s @invoice.vat_amount
      end

      desc "Return true if the PDF was generated."
      def exists_pdf?
        @invoice.pdf.file?
      end

      example %{
        {{ invoice.period_begin | date: i18n.short_date }}
      }
      def period_begin
        @invoice.period.begin
      end

      example %{
        {{ invoice.period_end | date: i18n.long_date }}
      }
      def period_end
        @invoice.period.end
      end

      example %{
        {{ invoice.issued_on | date: i18n.long_date }}
      }
      def issued_on
        @invoice.issued_on
      end

      example %{
        {{ invoice.due_on | date: i18n.long_date }}
      }
      def due_on
        @invoice.due_on
      end

      example %{
        {{ invoice.paid_on | date: i18n.long_date }}
      }
      def paid_on
        @invoice.paid_at
      end

      def vat_code
        @invoice.vat_code
      end

      def fiscal_code
        @invoice.fiscal_code
      end

      desc "Returns an AccountDrop."
      def account
        Drops::Account.new(@invoice.buyer_account)
      end

      deprecated "Please use `invoice.account` instead."
      def buyer_account
        account
      end


      desc "Returns an array of LineItemDrop."
      example %{
        {% for line_item in invoice.line_items %}
          <tr class="line_item {% cycle 'odd', 'even' %}">
            <th>{{ line_item.name }}</th>
            <td>{{ line_item.description }}</td>
            <td>{{ line_item.quantity }}</td>
            <td>{{ line_item.cost }}</td>
          </tr>
        {% endfor %}
      }
      def line_items
        Liquid::Drops::LineItem.wrap(@invoice.line_items)
      end


      desc "Returns an array of PaymentTransactionDrop."
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
      def payment_transactions
        Liquid::Drops::PaymentTransaction.wrap(@invoice.payment_transactions)
      end



      desc "Returns the resource URL of the invoice."
      example %{
        {{ "Show" | link_to: invoice.url }}
      }
      def url
        admin_account_invoice_path(@invoice)
      end

      desc "Returns the resource URL of the invoice PDF."
      example %{
        {{ "PDF" | link_to: invoice.pdf_url }}
      }
      def pdf_url
        @invoice.pdf.expiring_url
      end

      private

      def money_to_s(value)
        number_to_currency(value.to_f, unit: '')
      end
    end
  end
end
