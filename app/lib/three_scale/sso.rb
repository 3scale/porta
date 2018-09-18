# encoding: utf-8
module ThreeScale

  module SSO

    SEPARATOR= "⚡"
    VERSION  = "SSO-rb"

    # This generates a random sso key that looks like some Hex stuff
    def self.generate_sso_key
      SecureRandom.hex 32
    end

    # We get shorter tokens here
    class Serializer

      def self.load value
        Zlib::Inflate.inflate(value).force_encoding "UTF-8"
      end

      def self.dump value
        Zlib::Deflate.deflate value
      end
    end

    class ValidationError < StandardError; end

    # This should not know much about our data model
    #   generation_time is not actually used for anything.
    class Encryptor

      #
      # Parameters:
      #   sso_key     -> 3scale provides this
      #   expires_in  -> for how many seconds from now this key will be valid, defaults to 10 minutes from now (600 seconds)
      def initialize sso_key, expires_at= Time.now.utc + 10.minutes
        @expires_at = expires_at
        @me = ActiveSupport::MessageEncryptor.new [sso_key].pack("H*"), serializer: ThreeScale::SSO::Serializer
      end

      # Decrypts the <tt>token</tt> do'h
      def decrypt_token token
        @me.decrypt_and_verify(token).split ThreeScale::SSO::SEPARATOR
      end

      # This extracts and returns the values as passed to <tt>encrypt_token</tt>
      # It also checks if the token is expired.
      def extract! token
        raw = decrypt_token token
        values = raw.slice! 3..(raw.size-3)

        raw = raw - ["Ra", ThreeScale::SSO::VERSION, "zZ"]
        generation_time, expiration_time = raw.map{ |t| Time.at(t.to_f) }

        raise ValidationError.new("Token expired.") if expiration_time < Time.now.utc

        values
      end

      # Generates an encrypted token from the <tt>args</tt>
      def encrypt_token *args
        raw = ["Ra", ThreeScale::SSO::VERSION, "%10.5f" % Time.now.utc, @expires_at, "zZ"]
        raw.insert 3, *args
        @me.encrypt_and_sign raw.join(ThreeScale::SSO::SEPARATOR)
      end
    end
  end
end
