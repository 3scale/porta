# frozen_string_literal: true

module CMS
  module CodemirrorHelper
    # Disabling codemirror by URL parameter is an undocumented
    # and unsupported feature known only to Flighstats by now (Aug
    # 3/2012). It should probably be removed when we introduce a CMS API.
    #
    def codemirror_disabled?
      params[:cm] == '0'
    end
  end
end
