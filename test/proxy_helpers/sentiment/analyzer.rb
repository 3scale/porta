class Analyzer

  MAX_SENTENCE_LEN = 100

  def initialize

    @wordmap = {}
    f = File.new("data/working_AFINN-111.txt")

    while line = f.gets
      word, value = line.split(" ")
      @wordmap[word.strip] = value.strip.to_i
    end

  end


  def word(word)
    vw = sanitize(word)
    raise InvalidParameters, "\"#{word}\" is not a single word" if vw.size>1

    return {:word => word, :sentiment => @wordmap[vw.first] || 0 }
  end

  def sentence(sentence)
    vw = sanitize(sentence)
    raise InvalidParameters, "sentence is too long" if vw.nil? || vw.size > MAX_SENTENCE_LEN

    total = 0
    cont = 0

    vw.each do |word|
      if !@wordmap[word].nil?
        total=total+ @wordmap[word].to_f
        cont=cont+1
      end
    end

    return {:sentence => sentence, :count => vw.size, :sentiment => cont>0 ? total/cont.to_f : 0, :certainty => cont/vw.size.to_f}
  end


  def add_word(word, value)
    vw = sanitize(word)
    raise InvalidParameters, "\"#{word}\" is not a single word" if vw.size>1

    value = value.to_i
    raise InvalidParameters, "incorrect value, must be -5 to -1 for negative or to +1 to +5 for positive connotations" if value<-5 || value>5 || value==0

    Mutex.new.synchronize do
      @wordmap[vw.first] = value
      f = File.new("data/working_AFINN-111.txt","a+")
      f.puts "#{vw.first} #{value}"
      f.close
    end

    word(word)
  end

  private

  def sanitize(string)
    raise InvalidParameters, "failure to sanitize: #{string}" if string.to_s.empty?

    result = []
    string = string.gsub(/[^[:alnum:]]/, ' ')
    string.split(' ').each do |word|
      result << word.downcase.strip
    end

    raise InvalidParameters, "failure to sanitize: #{string}, returns empty set" if result.size==0

    result
  end

end

class InvalidParameters < RuntimeError
end
