class ProxyLog < ApplicationRecord
  belongs_to :provider, :class_name => 'Account'
  scope :latest_first, -> { order(created_at: :desc) }
  validates :status, :lua_file, presence: true

  def file_name
    "sandbox_proxy_#{provider.id}.lua"
  end
end
