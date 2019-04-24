class ProxyLog < ApplicationRecord
  belongs_to :provider, :class_name => 'Account'
  scope :latest_first, -> { order(created_at: :desc) }
  validates :status, :lua_file, presence: true
  validates :status, length: { maximum: 255 }

  def file_name
    "sandbox_proxy_#{provider.id}.lua"
  end
end
