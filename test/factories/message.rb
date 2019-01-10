FactoryBot.define do
  factory(:received_message, class: MessageRecipient) do
    kind { 'to' }
    hidden_at { nil }
    association :receiver, factory: :account
    association :message, state: 'sent'
  end

  factory(:message) do
    subject { 'Hola' }
    body { 'The Greatest Adventure' }
    state { 'unsent' }
    association :sender, factory: :account
  end
end
