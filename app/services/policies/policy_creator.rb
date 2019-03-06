# frozen_string_literal: true

class Policies::PolicyCreator

  attr_reader :params, :policy

  def initialize(account, params)
    @policy = account.policies.build
    @params = params
  end

  def call
    policy.schema ||= {}
    policy.schema.merge!(
      '$schema' => "http://apicast.io/policy-v1/schema#manifest#",
      'name' => params['humanName'],
      'version' => params['version'],
      'summary' => params['summary'],
      'description' => params['description'],
      'configuration' => configuration,
    )
    policy.name = params['name']
    policy.version = params['version']
    policy.save
    policy
  end

  def configuration
    JSON.parse(params['configuration'].to_s)
  rescue JSON::ParserError
    {}
  end
end
