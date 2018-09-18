module Liquid
  module Drops
    class Metric < Drops::Model
      allowed_name :metric, :metrics

      # TODO: extract to Methods drop
      allowed_name :methods

      def initialize(metric)
        @metric = metric
        super
      end

      hidden # use name or friendly name instead
      def id
        @metric.id
      end

      desc "Returns the unit of the metric."
      example %{
        This metric is measured in {{ metric.unit | pluralize }}
      }
      def unit
        @metric.unit
      end

      desc "Returns the description of the metric."
      def description
        @metric.description.presence
      end

      desc "Returns the name of the metric."
      example %{
        <h3>Metric {{ metric.name }}</h3>
        <p>{{ metric.description }}</p>
      }
      def name
        @metric.friendly_name
      end

      desc "Returns the system name of the metric."
      example %{
        <h3>Metric {{ metric.name }}</h3>
        <p>{{ metric.system_name }}</p>
      }
      def system_name
        @metric.name
      end

      desc "Returns the usage limits of the metric."
      example %{
        {% if metric.usage_limits.size > 0 %}
          <p>Usage limits of the metric</p>
          <ul>
            {% for usage_limit in metric.usage_limits %}
              <li>{{ usage_limit.period }} : {{ usage_limit.value }}</li>
            {% endfor %}
          </ul>
        {% else %}
          <p>This metric has no usage limits.</p>
       {% endif %}
      }
      def usage_limits
        Drops::UsageLimit.wrap(@metric.usage_limits)
      end

      desc "Returns the pricing rules of the metric."
      example %{
        {% if metric.pricing_rules.size > 0 %}
          <p>Pricing rules of the metric</p>
          <ul>
          {% for pricing_rule in metric.pricing_rules %}
            <li>{{ pricing_rule.cost_per_unit }}</li>
          {% endfor %}
          </ul>

        {% else %}
          <p>This metric has no pricing rules.</p>
        {% endif %}
      }
      def pricing_rules
        Drops::PricingRule.wrap(@metric.pricing_rules)
      end

      def has_parent
        @metric.parent?
      end

    end
  end
end
