# frozen_string_literal: true

require 'test_helper'

class AnnotatingTest < ActionDispatch::IntegrationTest

  class AnnotatedFeature < Feature
    annotated
  end

  class AnnotatingController < ApplicationController
    def update
      @annotated_feature = AnnotatedFeature.find params[:id]
      annotations = params.permit(annotations: {})
      @annotated_feature.update(annotations)
    end
  end

  def with_test_routes
    Rails.application.routes.draw do
      put '/test/update' => 'annotating_test/annotating#update'
    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end

  class Update < AnnotatingTest
    setup do
      @annotated_feature = AnnotatedFeature.new
      @annotated_feature.save!
    end

    test "creates a new annotations when it doesn't exist" do
      name = 'managed_by'
      value = 'operator'

      with_test_routes do
        put '/test/update', params: { id: @annotated_feature.id, annotations: { "#{name}": value } }
      end

      annotations = @annotated_feature.reload.annotations
      assert 1, annotations.size
      assert_equal name, annotations.first.name
      assert_equal value, annotations.first.value
    end

    test 'updates an existing annotation' do
      name = 'managed_by'
      value = 'admin'

      @annotated_feature.annotations << Annotation.new.tap do |a|
        a.name = name
        a.value = 'operator'
      end
      @annotated_feature.save!

      with_test_routes do
        put '/test/update', params: { id: @annotated_feature.id, annotations: { "#{name}": value } }
      end

      annotations = @annotated_feature.reload.annotations
      assert 1, annotations.size
      assert_equal name, annotations.first.name
      assert_equal value, annotations.first.value
    end

    ['', ' ', nil].each do |value|
      test "removes an annotation when it's set to #{value.inspect}" do
        name = 'managed_by'

        @annotated_feature.annotations << Annotation.new.tap do |a|
          a.name = name
          a.value = 'operator'
        end
        @annotated_feature.save!

        with_test_routes do
          put '/test/update', params: { id: @annotated_feature.id, annotations: [{ name: name, value: value }] }
        end

        annotations = @annotated_feature.reload.annotations
        assert 0, annotations.size
      end
    end
  end
end
