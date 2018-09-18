module Liquid
  module Drops
    class Account < Drops::Model

      info %{
A developer account. See `User` drop if you are looking for the email addresses or similar information.
      }

      drop_example %{
        <h1>Account organization name {{ current_account.name }}</h1>
        <div>Plan {{ current_account.bought_account_plan.name }}</div>
        <div>Telephone {{ current_account.telephone_number }}</div>

        <div>{{ current_account.fields_plain_text }}</div>
        <div>{{ current_account.extra_fields_plain_text }}</div>

        {% if current_account.approval_required? %}
           <p>This account requires approval.</p>
        {% endif %}

        {% if current_account.credit_card_required? %}

          {% if current_account.credit_card_stored? %}
            <p>This account has credit card details stored in database.</p>
          {% else %}
            <p>Please enter your {{ 'credit card details' | link_to: urls.payment_details }}.</p>
          {% endif %}

          {% if current_account.credit_card_missing? %}
            <p>This account has no credit card details stored in database.</p>
          {% endif %}
        {% endif %}
      }

      allowed_name :account, :current_account
      deprecated_name :buyer_account, :user_account, :buyer, :sender, :provider

      desc "Returns the id of the account."
      def id
        @model.id
      end

      desc "Returns the organization name of the developer's account."
      def name
        @model.name
      end

      desc "Returns account's display name"
      def display_name
        @model.display_name
      end

      desc "Returns a text about a VAT zero."
      def vat_zero_text
        @model.vat_zero_text
      end

      desc "Return the VAT rate."
      def vat_rate
        @model.vat_rate
      end

      desc "Returns the unread messages."
      def unread_messages
        @unread_messages ||= @model.received_messages.unread
        Liquid::Drops::Message.wrap(@unread_messages)
      end

      desc "Returns the latest messages."
      def latest_messages
        @latest_messages ||= @model.received_messages.latest
        Liquid::Drops::Message.wrap(@latest_messages)
      end

      desc "Returns the plan the account has contracted."
      def bought_account_plan
        Drops::AccountPlan.new(@model.bought_account_plan)
      end

      desc "Returns the contract account."
      def bought_account_contract
        Drops::Contract.new(@model.bought_account_contract)
      end

      hidden
      # DEPRECATED
      def bought_plan
        Drops::Plan.new(@model.bought_plan)
      end

      def credit_card_display_number
        @model.credit_card_display_number
      end

      def credit_card_expiration_date
        @model.credit_card_expires_on_with_default.strftime("%B, %Y") unless @model.provider_account.payment_gateway_type == :authorize_net
      end

      desc "Returns whether the account is required to enter credit card details."
      def credit_card_required?
        @model.credit_card_needed?
      end

      hidden
      # TODO: remove after deploy
      def credit_card_needed?
        credit_card_required?
      end

      desc "Returns whether the account has credit card details stored."
      def credit_card_stored?
        @model.credit_card_stored?
      end

      desc "Returns whether the account has no credit card details stored."
      def credit_card_missing?
        !credit_card_stored?
      end

      hidden
      #TODO: provider only
      # FIXME: logic in drop?
      desc "Returns whether this provider account requires credit card from it's buyers"
      def requires_credit_card?
        @model.billing_strategy.try(:needs_credit_card?)
      end

      desc 'Returns whether this buyer needs to edit credit card because of bought paid plans'
      def requires_credit_card_now?
        @model.requires_credit_card_now?
      end

      desc "Returns timezone of this account."
      deprecated "Please use `provider.timezone` instead."
      def timezone
        source = @model.buyer? ? @model.provider_account : @model
        Drops::TimeZone.new(source.timezone)
      end

      desc "Returns whether the account has at least a paid contract."
      def paid?
        @model.paid?
      end

      desc "Returns whether the account is in the trial period, i.e. all paid contracts are in the trial period."
      def on_trial?
        @model.on_trial?
      end

      desc "Returns the telephone number of the account."
      def telephone_number
        @model.telephone_number
      end

      desc "Returns whether the account requires approval."
      def approval_required?
        @model.approval_required?
      end

      desc "Returns UNIX timestamp of account creation (signup)."
      example "Converting timestamp to JavaScript Date.", %{
        <script>
          var data = new Date({{ account.created_at }} * 1000);
        </script>
      }
      def created_at
        @model.created_at.to_i
      end

      desc "Returns legal address, city and state."
      def full_address
        @model.full_address
      end

      desc "Returns the applications of the account."
      def applications
        Drops::Application.wrap(@model.bought_cinstances.includes(:service))
      end

      desc "Returns an array with ServiceContract drops."
      def subscribed_services
        Drops::ServiceContract.wrap(@model.bought_service_contracts)
      end

      desc "Returns the country of the account."
      def country_name
        @model.country_name
      end

      desc "Returns the admin user of this account."
      def admin
        Drops::User.new admin_user
      end

      # TODO: extract to module ExtraFields::Drop
      #
      desc "Returns the extra fields defined for the account as plain text."
      def extra_fields_plain_text
        result = ''
        #TODO: move all these condition inside the each_pair iterator
        if @model.extra_fields.present?
          @model.extra_fields.each_pair do |name, value|
            if @model.field(name).present? &&
                @model.field(name).visible_for?(admin_user)
              result << "* #{@model.field_label(name)}: #{value}\n"
            end
          end
        end
        result
      end

      # TODO: hide it from docs?
      desc "Returns the fields defined for the account as plain text."
      def fields_plain_text
        result = ''
        if @model.defined_fields.present?
          @model.defined_fields.each do |field|
            if @model.field(field.name).present? && field.visible_for?(admin_user)
              result << "* #{@model.field_label(field.name)}: #{@model.field_value(field.name)}\n"
            end
          end
        end
        result
      end

      desc "Returns extra fields with values of this account."
      example "Print one extra field.", %{
        Your OAuth token: {{ account.extra_fields.oauth_token }}
      }
      example "Print label and value of extra field.", %{
        {{ account.extra_fields.my_field.label }}: {{ account.extra_fields.my_field.value }}
      }
      example "Print all extra fields.", %{
        {% for field in account.extra_fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def extra_fields
        Drops::Fields.extra_fields(@model)
      end

      desc "Returns all fields with values of this account."
      example "Print one field.", %{
        Country: {{ account.fields.country }}
      }
      example "Print label and value of field.", %{
        {{ account.fields.country.label }}: {{ account.fields.country.value }}
      }
      example "Print all fields.", %{
        {% for field in account.fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def fields
        Drops::Fields.fields(@model)
      end

      def builtin_fields
        Drops::Fields.builtin_fields(@model)
      end

      def multiple_applications_allowed?
        @model.multiple_applications_allowed?
      end

      desc "Returns the billing address of this account."
      def billing_address
        @__billing_address ||= ::Liquid::Drops::BillingAddress.new @model
      end

      desc "Returns whether this account has a billing address or not."
      def has_billing_address?
        @model.has_billing_address?
      end

      class Can < Liquid::Drop
        def initialize(account)
          @account = account
        end

        def be_updated?
          ability.can?(:update, @account)
        end

        def be_deleted?
          ability.can?(:destroy, @account)
        end

        private
          def ability
            @ability ||= ::Ability.new(::User.current)
          end
      end

      desc "Give access to permission methods."
      example %{
        %{ if account.can.be_deleted? %}
          <!-- do something -->
        {% endif %}
      }
      def can
        Can.new(@model)
      end

      def edit_url
        edit_admin_account_path
      end

      def edit_ogone_billing_address_url
        edit_admin_account_ogone_path
      end

      hidden
      def edit_payment_express_billing_address_url
        ''
      end

      def edit_braintree_blue_credit_card_details_url
        edit_admin_account_braintree_blue_path
      end

      def edit_stripe_billing_address_url
        edit_admin_account_stripe_path
      end

      def edit_adyen12_billing_address_url
        edit_admin_account_adyen12_path
      end

      private

      def admin_user
        @model.admins.first
      end
    end
  end
end
