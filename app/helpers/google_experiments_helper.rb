module GoogleExperimentsHelper

  GOOGLE_ANALYTICS_EXPERIMENT_SCRIPT = URI('https://www.google-analytics.com/cx/api.js').freeze
  GOOGLE_EXPERIMENTS = 'google_experiments.js'.freeze

  def include_google_experiment(experiment_name)
    return unless ThreeScale::Analytics::GoogleExperiments.enabled?

    config = ThreeScale::Analytics::GoogleExperiments.config

    experiment_id = config[experiment_name]

    unless experiment_id
      Rails.logger.info "Could not find configuration for experiment #{experiment_name}"
      return
    end

    uri = GOOGLE_ANALYTICS_EXPERIMENT_SCRIPT.dup
    uri.query = { experiment: experiment_id }.to_query

    content = block_given? ? capture(&Proc.new) : ''

    javascript_include_tag(uri.to_s) + javascript_include_tag(GOOGLE_EXPERIMENTS) + content
  end
end
