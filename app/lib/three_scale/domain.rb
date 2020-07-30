module ThreeScale
  module Domain
    def self.current_endpoint(request, host = request.host)
      "#{request.scheme}://#{host}:#{request.port}"
    end

    def self.callback_endpoint(request, account, host = request.host)
      endpoint = if account.master?
                   current_endpoint(request, account.external_domain) + '/master/devportal'.freeze
                 else
                   current_endpoint(request, host)
      end + '/auth'.freeze

      invitation_token = (request.try(:parameters) || {})[:invitation_token]

      if invitation_token.present?
        endpoint + "/invitations/#{invitation_token}"
      else
        endpoint
      end
    end
  end
end
