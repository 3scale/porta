# TODO: Extract this into a gem.

module StringHacks
  # Opposite of ActiveSupport's to_sentence.
  #
  # == Examples
  #
  #   > ''.from_sentence
  #   []
  #
  #   > 'alice'.from_sentence
  #   ['alice']
  #
  #   > 'alice and bob'.from_sentence
  #   ['alice', 'bob']
  #
  #   > 'alice, bob and claire'
  #   ['alice, 'bob', 'claire']
  #
  #   # You get the idea...
  def from_sentence
    split(/ and |,/).map(&:strip).reject(&:blank?)
  end
end

String.send(:include, StringHacks)
