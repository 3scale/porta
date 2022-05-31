# Patches dalli to use SHA256 checksum instead of MD5.
# Once we stop supporting Ruby 2.4, we should upgrade dalli
# and see if any configuration is needed for same effect.
#
# key digests were actually fixed with
# https://github.com/petergoldstein/dalli/commit/74b2625f11ff56dd6f55c7316bc115bc5a29be5f

Dalli::Client.prepend(Module.new do
  def validate_key(key)
    raise ArgumentError, "key cannot be blank" if !key || key.length == 0
    key = key_with_namespace(key)
    if key.length > 250
      digest = Digest::SHA256.hexdigest(key)
      truncated_key_separator = ':md5:'
      truncated_key_target_size = 249
      # replicating 3.x logic
      truncated_key_target_size = truncated_key_target_size + 1 if namespace
      max_length_before_namespace = truncated_key_target_size - truncated_key_separator.size - digest.size
      key = "#{key[0, max_length_before_namespace]}#{truncated_key_separator}#{digest}"
    end
    return key
  end
end)
