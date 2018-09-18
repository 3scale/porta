module ThreeScale::SpamProtection
  module Integration

    module Model
      extend ActiveSupport::Concern

      included do
        delegate :spam?, :is_spam?, :spam_probability, :to => :spam_protection
        class_attribute :_spam_protection, :instance_reader => false, :instance_writer => false
      end

      def spam_protection
        @spam_protection ||= ThreeScale::SpamProtection::Protector.new(self)
      end

      module ClassMethods

        def spam_protection_attribute(*attrs)
          return unless respond_to?(:attr_accessible)
          return unless self._accessible_attributes

          attr_accessible *attrs
        end

        def spam_protection
          self._spam_protection
        end

        def has_spam_protection(*checks)
          config = ThreeScale::SpamProtection::Configuration.new(self)
          config.enable_checks! checks.presence || config.available_checks
          self._spam_protection = config
        end
      end
    end

  end
end
