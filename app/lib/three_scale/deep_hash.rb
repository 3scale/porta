# use case:
# * hash = ThreeScale::DeepHash.new(whatever: {nested: 'hash'})
# * hash.whatever.nested == "hash"

class ThreeScale::DeepHash < BasicObject
  def initialize(hash)
    @hash = hash
  end

  def [](val)
    __get__(val)
  end

  def method_missing(method, *)
    return super unless @hash.has_key?(method.to_s)
    __get__(method)
  end

  def inspect
    "<#ThreeScale::DeepHash:@hash=#{@hash.inspect}>"
  end

  private
  def __get__(key)
    value = @hash.fetch(key.to_s)

    if value.is_a?(::Hash)
      ::ThreeScale::DeepHash.new(value)
    elsif value.is_a?(::Array)
      value.map{ |value| ::ThreeScale::DeepHash.new(value) }
    else
      value
    end
  end
end
