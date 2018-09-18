require 'test_helper'

class CMS::FileTest < ActiveSupport::TestCase

  test 'downloadable url for s3 should contain the filename in the metadata' do
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))

    @file = Factory.build(:cms_file, downloadable: true)

    url = @file.url
    assert_match(/amazonaws/, url) # Check that is a amazon url

    filename = CGI.escape(%[filename="#{@file.attachment.original_filename}"])
    assert_match(/#{filename}/, url)
    assert_match /X-Amz-Signature/, url
  end

  test 'url for s3 should contain signature' do
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))

    url = Factory.build_stubbed(:cms_file, downloadable: false).url

    assert_match(/amazonaws/, url) # Check that is a amazon url
    assert_match /X-Amz-Signature/, url
  end

  test 'path should be normalized' do
    @file = Factory.build(:cms_file, :path => " do whatever / you want ")
    assert @file.invalid?
    assert_equal "/do-whatever/you-want", @file.path
    assert_valid @file
  end

  test 'detects correct content type for css' do
    file = CMS::File.new

    file.attachment = Rails.root.join('test', 'fixtures', 'test.css').open

    assert_equal 'text/css', file.attachment_content_type
  end

  def test_attachment_path_is_utc

    hypnotoad = Rails.root.join('test', 'fixtures', 'hypnotoad.jpg').open
    pacific = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]

    file = Factory(:cms_file)
    file.provider.update_attribute(:timezone, pacific.name)

    Time.use_zone pacific do
      Timecop.freeze(Time.utc(2012)) do
        file.attachment = hypnotoad

        assert_equal Time.zone.now, file.attachment_updated_at
        assert_equal Date.new(2012), file.date

        assert_match '/2012/01/01/', file.attachment.path
      end
    end
  end

  def test_path
    file = CMS::File.new

    file.path = 'foo'
    assert_equal '/foo', file.path

    file.path = '/bar'
    assert_equal '/bar', file.path
  end
end
