# frozen_string_literal: true

require 'test_helper'

module Annotating
  class ModelTest < ActiveSupport::TestCase
    class AnnotatedFeature < Feature
      annotated
    end

    class AnnotateTest < ModelTest
      test "creates a new annotation when it doesn't exist" do
        name = 'managed'
        value = 'operator'
        subject = AnnotatedFeature.new

        subject.annotations.expects(:build).with(name: name, value: value)

        subject.annotate(name, value)
      end

      test 'updates an annotation when it exists' do
        name = 'managed'
        value = 'admin'
        subject = AnnotatedFeature.new
        subject.annotate(name, 'operator')

        subject.annotate(name, value)

        assert_equal 1, subject.annotations.size
        assert_equal name, subject.annotations.first.name
        assert_equal value, subject.annotations.first.value
      end

      ['', ' ', nil].each do |value|
        test "removes an annotation when it's set to #{value.inspect}" do
          name = 'managed'
          subject = AnnotatedFeature.new
          subject.annotate(name, 'operator')

          subject.expects(:remove_annotation).with(name)

          subject.annotate(name, value)
        end
      end
    end

    class RemoveAnnotationTest < ModelTest
      test 'marks annotation for destruction' do
        name = 'managed'
        subject = AnnotatedFeature.new
        subject.annotate(name, 'operator')

        subject.remove_annotation(name)

        assert subject.annotations.first.marked_for_destruction?
      end
    end

    class AnnotationTest < ModelTest
      test 'returns the annotation model' do
        name = 'managed'
        subject = AnnotatedFeature.new
        subject.annotate(name, 'operator')

        result = subject.annotation(name)

        assert_instance_of Annotation, result
      end

      test "returns nil if it doesn't exist" do
        subject = AnnotatedFeature.new
        subject.annotate('managed', 'operator')

        result = subject.annotation('test')

        assert_nil result
      end
    end

    class ValueOfAnnotationTest < ModelTest
      test 'returns the annotation value' do
        name = 'managed'
        value = 'operator'
        subject = AnnotatedFeature.new
        subject.annotate(name, value)

        result = subject.value_of_annotation(name)

        assert_equal value, result
      end

      test "returns nil if it doesn't exist" do
        subject = AnnotatedFeature.new
        subject.annotate('managed', 'operator')

        result = subject.value_of_annotation('test')

        assert_nil result
      end
    end

    class AnnotationsTest < ModelTest
      test 'extracts the proper parameters from the given hash' do
        name = 'managed'
        value = 'operator'
        subject = AnnotatedFeature.new

        subject.expects(:annotate).with(name, value)

        subject.annotations=([{name: name, value: value}])
      end

      test 'annotates once per each received hash' do
        annotation = { name: 'managed', value: 'operator' }
        subject = AnnotatedFeature.new

        subject.expects(:annotate).times(3)

        subject.annotations=([annotation, annotation ,annotation])
      end
    end
  end
end
