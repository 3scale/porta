class ReplaceLiquidTagsInLayout < ActiveRecord::Migration
  TAGS      = %w(essential_assets logo flash submenu footer)
  ODD_BALLS = { "widget" => "user_widget", "m" => "menu", "colour_settings" => "color_settings" }

  def self.up
    #PageTemplate.find_all_by_name('main_layout').each do |template|
    #  class << template
    #    def save!(perform_validations=false)
    #      save(perform_validations) || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
    #    end
    #  end
    #
    #  TAGS.each {|v| template.body.gsub!(/\{\{\s*#{v}\s*\}\}/, "{% #{v} %}")}
    #  ODD_BALLS.each {|k,v| template.body.gsub!(/\{\{\s*#{k}\s*\}\}/, "{% #{v} %}")}
    #  template.body.gsub!(/\{\{\s*content_for_layout\s*\}\}/, "{% container main %}\n{% container sidebar %}")
    #
    #
    #  template.save!
    #
    #  puts "Parsed Template #{template.id}"
    #end
  end

  def self.down
  end
end
