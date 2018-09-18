namespace :liquid do
  desc "Deletes liquid templates that don't differ from the default ones."
  task :cleanup => :environment do
    defaults = {}

    Liquidizer.template_paths.each do |path|
      Dir["#{path}/**/*.liquid"].each do |file|
        name = file.gsub(/^#{Regexp.quote(path)}\/*/, '')
        name = name.gsub(/\.liquid$/, '')

        defaults[name] = File.read(file)
      end
    end

    LiquidTemplate.find_each(:include => :account) do |template|
      if dom_equal?(template.content, defaults[template.name])
        puts "Deleting template #{template.name} of #{template.account.try(:org_name) || '[deleted account]'}."

        template.destroy
      end
    end
  end

  TAG = /(\{%(.+?)%\})/
  VARIABLE = /(\{\{(.+?)\}\})/
  BOTH = /(\{(?:%|\{)\s*(.+?)\s*(?:\}|%)\})/
  FILTER = /\|\s*([^|]+)/

  desc 'Print names of all used liquid constructs in the databse'
  task :list => :environment do
    CMS::Template.find_each do |view|
      puts view.name

      (view.published || view.draft || '').scan(TAG) do |liquid|
        puts "  #{liquid.first}"
      end
    end
  end

  task :analyze => :environment do
    stops = %w(endif endcase endfor comment endcomment else endunless)

    hash = Hash.new{ |hash,key| hash[key] = 0 }

    tags = hash.dup
    vars = hash.dup
    filters = hash.dup

    [DynamicView, PagePartial].each do |model|
      model.find_each do |view|
        view.body.scan(BOTH) do |tag, content|
          next if stops.include?(content)

          case tag
          when TAG
            case content
            when /^(?:if|unless|case|when)\s+(\S+)/ # its var
              var = $1
              next if var =~ /^\d+$/

              # puts "VAR: #{var}"
              vars[var] += 1

            when /^for\s+.+?\s+in\s+(\S+)$/
              vars[$1] += 1

            else
              # puts "TAG: #{content}"
              tags[content] += 1
            end

          when VARIABLE

            content.scan(FILTER).flatten.map(&:strip).each do |name|
              # puts "FIL: #{name}"
              filters[name.split(':').first] += 1
            end

            content = content.split('|').first.strip
            next if content =~ /^".+?"$/ || content =~ /^'.+?'$/ || content == "''"

            # puts "VAR: #{content}"
            vars[content] += 1
          else
            raise "unknown"

          end

          #uses[content] += 1
        end
      end
    end

    def print(hash)
      hash.sort_by{ |k,v| v }.reverse.each do |name, used|
        puts used.to_s.ljust(5) + name
      end
    end

    puts "~~~ Filters ~~~"
    print filters
    puts

    puts "~~~ Tags ~~~"
    print tags
    puts

    puts "~~~ Vars ~~~"
    print vars
  end

  task :variables => :environment do
    done = []
    used = Liquidizer.template_paths.map do |path|
      Dir[path.join("*.liquid")].map do |file|
        file = File.expand_path(file)
        next if done.include?(file)
        done << file
        File.read(file).scan(BOTH).map do |match|
          next if match.last =~ /\.css/
          match.last.scan(/(\w+?\.\w+)/)
        end
      end
    end
    used.flatten!
    used.compact!
    used.uniq!
    used.sort!
    puts used
  end

end

# This is taken from ActionController::Assertions::DomAssertions#assert_dom_equal
def dom_equal?(one, two)
  dom_one = HTML::Document.new(one.to_s).root
  dom_two = HTML::Document.new(two.to_s).root
  ActionController::Assertions::DomAssertions.strip_whitespace!(dom_one.children)
  ActionController::Assertions::DomAssertions.strip_whitespace!(dom_two.children)

  dom_one == dom_two
end
