module PaymentGateways
  class OgoneCrypt < PaymentGatewayCrypt

    DEFAULT_EXPIRATION_DATE = Date.new(2099, 12, 01)
    DEFAULT_EXPIRATION_DATE_PARAM = DEFAULT_EXPIRATION_DATE.strftime("%m%y") # "1299"

    attr_reader :url
    attr_accessor :fields, :field_names, :payment_gateway_options

    def initialize(user)
      super
      @payment_gateway_options = @provider.payment_gateway_options
      @url = "https://secure.ogone.com/ncol/#{test? ? 'test' : 'prod'}/orderstandard.asp".freeze
    end

  def fill_fields(return_url)
    @fields = {}
    @fields['PSPID']      = payment_gateway_options[:login]
    @fields['orderID']    = "#{user.first_name}_#{Time.now.to_i}"
    @fields['amount']     = '1'
    @fields['alias']      = buyer_reference
    @fields['aliasusage'] = "Your data will be used for future chargements"
    @fields['currency']   = provider.currency
    @fields['language']   = 'en_US'
    @fields['operation']  = 'RES'
    @fields['accepturl']  = return_url
    @fields['cancelurl']  = return_url
    @fields['declineurl']  = return_url
    @fields['exceptionurl']  = return_url
    @fields['SHASign']    = SHASign(@fields, payment_gateway_options[:signature])
  end

  def success?(params)
    parameters_to_sign = params.dup
    %w{action controller SHASIGN}.each{|excluded| parameters_to_sign.delete excluded}

    params.upcase_keys['STATUS'] == '5' &&
      SHASign(parameters_to_sign, payment_gateway_options[:signature_out]) ==  params["SHASIGN"]
  end

    def upcase_keys(hash)
      upcase_keys!(hash.dup)
    end

    def upcase_keys!(params)
      params.keys.each do |key|
        self[(key.upcase rescue key) || key] = params.delete(key)
      end
      self
    end

    def update_user(params)
      expiration_date = params.upcase_keys['ED']
      expiration_date = DEFAULT_EXPIRATION_DATE_PARAM if expiration_date.blank?
      account.credit_card_expires_on_month = expiration_date[0..1]
      account.credit_card_expires_on_year =  "20#{expiration_date[2..3]}"

      account.credit_card_partial_number = params.upcase_keys['CARDNO'][-4..-1]
      account.credit_card_auth_code = buyer_reference
      account.save!
    end


    def SHASign(fields, signature)
      f = fields.delete_if{|k, v| v.blank? }
      capitalized_hash = {}
      fields.each do |k, v|
        capitalized_hash[k.upcase]=v
      end
      datastring = capitalized_hash.keys.sort.collect do |key|
        "#{key}=#{capitalized_hash[key]}"
      end.join(signature)

      Digest::SHA1.hexdigest("#{datastring}#{signature}").upcase
    end
  end
end
