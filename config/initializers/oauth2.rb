OAuth2::MACToken.prepend(Module.new do
  # this is a copy of original method but without using MD5 to
  # enable FIPS environment compatibility.
  # see https://github.com/oauth-xx/oauth2/pull/587
  def header(verb, url)
    timestamp = Time.now.utc.to_i
    nonce = Digest::SHA256.hexdigest([timestamp, SecureRandom.hex].join(':'))

    uri = URI.parse(url)

    raise(ArgumentError, "could not parse \"#{url}\" into URI") unless uri.is_a?(URI::HTTP)

    mac = signature(timestamp, nonce, verb, uri)

    "MAC id=\"#{token}\", ts=\"#{timestamp}\", nonce=\"#{nonce}\", mac=\"#{mac}\""
  end
end)
