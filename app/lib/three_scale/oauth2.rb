module ThreeScale
  module OAuth2
    module_function

    @_config = ThreeScale.config.fetch(:oauth2){ Hash.new }.freeze

    class << self
      attr_internal_reader :config
    end

  end
end
