# frozen_string_literal: true

class Policies::PolicyUpdater

  attr_reader :policy, :params

  def initialize(policy, params)
    @policy = policy
    @params = params
  end

  def call
    policy.schema ||= {}
    policy.schema.merge!(
      '$schema' => "http://apicast.io/policy-v1/schema#manifest#",
      'name' => params['humanName'],
      'summary' => params['summary'],
      'description' => params['description'],
      'configuration' => configuration
    )
    policy.save
    policy
  end

  def configuration
    JSON.parse(params['configuration'].to_s)
  rescue JSON::ParserError
    policy.schema['configuration']
  end
end
