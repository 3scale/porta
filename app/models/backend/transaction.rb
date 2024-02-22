# frozen_string_literal: true

# Used by Stats tests and backend random data generator
module Backend
  class Transaction
    attr_accessor :id, :estimated_usage, :provider_account_id, :created_at, :service_id, :cinstance_id, :log

    attr_writer :user_key

    delegate :application_id, to: :cinstance_data

    def initialize(attributes = {})
      self.attributes = attributes
    end

    def self.report!(params = {})
      transaction = new(params)
      transaction.report!
      transaction
    end

    def self.usage_status(provider_account_id, cinstance_id, service_id, options = {})
      CinstanceData.new(provider_account_id, cinstance_id, service_id).status(options)
    end

    def report!
      self.created_at ||= Time.zone.now

      cinstance_data.validate_state!
      usage_accumulator.validate!(:additional_usage  => usage)

      self.usage = estimated_usage if usage.empty?
      aggregate
      true
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

    private

    def attributes=(attributes)
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def cinstance_data
      @cinstance_data ||= CinstanceData.new(provider_account_id, cinstance_id, @service_id)
    end

    def usage_accumulator
      @usage_accumulator ||= cinstance_data.usage_accumulator
    end

    def aggregate
      Stats::Aggregation.aggregate(:service    => service_id,
                                   :cinstance  => application_id,
                                   :created_at => created_at,
                                   :usage      => usage,
                                   :log        => log
                                  )
    end
  end
end
