module ThreeScale
  module Domain
    STANDARD_HTTP_PORTS = [80, 443]

    def self.current_endpoint(request, host = request.host)
      if STANDARD_HTTP_PORTS.exclude?(request.port.to_i)
        "#{request.scheme}://#{host}:#{request.port}"
      else
        "#{request.scheme}://#{host}"
      end
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
