module Liquid
  module Drops
    class Country < Drops::Model

      allowed_name :country, :countries

      def to_str
        @model.name
      end

      def code
        @model.code
      end

      def label
        @model.name
      end
    end
  end
end
