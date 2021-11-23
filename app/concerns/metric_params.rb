# frozen_string_literal: true

module MetricParams
  extend ActiveSupport::Concern

  DEFAULT_PARAMS = %i[friendly_name unit description].freeze
  private_constant :DEFAULT_PARAMS

  included do
    private

    def create_params
      params.require(:metric).permit(DEFAULT_PARAMS | %i[system_name])
    end

    def update_params
      params.require(:metric).permit(DEFAULT_PARAMS)
    end
  end
end
