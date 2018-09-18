module ThreeScale
  module Middleware

    class Multitenant
      def self.log(message)
        Rails.logger.debug "[MultiTenant] #{message}" if ENV['DEBUG']
      end

      class TenantChecker
        attr_reader :original, :attribute

        class TenantLeak < StandardError
          def initialize(object, attribute, original)
            @object, @attribute, @original = object, attribute, original
          end

          def to_s
            "#{@object.class}:#{@object.id} has #{@attribute} #{@object.send(@attribute).inspect} but #{@original.inspect} already exists."
          end
        end

        def initialize(attribute, app, env)
          @original = nil
          @attribute = attribute
          @app = app
          @env = env
        end

        def verify!(object)

	         # this controller shouldnt be checked
          return true if @env["action_controller.request.path_parameters"]["controller"] == "provider/domains"

          unless object.respond_to?(attribute)
            # Multitenant.log "#{object} does not respond to: #{attribute}"
            return true
          end


          begin
            current = object.send(attribute)
          rescue ActiveRecord::MissingAttributeError
            # Multitenant.log("#{object} is missing #{attribute}. Reloading and trying again")
            fresh = object.class.send(:with_exclusive_scope){ object.class.find(object.id, :select => attribute) }
            current = fresh.send(attribute)
          end

          if current.nil?
            # Multitenant.log "#{object} #{attribute} is nil. Skipping."
            return true
          else
            @original ||= current

            if current == original
              # Multitenant.log "verified object #{object} (#{attribute}: #{original} == #{current})"

            else

              # we still need to check if it's master before raising a tenant leak
              @cookie_store ||= find_cookie_store(@app)
              @session ||= @cookie_store.send(:load_session, @env)

              @master ||= Account.find_by_sql(["SELECT * FROM accounts WHERE master = ?", true]).first

              if user_id = @session.last[:user_id].presence
                @users ||= {}
                @users[user_id] ||= User.find_by_sql(["SELECT * FROM users WHERE id = ? AND account_id = ?", user_id, @master.id]).present?
                return if @users[user_id]
              end

              return if @env["action_controller.request.query_parameters"]["provider_key"] == @master.api_key

              raise TenantLeak.new(object, attribute, original)
            end
          end
        end

        private

        # these middlewares have a funny recursion
        def find_cookie_store(app)
          if app.is_a? ActionDispatch::Session::CookieStore
            app
          else
            find_cookie_store(app.instance_variable_get('@app'))
          end
        end
      end

      module EnforceTenant
        # adding after_initialize does not work, it would have to be done for every model
        def after_initialize
          enforce_tenant!
          super if defined?(super)
        end

        private
        def enforce_tenant!
          # Multitenant.log "initialized object #{self.class}:#{self.id}"
          Thread.current[:multitenant].try!(:verify!, self)
        end
      end

      def initialize(app, attribute)
        @app = app
        @attribute = attribute
        ActiveRecord::Base.send(:include, EnforceTenant)
      end

      def call(env)
        dup._call(env)
      end

      def _call(env)
        Thread.current[:multitenant] = TenantChecker.new(@attribute,@app,env)
        @app.call(env)
      ensure
        Thread.current[:multitenant] = nil
      end
    end
  end
end
