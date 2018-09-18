module Liquid
  module Filters
    module ParamFilter
      include Liquid::Filters::Base

      example "Using to_param filter in liquid.", %{
        <h1>Signup to a service</h1>
        <a href="{{ urls.signup }}?{{ service | to_param }}">Signup to {{ service.name }}</a>
      }

      desc "Converts a supplied drop to URL parameter if possible."
      # example by supplying a PlanDrop with ID 42 you should get:
      #
      # {{ plan | to_param }}  --> "plans[]=42"
      #
      def to_param(drop)
        if drop.is_a? Liquid::Drops::Plan
          "plan_ids[]=#{drop.id}"
        elsif drop.is_a? Liquid::Drops::Service
          "service_id=#{drop.id}"
        elsif drop.respond_to?(:map)
          drop.map { |d| to_param(d) }.join('&')
        else
          "cannot_be_converted_to_param"
        end
      end
    end
  end
end
