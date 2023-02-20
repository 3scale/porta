# frozen_string_literal: true

module CMS::SystemName

  extend ActiveSupport::Concern

  included do
    validates :system_name, uniqueness: { scope: %i[provider_id], allow_blank: true },
              format: { with: %r{\A\w[\w\-/ ]+\z}, allow_blank: true }, length: { maximum: 255 },
              presence: true

    before_validation :set_system_name, on: :create
  end

  protected

  def set_system_name
    self.system_name = title.parameterize if title.present? && system_name.blank?
  end
end
