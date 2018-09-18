class Fields::BaseField
  #TODO: builtin and type look like they can be removed
  attr_accessor :name, :label, :type, :required, :choices, :hint, :hidden, :options

  alias hidden? hidden

  def initialize(opts = {})
    options = opts.symbolize_keys
    self.name = options[:name]
    self.label = options[:label]
    self.required = options[:required]
    self.choices = options[:choices]
    self.hint = options[:hint]
    self.hidden = options[:hidden]
    self.options = options.slice(:as, :label, :required, :hint, :input_html, :wrapper_html).freeze
  end

  def label=(val)
    val ||= name.to_s.humanize
    @label = val
  end

  def type=(val)
    val ||= :text
    @type = val
  end

  def required=(val)
    val ||= false
    @required = val
  end

  def choices=(val)
    @choices = val.presence
  end

  def builder_options
    opts = options.dup
    opts[:required] = true if required
    opts[:label] = label if label
    opts[:type] = type if type
    opts[:hint] = hint if hint
    opts[:collection] = choices if choices
    opts
  end

  def input(builder)
    raise "Need to implement in subclasses"
  end

end
