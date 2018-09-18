# Copyright (c) 2010, Nathaniel Ritmeyer. All rights reserved.
#
# http://www.natontesting.com
#
# Save this in a file called 'unused.rb' in your 'features/support' directory. Then, to list
# all the unused steps in your project, run the following command:
#
#   cucumber -d -f Cucumber::Formatter::Unused
#
# or...
#
#   cucumber -d -f Unused
require 'cucumber/formatter/stepdefs'

class Unused < Cucumber::Formatter::Stepdefs
  def self.replace_step_file(name, line_number)
    cutting = false
    result = []

    File.new(name).each_line.with_index do |l,i|
      cutting = true if (i == line_number)

      if cutting
        if (l =~ /^end$/)
          cutting = false
        end
      else
        result << l
      end
    end

    File.new(name, 'w').write(result.join(""))
  end


  def print_summary(features)
    add_unused_stepdefs
    keys = @stepdef_to_match.keys.sort {|a,b| a.regexp_source <=> b.regexp_source}
    puts "The following steps are unused...\n---------"

    keys.each do |key|
      if @stepdef_to_match[key].none?
        puts "#{key.file_colon_line} (#{key.regexp_source})"
        file, start = key.file_colon_line.split(':')
        Unused.replace_step_file(file,start.to_i - 1)
      end
    end
  end
end

# testing code
# Unused.replace_step_file('features/step_definitions/permissions.rb',11-1)
