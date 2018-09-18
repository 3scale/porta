# frozen_string_literal: true

module ApiSupport::Params
  extend ActiveSupport::Concern

  included do
    wrap_parameters format: %i[url_encoded_form json multipart_form]
    before_action :wrap_parameters_check

    private

    def flat_params
      params.except(:format, :controller, :action, :provider_key, :api_key)
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
    # https://3scale.airbrake.io/projects/14982/groups/71345830/notices/1099701031757124010
    def wrap_parameters_check
      option_name = _wrapper_options[:name]
      param_name = params[option_name]
      return if !param_name || param_name.is_a?(Hash)

      respond_to do |format|
        format.any(:xml, :json) { render request.format.to_sym => "Wrong type for parameter: #{option_name}", status: :unprocessable_entity }
      end

      false
    end
  end
end
