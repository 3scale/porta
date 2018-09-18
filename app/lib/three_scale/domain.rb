module ThreeScale
  module Domain
    def self.current_endpoint(request, host = request.host)
      host_and_port = if Rails.env.development?
                        request.host_with_port("#{host}:#{request.port}")
                      elsif Rails.env.preview?
                        request.respond_to?(:real_host) ? request.real_host(host) : host
                      else
                        host
                      end
      "#{request.scheme}://#{host_and_port}"
    end

    def self.callback_endpoint(request, account, host = request.host)
      endpoint = if account.master?
                   current_endpoint(request, account.domain) + '/master/devportal'.freeze
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
