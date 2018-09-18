Factory.define(:received_message, class: MessageRecipient) do |factory|
  factory.kind 'to'
  factory.hidden_at nil
  factory.association :receiver, factory: :account
  factory.association :message, state: 'sent'
end

Factory.define(:message) do |factory|
  factory.subject 'Hola'
  factory.body 'The Greatest Adventure'
  factory.state 'unsent'
  factory.association :sender, factory: :account
end
