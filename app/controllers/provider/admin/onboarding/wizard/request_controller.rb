# frozen_string_literal: true

class  Provider::Admin::Onboarding::Wizard::RequestController < Provider::Admin::Onboarding::Wizard::BaseController
  before_action :build_request_form

  def new
    track_step('new request')
  end

  def update
    saved = @request.validate(request_params) && @request.save

    unless saved
      analytics.track('Validation Error', controller: controller_name, action: action_name)
      return render(action: :edit)
    end

    status = @request.test_api!
    success = status&.success?
    real_api = ApiClassificationService.test(@request.uri).real_api?

    if status
      @error, @message = status.error unless success
    else
      @error = 'Server Error'
      @message = 'The gateway cannot be deployed at this moment, please try again in a couple of minutes.'
    end

    analytics.track('Onboarding Request',
                    success: success, error: @error, message: @message,
                    uri: @request.uri, real_api: real_api)

    if success
      redirect_to onboarding_wizard_request_path_with_response(response: status.body.to_s)
    else
      render action: :edit
    end
  end

  # success (also shows response)
  def show
    @response = Encoder.decode_param(response_params[:response].to_s)
    track_step('show request')
  end

  def edit
    track_step('edit request')
  end

  protected

  def request_params
    params.require(:request)
  end

  def response_params
    params.permit(:response)
  end

  def build_request_form
    @request = ::Onboarding::RequestForm.new(proxy)
  end

  def proxy
    service.proxy
  end

  def onboarding_wizard_request_path_with_response(response:, **other_params)
    uri = ->(params) { provider_admin_onboarding_wizard_request_path(params) }
    reserved_bytes = uri.call(response: '', **other_params).slice(/\?.+/).bytesize # Makes sure we don't exceed the max size of QUERY_STRING (1024 x 10 bytes)
    encoded_response = Encoder.encode_param(response, reserved_bytes: reserved_bytes)
    uri.call(response: encoded_response, **other_params)
  end

  class Encoder
    def self.encode_param(value, reserved_bytes: 0)
      new(value, reserved_bytes: reserved_bytes).encoded_value
    end

    def self.decode_param(value)
      Base64.urlsafe_decode64(value)
    rescue ArgumentError
      value
    end

    def initialize(value, reserved_bytes:)
      @value = value
      @reserved_bytes = reserved_bytes
    end

    attr_reader :value, :reserved_bytes

    def encoded_value
      Base64.urlsafe_encode64(truncated_value, padding: false)
    end

    protected

    MAX_QUERY_STRING_BYTES = (1024 * 10).freeze
    BASE_64_EXPANSION_FACTOR = (4.0 / 3).freeze
    private_constant :MAX_QUERY_STRING_BYTES, :BASE_64_EXPANSION_FACTOR

    def truncated_value
      return value unless truncate?
      value.byteslice(0...(max_value_size-3)) + '…'
    end

    def truncate?
      value_size > max_value_size
    end

    def value_size
      value.bytesize
    end

    def max_value_size
      ((MAX_QUERY_STRING_BYTES - reserved_bytes) / BASE_64_EXPANSION_FACTOR).floor
    end
  end
  private_constant :Encoder
end
