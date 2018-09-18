# Envelope providing compatibility with Paperclip::Attachment
module Pdf
  module Finance

    # REFACTOR: delete this class and use InvoiceReportData instead
    class InvoiceAttachment < StringIO
      def initialize(invoice_data, content)
        @data = invoice_data
        super(content)
      end

      def original_filename
        @data.filename
      end

      def content_type
        'application/pdf'
      end
    end
  end
end
