# frozen_string_literal: true

module Features
  class LoggingConfig < Config
    def enabled?
      config.present?
    end
  end
end
