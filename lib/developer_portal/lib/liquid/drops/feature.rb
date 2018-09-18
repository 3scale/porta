module Liquid
  module Drops
    class Feature < Drops::Model
      allowed_name :feature

      def initialize(feature)
        @feature = feature
        super
      end

      desc "Returns the name of the feature."
      example %{
        <h1>Feature {{ feature.name }}</h1>
      }
      def name
        @feature.name
      end

      desc "Returns the description of the feature."
      def description
        @feature.description
      end

      desc "Returns description of the feature or information that there is no description."
      example %{
        {% if feature.has_description? %}
          {{ feature.description }}
        {% else %}
           This feature has no description.
        {% endif %}
      }
      def has_description?
        !description.blank?
      end

      desc "Returns system name of the feature (system wide unique name)."
      example %{
        {% if feature.system_name == 'promo_feature' %}
          <div>This feature is available only today!</div>
        {% endif %}
      }
      delegate :system_name, to: :@feature

      hidden # use system name instead
      def id
        @feature.id
      end

      hidden # this cannot be deprecated, it has to be replaced
      def plan
        Drops::Plan.new @feature.plan
      end

    end
  end
end
