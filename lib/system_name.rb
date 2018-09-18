module SystemName

  extend ActiveSupport::Concern

  included do
    before_validation :generate_system_name, on: :create
    class_attribute :_system_human_name
  end

  module ClassMethods

    def validates_system_name(opts = {})
      validates :system_name, presence: true, format: { with: /\A\w[\w\-\/_]+\z/, allow_nil: true }

      if opts[:uniqueness_scope]
        validates :system_name, uniqueness: opts[:uniqueness_scope] == true ? true : { scope: opts[:uniqueness_scope] }
      end
    end

    def has_system_name(opts = {})
      attr_protected :system_name if opts.delete(:protected)
      self._system_human_name = opts.delete(:human_name) || :name
      validates_system_name(opts)
    end
  end

  protected

    def system_human_name
      send(self._system_human_name)
    end

    # Generates system_name from 'system_human_name'
    def generate_system_name
      generate_system_name! if self.system_name.blank?
    end

    def generate_system_name!
      if self.system_human_name.present?
        slug = self.system_human_name.parameterize.underscore
        self.system_name = slug.blank? ? internal_system_name : slug
      else
        # TODO: remove this branch when Feature#name validation is added
        # and this ticket resolved https://github.com/3scale/system/issues/908
        if self.is_a?(Feature)
          msg = "Deprecated API with missing feature name probably called."
          Rails.logger.warn msg
        end

        self.system_name = internal_system_name
      end
    end

    # This method is used when we need to generate a system_name
    # but there is no suitable 'name' (human_name) from which
    # we can guess a reasonable one.
    #
    def internal_system_name
      model_name = ActiveModel::Name.new(self.class, self.class.parent)
      "#{model_name.param_key}_#{SecureRandom.hex(6)}"
    end
end
