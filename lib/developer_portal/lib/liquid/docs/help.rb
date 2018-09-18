module Liquid
  module Docs
    module Help

      def help
        "http://support.3scale.net/#{to_param}"
      end

      def to_param
        "Liquid/#{[parts[-2..-2], name].join('/')}"
      end

    end
  end
end
