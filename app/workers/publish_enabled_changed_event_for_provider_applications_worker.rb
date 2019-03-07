# frozen_string_literal: true

# TODO: Rails 5 --> class PublishEnabledChangedEventForProviderApplicationsWorker < ApplicationJob
class PublishEnabledChangedEventForProviderApplicationsWorker < ActiveJob::Base
  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.info "PublishEnabledChangedEventForProviderApplicationsWorker#perform raised #{exception.class} with message #{exception.message}"
  end

  def perform(provider, previous_state)
    return unless [provider.state, previous_state].include?('scheduled_for_deletion')
    provider.buyer_applications.find_each(&:publish_enabled_changed_event)
    provider.bought_cinstances.find_each(&:publish_enabled_changed_event)
  end
end
