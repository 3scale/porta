module BackendClient
  class BackendError < RuntimeError; end
  class TooManyItems < BackendError; end
  class InvalidItem  < BackendError; end

  def self.config
    System::Application.config.backend_client
  end
end
