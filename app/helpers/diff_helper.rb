module DiffHelper

  def diff_widget(diff)
    stats = diff.stats
    changes = stats.map{ |key, count| pluralize(count, key.to_s) }.presence
    title = changes ? changes.to_sentence : "no changes"

    content_tag :span, :class => :diff, :title => title do
      concat content_tag(:span, "+#{stats[:addition]}", :class => :plus)
      concat content_tag(:span, "-#{stats[:deletion]}", :class => :minus)
    end
  end
end
