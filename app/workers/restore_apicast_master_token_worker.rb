# frozen_string_literal: true

# This will only perform in the context of k8s or OpenShift
# It sets the value of the access token from an environment variable
class RestoreApicastMasterTokenWorker < ApplicationJob
  unique :until_executed


  def perform(*)
    if ENV['APICAST_ACCESS_TOKEN'].blank?
      Rails.logger.info 'Cannot execute this job without an access token'
      return
    end

    token_name = ENV.fetch('APICAST_TOKEN_NAME', 'APIcast mapping-service')
    token = ENV.fetch('APICAST_ACCESS_TOKEN')
    master = Account.master
    access_token = master.access_tokens.find_by!(name: token_name)
    # Need to do that because `:value` is a readonly attribute
    AccessToken.where(id: access_token.id).limit(1).update_all(value: token) # rubocop:disable Rails/SkipsModelValidations
  end
end
