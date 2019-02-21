# frozen_string_literal: true

class BackendDeleteEndUsersWorker
  include Sidekiq::Worker

  def perform(service_id)
    ThreeScale::Core::User.delete_all_for_service(service_id)
  end
end
