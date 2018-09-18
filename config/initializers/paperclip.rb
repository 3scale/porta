# Put any custom interpolations for paperclip here.
Paperclip.interpolates(:param) { |attachment, style| attachment.instance.to_param }
Paperclip.interpolates(:account_id) { |attachment, style| attachment.instance.account.id }

Paperclip.interpolates(:pid) { |attachment, style| Process.pid }

Paperclip.interpolates(:s3_provider_prefix) { |attachment, _| attachment.instance.s3_provider_prefix }

Paperclip.interpolates(:storage_root) do |attachment, style|
  storage_root = case (storage = attachment.options[:storage].to_sym)
                 when :filesystem
                   ':rails_root/public'.freeze
                 when :s3
                   ':s3_provider_prefix'.freeze
                 else
                   raise "unsupported storage class: #{storage}"
                 end
  Paperclip::Interpolations.interpolate(storage_root, attachment, style)
end

Paperclip.interpolates(:url_root) do |attachment, style|
  url_root = case (storage = attachment.options[:storage].to_sym)
             when :filesystem
               '/system/:s3_provider_prefix'.freeze
             when :s3
               ':s3_provider_prefix'.freeze
             else
               raise "unsupported storage class: #{storage}"
             end
  Paperclip::Interpolations.interpolate(url_root, attachment, style)
end

Paperclip.interpolates :date_partition do |attachment, style|
  instance = attachment.instance
  date = instance.respond_to?(:date) ? instance.date : instance.created_at || Time.now
  date.strftime("%Y/%m/%d")
end

Paperclip.interpolates :random_secret do |attachment, style|
  attachment.instance.random_secret
end

Paperclip.interpolates :s3_prefix do |attachment, style|
  # consider raising exception, when there is no prefix
  attachment.instance.provider.s3_prefix
end


begin
  CMS::S3.enable!
rescue CMS::S3::NoConfigError
  Rails.logger.warn "[WARN] S3 storage is not enabled." unless Rails.env.test?

  CMS::S3.stub! if Rails.env.test?
end

module Paperclip
  class MediaTypeSpoofDetector
    # TODO: Nice to have
    # delete this method, check validations,
    # maybe redefine only in some models
    def spoofed?
      false
    end
  end

  # Security Warning: this basically turns off the content type detection
  # based on the file contents. Not sure what we else we can do.
  class ContentTypeDetector
    def type_from_mime_magic
      @type_from_mime_magic ||= MimeMagic.by_path(@filepath).try(:type)
    end
  end
end
