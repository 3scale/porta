class Country < ApplicationRecord
  validates :name, :code, presence: true
  validates :code, uniqueness: { case_sensitive: true }
  validates :name, :code, :currency, length: {maximum: 255}

  # Cuba, Iran, North Korea, Sudan, Syria
  T5_COUNTRIES_CODE = %w(CU IR KP SD SY).freeze

  default_scope -> { where(enabled: true).order('name') }
  scope :t5_countries, -> { unscoped.where(code: T5_COUNTRIES_CODE) }

  def to_param
    code.downcase
  end

end
