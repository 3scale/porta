# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  _key access_token activation_code app_key certificate cms_token credit_card credit_card_auth_code
  credit_card_authorize_net_payment_profile_token credit_card_expires_on credit_card_partial_number crypt
  crypted_password janrain_api_key lost_password_token otp passw password password_digest payment_gateway_options
  payment_service_reference provider_key salt secret service_token site_access_code ssn sso_key token user_key
]
