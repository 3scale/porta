# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[activation_code cms_token credit_card credit_card_auth_code
                                                 credit_card_authorize_net_payment_profile_token credit_card_expires_on
                                                 credit_card_partial_number crypted_password janrain_api_key lost_password_token
                                                 password password_digest payment_gateway_options payment_service_reference salt
                                                 site_access_code sso_key user_key access_token service_token provider_key app_key]
