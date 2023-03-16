# frozen_string_literal: true

module ApiSupport::Params
  extend ActiveSupport::Concern

  included do
    wrap_parameters format: %i[url_encoded_form json multipart_form]
    before_action :wrap_parameters_check
    before_action :unpermitted_parameters_check
    class_attribute :_class_action_on_unpermitted_parameters
    class_attribute :_class_always_permitted_parameters, default: []
  end

  module ClassMethods

    # What to do when the client sends additional parameters not permitted by Strong Parameters
    #
    # === Allowed values:
    #   * <tt>:log</tt> -   Writes a warning on the logs, containing the list of unpermitted parameters.
    #   * <tt>:raise</tt> - Raises an +ActionController::UnpermittedParameters+ error.
    #   * <tt>nil</tt>, not set, any other value - Defaults to the action globally set through +ActionController::Parameters.action_on_unpermitted_parameters+
    #
    def class_action_on_unpermitted_parameters(action)
      self._class_action_on_unpermitted_parameters = action
    end

    # White list of parameters that won't trigger an UnpermittedParameters error.
    #
    # The parameters in this list are still unpermitted for mass-assignment, they must be
    # manually permitted for that purpose.
    #
    # Accepts symbols and strings
    #
    def class_always_permitted_parameters(permitted_params)
      self._class_always_permitted_parameters = self._class_always_permitted_parameters.dup
      self._class_always_permitted_parameters.push(*permitted_params).uniq!
    end
  end

  protected

  def flat_params
    params.except(:format, :controller, :action, :provider_key, :api_key, :access_token)
  end

  def wrapped_keys
    [_wrapper_key, *_wrapper_options[:include]].map(&:to_s)
  end

  def class_always_permitted_keys
    _class_always_permitted_parameters.map(&:to_s)
  end

  def unpermitted_keys
    flat_params.keys - wrapped_keys - class_always_permitted_keys
  end

  # This basically checks if the wrapped parameter is passed as a Hash, if not it will go 422
  #
  # when ```wrap_parameter Foo``` it will produce this results:
  #
  #     /api/foo.xml?foo[bar]=1&foo[baz]=2 => OK
  #     /api/foo.xml?bar=1&baz=2           => OK
  #     /api/foo.xml?foo[bar]=1&foo=2      => 422
  #     /api/foo.xml?foo=5                 => 422
  #
  def wrap_parameters_check
    option_name = _wrapper_options[:name]
    param_name = params[option_name]
    return if !param_name || param_name.is_a?(ActionController::Parameters)

    respond_to do |format|
      format.any(:xml, :json) { render request.format.to_sym => "Wrong type for parameter: #{option_name}", status: :unprocessable_entity }
    end

    false
  end

  def unpermitted_parameters_check
    return unless _class_action_on_unpermitted_parameters
    return if unpermitted_keys.blank?

    case self.class._class_action_on_unpermitted_parameters
    when :log
      Rails.logger.warn("Unpermitted parameters: #{unpermitted_keys}")
    when :raise
      raise ActionController::UnpermittedParameters, unpermitted_keys
    end
  end
end
