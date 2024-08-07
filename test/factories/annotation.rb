# frozen_string_literal: true

FactoryBot.define do
  factory(:annotation, class: Annotation) do
    association :annotated, factory: :provider_account
    name { Annotation::SUPPORTED_ANNOTATIONS.first }
    value { 'operator' }
  end
end
