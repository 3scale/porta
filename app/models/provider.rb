module Provider
  extend self

  # Way to find providers not breaking Demeter's Law!
  # @param [Integer] id
  # @return Account
  delegate :find, to: :all

  def all
    Account.providers_with_master
  end
end
