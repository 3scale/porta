# frozen_string_literal: true
OpenSSL::X509::DEFAULT_CERT_FILE.tap do |file|
  ENV['SSL_CERT_FILE'] ||= file if File.exist?(file)
end

OpenSSL::X509::DEFAULT_CERT_DIR.tap do |dir|
  ENV['SSL_CERT_DIR'] ||= dir if Dir.exist?(dir)
end

if ActiveModel::Type::Boolean.new.cast(ENV['DISABLE_MD5_FOR_TESTING'])
  class OpenSSL::Digest
    send :remove_const, :MD5
    class MD5; end
  end
end
