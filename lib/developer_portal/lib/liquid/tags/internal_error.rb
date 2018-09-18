module Liquid
  module Tags

    class InternalError < Liquid::Tags::Base
      nodoc!

      # scheduled for deletion

      def render(context)
        context.registers[:controller].send(:instance_variable_get, "@exception")
      end
    end
  end
end
