# frozen_string_literal: true

class Users::UserDeletedEvent < UserRelatedEvent
  def self.create(user)
    new(
      user_id: user.id,
      metadata: {
        provider_id: user.provider_account.try(:id) || user.tenant_id
      }
    )
  end
end
