# frozen_string_literal: true


module Pdf
  module Finance
    class InvoiceGenerator
      include Pdf::Printer

      # TODO: remove
      include ActionView::Helpers::NumberHelper
      include ThreeScale::MoneyHelper
      include ::Finance::InvoicesHelper

      def initialize(invoice_data)
        @data = invoice_data
        @coder = HTMLEntities.new

        # TODO: accept as parameter
        @style = Pdf::Styles::BlackAndWhite.new
        @pdf = Prawn::Document.new(page_size: 'A4',
                                   page_layout: :portrait,
                                   compress: true)

        set_default_font
      end

      # Generates PDF content and wraps it to envelope acceptable by Paperclip
      def generate_as_attachment
        InvoiceAttachment.new(@data, generate)
      end

      def generate
        print_header

        print_address_columns

        move_down(5)
        print_line_items
        move_down(5)

        print_line
        move_down
        print_total

        move_down(2)
        @pdf.text @data.invoice_footnote
        move_down

        @pdf.render
      end

      private

      def print_header
        two_columns do |column|
          print_logo if column == :left
          print_address(@data.buyer) if column == :right
        end

        move_down(14)
        @pdf.text "Invoice for #{@data.name}", size: 20, align: :center
        move_down(14)

        subtitle('Details')
        print_details
        move_down(3)
      end

      def print_logo
        @data.with_logo do |logo|
          @pdf.image(logo, fit: [200,50], position: :left) if logo
        end
      end

      def print_address_columns
        two_columns([0.mm, @pdf.cursor]) do |column|
          print_address(@data.provider, 'Issued by') if column == :left
          print_address(@data.buyer, 'For') if column == :right
        end
      end

      def print_address(person, name = nil)
        subtitle("#{name}") if name
        table_with_column_header(person, width: TABLE_HALF_WIDTH)
      end

      def print_details
        details = [['Invoice ID', @data.friendly_id],
                   ['Issued on', @data.issued_on],
                   ['Billing period start', @data.period_start],
                   ['Billing period end', @data.period_end],
                   ['Due on', @data.due_on]]

        table_with_column_header(details)
      end

      def print_line_items
        subtitle('Line items')
        opts = { width: TABLE_FULL_WIDTH, header: true, cell_style: {align: :right} }
        table_with_header([InvoiceReportData::LINE_ITEMS_HEADING] + @data.line_items, opts) do
          column(0).style { |column| column.align = :left }
        end
        move_down
        @pdf.text(@data.vat_zero_text) if @data.vat_rate&.zero?
      end

      def print_total
        @pdf.bounding_box([@pdf.bounds.right - 310, @pdf.cursor], width: 310) do
          @pdf.text "AMOUNT DUE: #{@coder.decode(rounded_price_tag(@data.cost))}", size: 13, align: :right, style: :bold
        end
      end

    end
  end
end
