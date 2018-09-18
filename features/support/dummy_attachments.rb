# BIG FAT WANING: requiring spec/mocks loads rspec mocking into all objects!
# require 'spec/mocks'

module DummyAttachments
  def dummy_css
    f = File.new(dummy_css_filename)
    f.stubs(:local_path).returns(dummy_css_filename)
    f
  end

  def dummy_css_filename
    File.join(Rails.root, 'test/', 'fixtures', 'test.css')
  end
end
