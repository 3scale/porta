#!/usr/bin/env ruby


require 'objspace'


# set_trace_func proc { |event, file, line, id, binding, classname|
#   if classname == 'Account'
#     printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#   end
# }


# $file = File.new('diff.rb')
$classes = []


module HyperMegaProfiler

  def puts_diff
    new = $classes[-1]
    old = $classes[-2]
    diff = {}

    new.each_pair do |k,v|
      delta = v[:count] - (old[k] ? old[k][:count] : 0)
      diff[k] = delta if delta != 0
    end

    puts "DIFF: #{diff.sort.inspect}"
    # diff.sort {|a,b| a[1][:count] <=> b[1][:count]}
  end

  def count_objects
    # count = 0
    # ObjectSpace.each_object do |o|
    #   count += 1
    # end
    # puts "--------------------"

    # $count = ObjectSpace.count_objects($count ||= {})

    # mem = system('ps -o rss= -p   #{Process.pid}'.to_i)

    # puts "------- Objects #{$count.inspect}"
    # puts "------- Mem #{mem}"

    new = {}

    ObjectSpace.each_object do |o|
      key = o.class.to_s

      if val = new[key]
        val[:count] += 1
        val[:size] += ObjectSpace.memsize_of(o)
        val[:names] += ", #{o.org_name}" if o.respond_to?(:org_name)
      else
        new[key] = {
          count: 1,
          size: ObjectSpace.memsize_of(o),
          names: o.respond_to?(:org_name) ? o.org_name : ''
        }
      end
    end

    $classes << new
  end
end


include HyperMegaProfiler


now = Date.new(2012,12,1)
Cinstance.update_all('paid_until = NULL')
bs = Account.find(34576).billing_strategy

bs.account.buyer_accounts.all( :limit => 5).each do |buyer|
  bs.bill_fixed_costs(buyer, now)
  bs.bill_variable_costs(buyer, now - 1.month)
  ObjectSpace.garbage_collect
  count_objects
  puts_diff if $classes.size > 1
  puts '-------------'
end
