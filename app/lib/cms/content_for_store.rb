module CMS
  class ContentForStore

    def initialize
      @store = Hash.new{|hash,key| hash[key] = "" }
    end

    def []=(key,value)
      @store[key] += value
    end

    def [](key)
      @store[key]
    end

  end
end
