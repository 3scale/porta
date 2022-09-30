# frozen_string_literal: true

require 'test_helper'

class PaperclipTest < ActiveSupport::TestCase
  setup do
    @account = FactoryBot.build_stubbed(:simple_provider, s3_prefix: 'fake-s3-prefix')
    account.stubs(account: account)
  end

  attr_reader :account

  class S3StorageTest < PaperclipTest
    setup do
      default_options = Paperclip::Attachment.default_options.merge(
        storage: :s3,
        bucket: 'my-bucket',
        s3_region: 'us-east',
        path: ':rails_root/public/system/:url',
      )
      Paperclip::Attachment.stubs(default_options: default_options)
    end

    test 's3_domain_url' do
      attachment = Paperclip::Attachment.new(:attachment, account, url: ':url_root/:account_id/:class/:attachment/:style/:basename.:extension')
      attachment.stubs(original_filename: 'fake_attachment.png')

      assert_equal ':s3_path_url', attachment.options[:url]
      assert_equal "https://my-bucket.s3.amazonaws.com/fake-s3-prefix/#{account.id}/accounts/attachments/medium/fake_attachment.png", attachment.url(:medium)
    end

    test 'force_path_style' do
      Paperclip::Attachment.default_options[:s3_options] = { force_path_style: true }
      attachment = Paperclip::Attachment.new(:attachment, account, url: ':url_root/:account_id/:class/:attachment/:style/:basename.:extension')
      attachment.stubs(original_filename: 'fake_attachment.png')

      assert_equal "https://s3.amazonaws.com/my-bucket/fake-s3-prefix/#{account.id}/accounts/attachments/medium/fake_attachment.png", attachment.url(:medium)
    end

    test 'bucket name containing a dot' do
      Paperclip::Attachment.default_options[:bucket] = 'test.my-bucket'
      attachment = Paperclip::Attachment.new(:attachment, account, url: ':url_root/:account_id/:class/:attachment/:style/:basename.:extension')
      attachment.stubs(original_filename: 'fake_attachment.png')

      assert_equal "https://s3.amazonaws.com/test.my-bucket/fake-s3-prefix/#{account.id}/accounts/attachments/medium/fake_attachment.png", attachment.url(:medium)
    end
  end
end
