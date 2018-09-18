module Fields
  class SignupForm
    REQUIRED_FIELDS = %w{ account[user][email] account[user][password]
                          account[org_name] account[subdomain]
                          account[self_subdomain] }.freeze

    OPTIONAL_FIELDS = %w{
      account[user][first_name] account[user][last_name]
      account[#user][extra_fields][API_Status_3s__c]
      account[extra_fields][API_Purpose_3s__c]
      account[extra_fields][API_Onprem_3s__c]
    }.freeze

    DEFAULT_FIELDS = (REQUIRED_FIELDS + OPTIONAL_FIELDS).map(&:freeze).freeze

    attr_reader :account, :user
    delegate :include?, :each, to: :@fields

    def initialize(account, user, fields)
      @account = account
      @user = user
      @fields = fields || DEFAULT_FIELDS
    end

    def user_fields
      UserFormFields.new(self)
    end

    def account_fields
      AccountFormFields.new(self)
    end

    def extra_field(name)
      extra_fields.fetch(name) { return nil }
    end

    def extra_fields
      @extra_fields ||= @account
                            .defined_extra_fields
                            .index_by { |field| field.name }
    end

    class FormFields < Struct.new(:signup_fields)
      delegate :include?, to: :signup_fields

      def extra_fields
        extra_fields_definitions
          .map { |fd| SignupExtraField.new(fd.attributes.dup) }
      end


      def extra_field_names
        raise 'should be overriden in subclasses'
      end

      private

      def extra_fields_definitions
        extra_field_names
          .map { |field_name| signup_fields.extra_field(field_name) }
          .compact
      end
    end

    class UserFormFields < FormFields

      def include?(name)
         super "account[user][#{name}]"
      end

      def extra_field_names
        signup_fields
          .each
          .map { |field_name| field_name.scan(/\[\#user\]\[extra_fields\]\[(\w+)\]/) }
          .flatten # two level array, flat_map is not enough
      end
    end

    class AccountFormFields < FormFields

      def include?(name)
        super "account[#{name}]"
      end

      def extra_field_names
        signup_fields
          .each
          .reject { |field_name| field_name.include?('[#user]') }
          .map { |field_name| field_name.scan(/\[extra_fields\]\[(\w+)\]/) }
          .flatten # two level array, flat_map is not enough
      end
    end
  end
end
