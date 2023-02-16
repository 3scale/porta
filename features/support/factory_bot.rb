require 'active_support/deprecation'

# @api private
module FactoryBotStepHelpers
  def convert_human_hash_to_attribute_hash(human_hash, associations = [])
    HumanHashToAttributeHash.new(human_hash, associations).attributes
  end

  class HumanHashToAttributeHash
    attr_reader :associations

    def initialize(human_hash, associations)
      @human_hash   = human_hash
      @associations = associations
    end

    def attributes(strategy = CreateAttributes)
      @human_hash.inject({}) do |attribute_hash, (human_key, value)|
        attributes = strategy.new(self, *process_key_value(human_key, value))
        attribute_hash.merge({ attributes.key => attributes.value })
      end
    end

    private

    def process_key_value(key, value)
      value = value.strip if value.is_a?(String)
      [key.downcase.gsub(' ', '_').to_sym, value]
    end

    class AssociationManager
      def initialize(human_hash_to_attributes_hash, key, value)
        @human_hash_to_attributes_hash = human_hash_to_attributes_hash
        @key   = key
        @value = value
      end

      def association
        @human_hash_to_attributes_hash.associations.detect {|association| association.name == @key }
      end

      def association_instance
        return unless association

        if attributes_hash = nested_attribute_hash
          factory.build_class.where(attributes_hash.attributes(FindAttributes)).first or
            FactoryBot.create(association.factory, attributes_hash.attributes)
        end
      end

      private

      def factory
        FactoryBot.factory_by_name(association.factory)
      end

      def nested_attribute_hash
        attribute, value = @value.split(':', 2)
        return if value.blank?

        HumanHashToAttributeHash.new({ attribute => value }, factory.associations)
      end
    end

    class AttributeStrategy
      attr_reader :key, :value, :association_manager

      def initialize(human_hash_to_attributes_hash, key, value)
        @association_manager = AssociationManager.new(human_hash_to_attributes_hash, key, value)
        @key   = key
        @value = value
      end
    end

    class FindAttributes < AttributeStrategy
      def initialize(human_hash_to_attributes_hash, key, value)
        super

        if association_manager.association
          @key = "#{@key}_id"
          @value = association_manager.association_instance.try(:id)
        end
      end
    end

    class CreateAttributes < AttributeStrategy
      def initialize(human_hash_to_attributes_hash, key, value)
        super

        if association_manager.association
          @value = association_manager.association_instance
        end
      end
    end
  end
end

World(FactoryBotStepHelpers)
