# frozen_string_literal: true

module Logic
  module Authentication

    DUMMY_PARAMS = {
      '1' => { :user_key => 'USER_KEY' },
      '2' => { :app_id => 'APP_ID', :app_key => 'APP_KEY' },
      'oauth' => { :app_id => 'APP_ID', :app_key => 'APP_KEY' }
    }

    module Service
      def plugin_authentication_params
        @plugin_authentication_params ||= if (app = self.cinstances.first)
                                            app.plugin_authentication_params
                                          else
                                            DUMMY_PARAMS[backend_version]
                                          end
      end
    end

    module ApplicationContract
      def oauth?
        self.service && self.service.backend_version == 'oauth'
      end

      def plugin_authentication_params
        if self.service
          if self.service.backend_version == '1'
            { :user_key => self.user_key }
          else
            { :app_id => self.application_id, :app_key => self.keys.first }
          end
        end
      end
    end
  end
end
