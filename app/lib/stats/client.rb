module Stats
  class Client < Base
    include Views::Usage
    include Views::Total

    def initialize(cinstance)
      @cinstance = cinstance
      super(cinstance.service, cinstance)
    end

    def usage(options)
      super
    end

    def client
      account = @cinstance.user_account

      {:client_name => account.org_name,
       :client_id   => account.id,
       :plan_name   => @cinstance.plan.name }
    end

    def source_key
      [@cinstance.service, {:cinstance => @cinstance.application_id}]
    end
  end
end
