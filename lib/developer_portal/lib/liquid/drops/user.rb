# encoding: UTF-8

module Liquid
  module Drops
    class User < Drops::Model
      allowed_name :user, :users

      drop_example %{
        <h1>User {{ user.display_name }}</h1>
        <div>Account {{ user.account.name }}</div>
        <div>Username {{ user.username }}</div>
        <div>Email {{ user.email }}</div>
        <div>Website {{ user.website }}</div>
     }

      privately_include do
        # So that we can escape by #h in the drop
        include ERB::Util
      end

      def initialize(user)
        @user = user
        super
      end

      hidden
      def id
        @user.id.to_s
      end

      desc "Returns whether the user is an admin."
      example %{
        {% if user.admin? %}
          <p>You are an admin of your account.</p>
        {% endif %}
      }
      def admin?
        @user.admin?
      end

      desc "Returns the username of the user, HTML escaped."
      def username
        h(@user.username)
      end

      desc "Returns the account of the user."
      def account
        Liquid::Drops::Account.wrap(@user.account)
      end

      desc "Returns the first and last name of the user."
      def name
        h(@user.decorate.full_name)
      end

      # TODO: display name, really? reconsider
      hidden
      def display_name
        h(@user.decorate.display_name)
      end

      hidden
      def informal_name
        h(@user.decorate.informal_name)
      end

      hidden
      deprecated "Use **oauth2?** instead."
      def authentication_id
        @user.sso_authorizations.last.try(:uid) || @user.authentication_id
      end

      desc "Returns true if user has stored oauth2 authorizations"
      def oauth2?
        @user.signup.oauth2?
      end

      desc "Returns the email of the user."
      def email
        h(@user.email)
      end

      # TODO: looks like it is not used, remove
      hidden
      def email_unverified?
        @user.email_unverified?
      end

      hidden
      def invitation
        Drops::Invitation.new(@user.invitation)
      end

      desc "Returns true if user signed up with password"
      def using_password?
        @user.already_using_password?
      end

      desc %{
        This method will return `true` for users using the built-in
        Developer Portal authentication mechanisms and `false` for
        those that are authenticated via Janrain, CAS or other
        single-sign-on method.
      }
      example %{
        {{ if user.password_required? }}
          <input name="account[user][password]" type="password">
          <input name="account[user][password_confirmation]" type="password">
        {{ endif }}
      }
      def password_required?
        @user.signup.by_user?
      end

      desc "Returns the list of sections the user has access to."
      example %{
        {% if user.sections.size > 0 %}
          <p>You can access following sections of our portal:</p>
           <ul>
            {% for section in user.sections %}
              <li>{{ section }}</li>
            {% endfor %}
          </ul>
        {% endif %}
      }
      def sections
        @user.sections.map(&:full_path)
      end

      desc "Returns the role of the user."
      def role
        @user.role.to_s
      end

      class Role < Drops::Base
        def initialize(name, description)
          @name = name.to_s
          @description = description.to_s
        end

        desc "Returns internal name of the role, important for the system."
        def name
          @name
        end

        desc "Returns description of the role."
        def description
          @description
        end
      end

      def ==(second)
        if second.is_a?(Liquid::Drops::User)
          self.id == second.id
        else
          false
        end
      end

      desc "Returns a list of available roles for the user."
      example %{
        {% for role in user.roles_collection %}
          <li>
            <label for="user_role_{{ role.key }}">
              <input
                {% if user.role == role.key %}
                  checked="checked"
                {% endif %}
              class="users_ids" id="user_role_{{ role.key }}" name="user[role]" type="radio" value="{{ role.key }}">
              {{ role.text }}
            </label>
            </li>
          {% endfor %}
        }
      def roles_collection
        #HACK: we are leaving out contributor of the roles form, there is some issue
        # with removing contributor. TODO check contributor can be removed
        roles = ::User::DEFAULT_ROLES
        roles.map do |role|
          text = role.to_s.capitalize
          text << ' (all access)' if role == :admin
          if role == :member && ::Ability.new(::User.current).can?(:create_contributors, ::User.current.account)
            text << ' (access control by group)'
          end
          Role.new(role, text)
        end
      end

      desc "Returns the resource URL of the user."
      example %{
        {{ 'Delete' | delete_button: user.url }}
      }
      def url
        admin_account_user_path(@user)
      end

      desc "Returns the URL to edit the user."
      example %{
        {{ 'Edit' | link_to: user.edit_url, title: 'Edit', class: 'action edit' }}
      }
      def edit_url
        edit_admin_account_user_path(@user)
      end

      class Can < Drops::Base
        def initialize(user)
          @user = user
        end

        desc "Returns true if can be destroyed by current_user."
        def be_destroyed?
          ability.can?(:destroy, @user)
        end

        desc "Returns true if can be managed by current_user."
        def be_managed?
         ability.can?(:manage, @user)
        end

        desc "Returns true if role can be updated by current user."
        def be_update_role?
          ability.can?(:update_role, @user)
        end

        private

        def ability
          @ability ||= ::Ability.new(::User.current)
        end
      end


      desc "Gives access to permission methods."
      example %{
        {% if user.can.be_managed? %}
          <!-- do something -->
        {% endif %}
      }
      def can
        Can.new(@model)
      end

      desc "Returns non-hidden extra fields with values for this user."
      example "Print label and value of an existing extra field.", %{
        {{ user.extra_fields.oauth_token.label }}: {{ user.extra_fields.oauth_token.value }}
      }
      example "Print all extra fields.", %{
        {% for field in user.extra_fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def extra_fields
        Drops::Fields.extra_fields(@user)
      end

      desc "Returns all fields with values for this user."
      example "Print label and value of an existing field", %{
        {{ user.fields.country.label }}: {{ user.fields.country.value }}
      }
      example "Print all fields.", %{
        {% for field in user.fields %}
          {{ field.label }}: {{ field.value }}
        {% endfor %}
      }
      def fields
        Drops::Fields.fields(@user)
      end

      desc "Returns all built-in fields with values for this user."
      def builtin_fields
        Drops::Fields.builtin_fields(@user)
      end
    end
  end
end
