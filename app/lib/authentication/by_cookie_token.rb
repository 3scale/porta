module Authentication
  module ByCookieToken
    # Stuff directives into including module
    def self.included( recipient )
      recipient.extend( ModelClassMethods )
      recipient.class_eval do
        include ModelInstanceMethods
      end
    end

    #
    # Class Methods
    #
    module ModelClassMethods
    end # class methods

    #
    # Instance Methods
    #
    module ModelInstanceMethods
      def remember_token?
        (!remember_token.blank?) &&
          remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
      end

      # These create and unset the fields required for remembering users between browser closes
      def remember_me
        remember_me_for UserSession::TTL
      end

      def remember_me_for(time)
        remember_me_until time.from_now.utc
      end

      def remember_me_until(time)
        # TODO: Use update_columns when Rails 4
        self.update_column(:remember_token_expires_at, time)
        self.update_column(:remember_token, self.class.make_token)
      end

      # refresh token (keeping same expires_at) if it exists
      def refresh_token
        if remember_token?
          self.update_column(:remember_token, self.class.make_token)
        end
      end

      #
      # Deletes the server-side record of the authentication token.  The
      # client-side (browser cookie) and server-side (this remember_token) must
      # always be deleted together.
      #
      def forget_me
        self.remember_token_expires_at = nil
        self.remember_token            = nil
        self.class.where(id: id).update_all(:remember_token_expires_at => nil, :remember_token => nil) # TODO: replace by update_columns
      end

    end # instance methods
  end

  #
  #
  module ByCookieTokenController
    # Stuff directives into including module
    def self.included( recipient )
      recipient.extend( ControllerClassMethods )
      recipient.class_eval do
        include ControllerInstanceMethods
      end
    end

    #
    # Class Methods
    #
    module ControllerClassMethods
    end # class methods

    module ControllerInstanceMethods
    end # instance methods
  end
end

