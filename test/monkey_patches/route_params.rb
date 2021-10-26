# frozen_string_literal: true

# TODO: remove when you see similar error but actual format is: "format"=>:json
# PARAMS_TO_SYMBOLIZE causes errors in the tests regarding the format.
# It always converts format to symbol which causes a failure in the tests:
# Stats::Api::ApplicationsController should route GET /stats/api/applications/42/usage.json
# --- expected
# +++ actual
# @@ -1 +1 @@
# -{"application_id"=>"42", "action"=>"usage", "format"=>:json, "controller"=>"stats/api/applications"}
# +{"controller"=>"stats/api/applications", "action"=>"usage", "application_id"=>"42", "format"=>"json"}
module Shoulda
  module Matchers
    module ActionController
      class RouteParams
        PARAMS_TO_SYMBOLIZE = [].freeze
      end
    end
  end
end
