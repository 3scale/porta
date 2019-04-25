class Partner < ApplicationRecord
  include SystemName

  has_system_name protected: true, uniqueness_scope: true
  attr_accessible :api_key, :name

  has_many :providers, class_name: "Account"
  has_many :application_plans

  validates :name, :api_key, presence: true
  validates :name, :api_key, :system_name, :logout_url, length: { maximum: 255 }

  def signup_type
    "partner:#{system_name}"
  end

  def can_manage_users?
    case system_name
    when 'heroku' then false
    when 'appdirect' then false
    else true
    end
  end
end
