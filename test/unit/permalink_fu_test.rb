# encoding: utf-8
require 'test_helper'

class BaseModel
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  include PermalinkFu

  attr_accessor :id
  attr_accessor :title
  attr_accessor :extra
  attr_accessor :permalink
  attr_accessor :foo
  attr_reader :errors

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  def new_record?
    !id
  end

  def self.where(scope)
    @scope = scope
    @count = 0
    self
  end

  def self.count
    @count
  ensure
    @count += 1
  end
end

class MockModel < BaseModel
  has_permalink :title
end

class ScopedModel < BaseModel
  has_permalink :title, :scope => :foo
end

class MockModelExtra < BaseModel
  has_permalink [:title, :extra]
end

class PermalinkFuTest < MiniTest::Unit::TestCase
  @@samples = {
    'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title-1-well-not-really',
    '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
    'āčēģīķļņū' => 'acegiklnu'
  }

  @@extra = { 'some-)()()-ExtRa!/// .data==?>    to \/\/test' => 'some-extra-data-to-test' }

  def test_should_escape_permalinks
    @@samples.each do |from, to|
      assert_equal to, PermalinkFu.escape(from)
    end
  end

  def test_should_escape_activerecord_model
    @m = MockModel.new
    @@samples.each do |from, to|
      @m.title = from; @m.permalink = nil
      assert @m.valid?
      assert_equal to, @m.permalink
    end
  end

  def test_multiple_attribute_permalink
    @m = MockModelExtra.new
    @@samples.each do |from, to|
      @@extra.each do |from_extra, to_extra|
        @m.title = from; @m.extra = from_extra; @m.permalink = nil
        assert @m.valid?
        assert_equal "#{to}-#{to_extra}", @m.permalink
      end
    end
  end

  def test_should_not_check_itself_for_unique_permalink
    @m = MockModel.new
    @m.id = 2
    @m.permalink = 'bar-2'
    assert @m.valid?
    assert_equal 'bar-2', @m.permalink
  end

  def test_validate_permalink
    model = MockModelExtra.new
    model.title = 'Морковковедение'
    refute model.valid?
    assert_equal ['title or extra must contain latin characters'], model.errors[:base]
    assert model.permalink.blank?

    model.title += ' monde féérique'
    assert model.valid?
    assert_equal 'monde-feerique', model.permalink
  end

  def test_generate_empty_permalink
    model = MockModelExtra.new
    assert_nil model.title
    assert_nil model.extra
    refute model.valid?
    assert '', model.permalink
  end
end
