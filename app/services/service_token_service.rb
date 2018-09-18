# frozen_string_literal: true

module ServiceTokenService
  module_function

  # @param [ServiceToken] service_token
  def update_backend(service_token)
    ThreeScale::Core::ServiceToken.save!(
      service_token.value => { service_id: service_token.service_id }
    )
  end

  # @param [ServiceToken] service_token
  def delete_backend(*service_tokens)
    ThreeScale::Core::ServiceToken.delete(service_tokens.map { |token| { service_id: token.service_id, service_token: token.value } })
  end
end
