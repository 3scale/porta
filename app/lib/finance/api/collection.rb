module Finance
  module Api
    class Collection < ThreeScale::Api::Collection

      def to_xml(options = {})
        Finance::Builder::XmlMarkup.invoices!(self)
      end

    end
  end
end
