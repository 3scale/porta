require 'prawn/core'
require 'prawn/format'
require "prawn/measurement_extensions"
require 'gruff'
require "open-uri"

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
        @pdf = Prawn::Document.new(:page_size => 'A4',
                                   :page_layout => :portrait)

        @pdf.tags(@style.tags)
        @pdf.font(@style.font)
      end

      # Generates PDF content and wraps it to envelope acceptable by Paperclip
      def generate_as_attachment
        InvoiceAttachment.new(@data, generate)
      end

      def generate
        two_columns do |column|
          case column
          when :left
              @pdf.image(@data.logo, :fit => [200,50], :position => :left) if @data.has_logo?

          when :right
              print_address(@data.buyer)
          end
        end

        move_down(14)
        @pdf.text "Invoice for #{@data.name}", :size => 20, :align => :center
        move_down(14)

        subtitle('<b>Details</b>')
        print_details
        move_down(3)

        # TODO: cleanup the constants
        two_columns( [ 0.mm, @pdf.cursor ], :height => 50.mm) do |column|
          case column
          when :left then print_address( @data.provider, 'Issued by')
          when :right then print_address( @data.buyer, 'For')
          end
        end

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

      def print_address(person, name = nil)
        subtitle("<b>#{name}</b>") if name
        @pdf.table(person, @style.table_style.merge(:width => TABLE_HALF_WIDTH))
      end

      def print_details
        details = [ [ 'Invoice ID', @data.friendly_id ],
                    [ 'Issued on', @data.issued_on ],
                    [ 'Billing period start', @data.period_start ],
                    [ 'Billing period end', @data.period_end ],
                    [ 'Due on', @data.due_on ] ]

        @pdf.table(details, @style.table_style)
      end

      def print_line_items
        opts = { :width => TABLE_FULL_WIDTH, :headers => InvoiceReportData::LINE_ITEMS_HEADING }
        @pdf.table(@data.line_items, @style.table_style.merge(opts))
        move_down
        @pdf.text(@data.vat_zero_text) if @data.vat_rate == 0
      end

      def print_total
        @pdf.bounding_box([@pdf.bounds.right - 310, @pdf.cursor], :width => 310) do
          @pdf.text "<b>AMOUNT DUE: #{@coder.decode(rounded_price_tag(@data.cost))}</b>", :size => 13, :align => :right
        end
      end

    end
  end
end
