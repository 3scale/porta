module InvoicesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :invoices

  items extend: InvoiceRepresenter

  self.xml_collection = Finance::Api::Collection
end
