class Toggle
  COOKIE_NAME = 'cms-toggle-ids'

  @loadAndMarkPacked: ->
    existing = []
    for id in Toggle.load()
      element = $('#' + id)

      if element.length > 0
        existing.push(id)
        @get(element).pack(0)

  @get: (element) ->
    el = $(element)
    el.data('toggle') || new Toggle(el)

  constructor: (@el) ->
    throw new Error('ThreeScale.Toggle needs an element') unless @el
    @id = @el.attr('id')
    throw new Error('ThreeScale.Toggle needs element with an ID') unless @id
    @el.data('toggle', this)

  save: ->
    ids = Toggle.load()

    if @el.hasClass('packed')
      ids.push(@id) if ids.indexOf(@id) < 0
      @el.trigger('toggle:pack')
    else
      i = ids.indexOf(@id)
      ids.splice(i, 1) if i >= 0
      @el.trigger('toggle:unpack')

    unless _(ids).isEqual(Toggle.load())
      Toggle.save(ids)

  pack: (speed) ->
    @el.slideUp speed, =>
      @el.addClass('packed')
      @save()

  unpack: (speed) ->
    @el.slideDown speed, =>
      @el.removeClass('packed')
      @save()

  toggle: (speed, callback) ->
    @el.slideToggle speed, =>
      @el.toggleClass('packed')
      @save()
      if 'function' == typeof callback
        callback.call this, @el

  # private

  @serialized_ids: ->
    $.cookie(COOKIE_NAME, path: '/') || '[]'

  @save: (ids) ->
    @cached_ids = ids
    $.cookie(COOKIE_NAME, JSON.stringify(ids), {expires: 30, path: '/'})

  @load: ->
    @cached_ids ||= JSON.parse(@serialized_ids())
    @cached_ids.slice(0)

window.ThreeScale.Toggle = Toggle
