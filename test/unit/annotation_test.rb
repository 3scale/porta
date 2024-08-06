# frozen_string_literal: true

require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase
  test 'not supported annotations are not allowed' do
    subject = Annotation.new

    subject.name = 'not_supported'

    assert_not subject.valid?
    assert subject.errors[:name].present?
    assert subject.errors[:name].include? 'is not included in the list'
  end

  test ':name is mandatory' do
    subject = Annotation.new

    assert_not subject.valid?
    assert subject.errors[:name].present?
    assert subject.errors[:name].include? "can't be blank"
  end

  test 'a valid :name is accepted' do
    subject = Annotation.new

    subject.name = 'managed'
    subject.valid?

    assert_not subject.errors[:name].present?
  end

  test ':annotated is mandatory' do
    subject = Annotation.new

    assert_not subject.valid?
    assert subject.errors[:annotated].present?
    assert subject.errors[:annotated].include? "must exist"
  end

  test 'a valid :annotated is accepted' do
    subject = Annotation.new

    subject.annotated = Account.new
    subject.valid?

    assert_not subject.errors[:annotated].present?
  end
end
