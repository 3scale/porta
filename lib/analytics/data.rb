module Analytics

  class Data
    def initialize(service)
      @service = service
    end

    def countries
      @service.transactions.in_period(1.month.ago..Time.zone.now)
      .find(
      :all,
      :select => 'COUNT(`service_transactions`.id) counts, `service_transactions`.client_ip, `countries`.name country_name, `countries`.code code',
      :joins => 'LEFT JOIN `ip_geographies` as `ip` ON `service_transactions`.client_ip = `ip`.client_ip ' +
              'LEFT JOIN `countries` ON `ip`.client_country_code = `countries`.code',
      :group => '`ip`.client_country_code',
      :order => 'counts DESC',
      :limit => 20)
    end


  end

end
