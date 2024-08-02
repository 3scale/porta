# frozen_string_literal: true

require 'test_helper'

class AnnotatingTest < ActiveSupport::TestCase

  class AnnotatedFeature < Feature
    annotated
  end

  test 'includes the proper modules' do
    %w[Annotating::Model Annotating::ManagedBy].each do |mod|
      assert_includes AnnotatedFeature.ancestors.map(&:name), mod
    end
  end

  test '#models returns the annotated models' do
    %w[Account Service BackendApi].each do |model|
      assert_includes Annotating.models.map(&:name), model
    end
  end
end
