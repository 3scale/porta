module Backend
  class Transaction # this stuff is used by the stats tests, beware
    attr_accessor :estimated_usage
    attr_accessor :id
    attr_accessor :provider_account_id
    attr_accessor :created_at
    #TODO: there's some duplication between this and delegate :to => :cinstance_data
    attr_accessor :service_id
    attr_accessor :client_ip
    attr_accessor :cinstance_id
    attr_accessor :log          # hash with the log info

    attr_writer :user_key
    attr_writer :confirmed

    delegate :provider_verification_key, :plan_name, :application_id,
             :service_id, :to => :cinstance_data

    def initialize(attributes = {})
      @confirmed = false

      self.attributes = attributes
    end

    def self.find(service_id, id)
      find_by_id(service_id, id) || raise(TransactionNotFound)
    end

    def self.find_by_id(service_id, id)
      attributes = storage.get_object(storage_key(service_id, id))
      attributes && new(attributes.merge(:id => id))
    end

    def self.report!(params = {})
      transaction = new(params)
      transaction.report!
      transaction
    end

    # Report multiple transactions at the same time.
    #
    # Transaction.report_multiple!(@provider_account.id,
    #                              '0' => {:user_key => @user_key_one,
    #                                      :usage => {'hits' => 1},
    #                                      :client_ip => "1.2.3.4"},
    #                              '1' => {:user_key => @user_key_two,
    #                                      :usage => {'hits' => 1},
    #                                      :client_ip => "1.2.3.5"})
    def self.report_multiple!(provider_account_id, raw_transactions)
      reporter = MultiReporter.new(provider_account_id)
      reporter.report!(raw_transactions)
    end

    def self.usage_status(provider_account_id, cinstance_id, service_id, options = {})
      CinstanceData.new(provider_account_id, cinstance_id, service_id).status(options)
    end

    def report!
      self.created_at ||= Time.zone.now

      if cinstance_data.anonymous_clients_allowed?
        ensure_cinstance_exists
      else
        cinstance_data.validate_state!
        usage_accumulator.validate!(:additional_usage  => usage)
      end

      if confirmed?
        confirm!
      else
        save_to_storage
      end

      true
    end

    def confirm!(params = {})
      self.attributes = params
      self.usage = estimated_usage if usage.empty?
      self.confirmed = true

      aggregate
      delete_from_storage

      true
    end

    def cancel!(params = {})
      delete_from_storage
    end

    def user_key
      @user_key || client_ip
    end

    def confirmed?
      @confirmed
    end

    def usage=(possibly_unparsed_data)
      if possibly_unparsed_data.is_a?(NumericHash)
        @usage = possibly_unparsed_data
      else
        @usage = nil
        @unparsed_usage = possibly_unparsed_data
      end
    end

    def usage
      @usage ||= if @unparsed_usage
                   cinstance_data.process_usage(@unparsed_usage)
                 else
                   NumericHash.new
                 end
    end

    def cinstance=(cinstance)
      self.cinstance_id        = cinstance.id
      self.provider_account_id = cinstance.provider_account.id
      self.user_key            = cinstance.user_key
      self.service_id          = cinstance.service.id
    end

    def storage
      self.class.storage
    end

    def self.storage
      @@storage ||= Backend::Storage.instance
    end

    def storage_key
      self.class.storage_key(@service_id, id)
    end

    def self.storage_key(service_id, id)
      "transactions/#{id}"
    end

    def to_param
      id && id.to_s
    end

    def to_xml(options = {})
      xml = options[:builder] || ThreeScale::XML::Builder.new

      xml.transaction do |xml|
        xml.id_(to_param)
        xml.provider_verification_key(provider_verification_key)
        # It's called contract_name to keep backwards compatibility.
        xml.contract_name(plan_name)
      end

      xml.to_xml
    end

    private

    def attributes=(attributes)
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def generate_id
      storage.incr(Service.find(@service_id).preffix_key('transactions/counter'))
    end

    def cinstance_data
      @cinstance_data ||= CinstanceData.new(provider_account_id, cinstance_id, @service_id)
    end

    def usage_accumulator
      @usage_accumulator ||= cinstance_data.usage_accumulator
    end

    def save_to_storage
      @id ||= generate_id

      storage.set_object(storage_key, :provider_account_id => provider_account_id,
                                      :service_id => service_id,
                                      :user_key => user_key,
                                      :estimated_usage => usage,
                                      :created_at => created_at,
                                      :client_ip => client_ip)
      storage.expire(storage_key, 1.day)
    end

    def delete_from_storage
      storage.del(storage_key) if id
    end

    def aggregate
      Stats::Aggregation.aggregate(:service    => service_id,
                                   :cinstance  => application_id,
                                   :created_at => created_at,
                                   :client_ip  => client_ip,
                                   :usage      => usage,
                                   :log        => log,
                                  )
    end
  end
end
