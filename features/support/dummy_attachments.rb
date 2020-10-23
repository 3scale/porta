# frozen_string_literal: true

# BIG FAT WANING: requiring spec/mocks loads rspec mocking into all objects!
# require 'spec/mocks'

module DummyAttachments
  def dummy_css
    file = File.new(dummy_css_filename)
    file.stubs(:local_path).returns(dummy_css_filename)
    file
  end

  def dummy_css_filename
    Rails.root.join('test/fixtures/test.css')
  end
end
