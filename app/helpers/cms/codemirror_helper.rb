module CMS
  module CodemirrorHelper
    def codemirror_loaded!
      @_codemirror_loaded = true
    end

    def codemirror_loaded?
      !!@_codemirror_loaded
    end

    # Disabling codemirror by URL parameter is an undocumented
    # and unsupported feature known only to Flighstats by now (Aug
    # 3/2012). It should probably be removed when we introduce a CMS API.
    #
    def codemirror_disabled?
      params[:cm] == '0'
    end

    def codemirror_params
      if params[:cm].present?
        { :cm => params[:cm] }
      else
        {}
      end
    end

  end
end
