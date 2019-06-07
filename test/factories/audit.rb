# frozen_string_literal: true

FactoryBot.define do
  factory(:audit, class: Audited.audit_class) do
    synchronous { true }

    provider_id { build_stubbed(:simple_provider).id }

    auditable_type { 'Account' }
    auditable_id  { provider_id }

    kind { auditable_type }

    action { 'create' }
    audited_changes { { 'org_name' => ['Previous', 'Current'] } }
    version { 1 }
    request_uuid { SecureRandom.uuid }

    user_id { User.current&.id }
    user_type { 'User' if user_id }
  end
end
