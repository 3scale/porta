# frozen_string_literal: true

Given "{provider} has no legal terms" do |provider|
  provider.builtin_legal_terms.delete_all
end

Given "{provider} has service subscription legal terms:" do |provider, text|
  provider.builtin_legal_terms.create!(system_name: CMS::Builtin::LegalTerm::SUBSCRIPTION_SYSTEM_NAME,
                                      published: text)
end
