class ThreeScale::Address

  ALLOWED_ATTRIBUTES = [ :name, :line1, :line2, :city, :zip, :state, :country , :phone ]

  attr_accessor *ALLOWED_ATTRIBUTES
  attr_accessor :errors

  delegate :blank?, to: :line1

  def initialize(*args)
    ALLOWED_ATTRIBUTES.each do |attr|
      if attr == :country
        value = args.shift

        if value.is_a?(Integer)
          self.country_id = value
        else
          self.country = value
        end
      else
        self.send("#{attr}=", args.shift)
      end
    end
  end

  def self.account_mapping
    [ %w(org_name name),
      %w(org_legaladdress line1),
      %w(org_legaladdress_cont line2),
      %w(city city),
      %w(zip zip),
      %w(state_region state),
      %w(country_id country_id),
      %w(telephone_number phone),
    ]
  end

  def self.mapping(prefix)
    ALLOWED_ATTRIBUTES.map do |attr|
      [ "#{prefix}_#{attr}", attr.to_s ]
    end
  end


  def country_id=(id)
    # HACK: We have non-existent country id's in the DB - (242, 81,
    # 78). We can remove the fallback when those id's are fixed
    @country = ::Country.find_by_id(id).try!(:name) || ''
  end


  def to_hash
    ALLOWED_ATTRIBUTES.inject({}) do |hash, key|
      hash[key] = self[key]
      hash
    end
  end

  # Quacking like Hash makes BillingAddress compatible with
  # ActiveMerchant. See AuthorizeNetCimGateway#add_address for interface.
  #
  def [](key)
    case key
    when :company then @name
    when :address then [ @address1, @address2 ].compact.join("\n")
    when :phone_number then @phone
    when :city, :country, :state, :zip then self.send(key)
    end
  end

end
