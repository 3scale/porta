module ThreeScale
  module OAuth2
    class UserData

      ATTRIBUTES = %i[email email_verified username uid org_name kind authentication_id id_token].freeze

      # @param [ThreeScale::OAuth2::ClientBase] client
      def self.build(client)
        attributes = {
          email: client.email,
          email_verified: client.email_verified?,
          username: client.username,
          uid: client.uid,
          org_name: client.org_name,
          kind: client.kind,
          authentication_id: client.authentication_id,
          id_token: client.id_token
        }
        new(attributes)
      end

      def initialize(attributes = {})
        @attributes = attributes.assert_valid_keys(*ATTRIBUTES).freeze
      end

      ATTRIBUTES.each do |attribute|
        define_method(attribute) do
          @attributes[attribute]
        end
      end

      def verified_email
        email if email_verified?
      end

      def email_verified?
        email && email_verified
      end

      # Return User attributes
      def to_hash
        {
          email: email,
          username: username
        }
      end

      # Return all attributes
      def to_h
        @attributes
      end

      def ==(other)
        to_h == other.to_h
      end

      delegate :[], to: :@attributes
    end
  end
end
