# frozen_string_literal: true

module SegmentDeleteService
  module_function

  def delete_user(event)
    # TODO: all this prints will be removed, but for now they are here for testing purposes
    uri = URI('https://gdpr.segment.com/graphql')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    # TODO: the token will be fetched by config when we have it
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json; charset=utf-8', 'Authorization' => 'Bearer token-example'})
    # pp "REQ HEADERS: #{request.instance_variable_get(:@header)}"
    # TODO: the workspaceSlug should be configurable
    request.body = {"query": "mutation { createWorkspaceRegulation(workspaceSlug: \"3scale\" type: SUPPRESS_AND_DELETE userId: \"#{event.data[:user_id]}\" ) { id } }"}.to_json
    # pp "REQ BODY: #{request.body}"
    # response = https.request(request)
    # pp "RESPONSE CODE: #{response.code}"
    # pp "RESPONSE BODY: #{response.body}"
    # TODO: return if it worked or not with true/false ? or raise an error if it didn't work? Btw, this code should also rescue if there are network errors or something like that :)
    https.request(request)
  end
end
