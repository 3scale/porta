# frozen_string_literal: true

FactoryBot.define do
  factory(:annotation, class: Annotation) do
    association :annotated, factory: :provider_account
    name { Annotation::SUPPORTED_ANNOTATIONS.sample }
    value { 'operator' }
  end
end
