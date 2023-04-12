# frozen_string_literal: true

module ApiSupport
  class UnpermittedParameters < StandardError
    def initialize(unpermitted_keys)
      msg = "Unpermitted parameters: #{unpermitted_keys}"
      super msg
    end
  end

  module ForbidParams
    extend ::ActiveSupport::Concern
    include Params

    included do
      class_attribute :_forbid_params_action
      class_attribute :_forbid_params_whitelist, default: []

      rescue_from UnpermittedParameters do |error|
        render_error error.message, status: :unprocessable_entity
      end
    end

    class_methods do
      def forbid_extra_params(action, options = {})
        before_action :unpermitted_parameters_check
        self._forbid_params_action = action

        return unless options[:whitelist]

        self._forbid_params_whitelist = [*options[:whitelist]]
      end
    end

    private

    def forbid_params_whitelist
      self.class._forbid_params_whitelist.map(&:to_s)
    end

    def wrapped_keys
      [_wrapper_key, *_wrapper_options[:include]].map(&:to_s)
    end

    def unpermitted_keys
      flat_params.keys - wrapped_keys - forbid_params_whitelist
    end

    def unpermitted_parameters_check
      return unless _forbid_params_action
      return if unpermitted_keys.blank?

      case self.class._forbid_params_action
      when :log
        Rails.logger.warn("Unpermitted parameters: #{unpermitted_keys}")
      when :reject
        raise UnpermittedParameters, unpermitted_keys
      end
    end
  end
end
