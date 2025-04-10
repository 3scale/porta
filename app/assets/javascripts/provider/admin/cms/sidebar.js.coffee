class Sidebar
  FOLDER_ICONS = ['fa-folder', 'fa-folder-open']
  ICON_SETS = [FOLDER_ICONS]
  HIGHLIGHT_CLASS = 'current'
  TOGGLE_SELECTOR = '[data-behavior~=toggle]'
  TOGGLE_ALL_BUTTON_SELECTOR = '#cms-sidebar-collapse-all'

  constructor: (@selector) ->

    @fire_ajax()

    @filter = new SidebarFilter(this)

    @hook(document)

    $ =>
      @element = $(@selector)

      @element
        .on 'click', TOGGLE_ALL_BUTTON_SELECTOR, (event) =>
          sections = @top_level_sections()
          all_packed = @all_items_packed()

          if all_packed
            sections.filter('.packed').each (_, element) -> SidebarToggle.get(element).unpack()
          else
            sections.filter(':not(.packed)').each (_, element) -> SidebarToggle.get(element).pack()

          @update_expand_collapse_button(!all_packed)

        .on 'click', TOGGLE_SELECTOR, (event) =>
          target = $(event.target)
          return unless target.is('.fa')
          ul = target.siblings('ul')
          return unless ul.length
          SidebarToggle.get(ul).toggle 300, (el) =>
            @update_expand_collapse_button()
          return false

        .on 'toggle:pack toggle:unpack', (event) ->
          icon = $(event.target).parent().children('.fa')
          for icon_set in ICON_SETS
            class_names = icon_set.map((class_name) -> ".#{class_name}").join(', ')
            icon.filter(class_names).toggleClass(icon_set.join(' '))

  top_level_sections: () ->
    root_section = $('#cms-sidebar-content ul .cms-section ul:first', @element)
    root_section.children(TOGGLE_SELECTOR).children('ul')

  all_items_packed: () ->
    top_level_sections = @top_level_sections()
    packed_sections = top_level_sections.filter('.packed')

    return packed_sections.length == top_level_sections.length

  expand_collapse_all_button: () ->
    @element.find(TOGGLE_ALL_BUTTON_SELECTOR)

  update_expand_collapse_button: (all_packed = @all_items_packed()) ->
    @expand_collapse_all_button().
      html(Sidebar.icon(if all_packed then 'plus-square' else 'minus-square'))

  fire_ajax: ->
    @ajax.abort() if @ajax
    @ajax = $.ajax('/p/admin/cms/templates/sidebar.json')
      .success (json) => @update(json)
      .error (xhr, status, error) ->
        console.error("#{xhr.status} #{error}")
        console.error(xhr.responseText)

  hook: (element) ->
    selector = @selector
    element = $(element)
    element
      .on 'cms-sidebar:update', (event) =>
        SidebarToggle.loadAndMarkPacked()
        @filter.filter()

        @update_expand_collapse_button()

      .on 'pjax:end cms-sidebar:update', (event) =>
        @highlight(window.location.pathname)

      .on 'mouseenter mouseleave', '.cms-sidebar-listing li > a', (event) ->
        $(this).parent().toggleClass('ui-state-hover')

  highlight: (path) ->
    @element.find("a.#{HIGHLIGHT_CLASS}").removeClass(HIGHLIGHT_CLASS)
    @element.find("a[href='#{path}']").addClass(HIGHLIGHT_CLASS)

  error_empty: ->
    @element.find('#cms-sidebar-error-empty')

  content: ->
    @element.find('#cms-sidebar-content')

  layouts: ->
    @element.find('#cms-sidebar-layouts')

  partials: ->
    @element.find('#cms-sidebar-partials')

  portlets: ->
    @element.find('#cms-sidebar-portlets')

  listings: ->
    @element.find('.cms-sidebar-listing')

  items: (filter) ->
    items = @listings().find('li')
    if filter? then items.filter(filter) else items

  update: (json) ->
    unless json
      @error_empty().show()
      return
    @groups = @group(json)
    @json = json

    content = @render_content(json.root.section)
    layouts = @render_layouts(@json.layouts)
    partials = @render_partials(@json.partials)
    portlets = @render_portlets(@json.portlets)

    $ =>
      @content().html(content)
      @layouts().html(layouts)
      @partials().html(partials)
      @portlets().html(portlets)

      @element.trigger('cms-sidebar:update')

  group: (json) ->
    {
      sections: Object.groupBy(json.sections, (n) => n.parent_id),
      pages: Object.groupBy(json.pages, (n) => n.section_id),
      files: Object.groupBy(json.files, (n) => n.section_id),
      builtins: Object.groupBy(json.builtins, (n) => n.section_id)
    }

  render_layouts: (layouts) =>
    data = {
      layouts: @json.layouts
    }

    SidebarTemplates.layouts(data)

  render_portlets: (portlets) =>
    data =
      portlets: @json.portlets

    SidebarTemplates.portlets(data)

  render_partials: (partials) =>
    data =
      partials: @json.partials

    SidebarTemplates.partials(data)

  render_content: (section) =>
    section_id = section.id

    data = {
      section: section,

      sections: @groups.sections[section_id],
      pages: @groups.pages[section_id],
      files: @groups.files[section_id],
      builtins: @groups.builtins[section_id],

      render: @.render_content
    }

    all = Array.from(
      new Set(data.sections)
        .union(new Set(data.pages))
        .union(new Set(data.files))
        .union(new Set(data.builtins))
      )
    section.empty = all.length == 0

    if section.parent_id || section.rendered
      SidebarTemplates.content(data)
    else
      section.rendered = true
      SidebarTemplates.root(data)

  @html = (element) ->
    element.clone().wrap('<div>').parent().html()

  @link_to = (text, path, title = text) ->
    title = " " if title is null
    title = title.join(' ') unless typeof(title) == 'string'
    Sidebar.html($('<a>', text: text, href: path, title: title))

  @icon = (icon, text) ->
    text = if text? then " " + text else ''
    Sidebar.html($('<i>', class: "fa fa-#{icon} fa-fw")) + text

  @icon_link_to = (icon, text, path, title = text) ->
    icon = Sidebar.icon(icon)
    link = Sidebar.link_to(text, path, title)

    Sidebar.html($(link).prepend(icon + ' '))

  @search = (item) ->
    """ data-search="#{item.search.string}" data-type="#{item.search.type}" data-origin="#{item.search.origin}" """

class SidebarToolbar
  ACTIVE = 'active'

  constructor: (@filter) ->
    $(document).on 'click', '[data-filter-type]', @process_type
    $(document).on 'click', '[data-filter-origin]', @process_origin

    $ =>
      types = @filter.status.types
      types = ['all'] if !types || types?.length == 0

      for type in types
        $("[data-filter-type=#{type}]").addClass(ACTIVE)

      if origin = @filter.status.origin || 'own'
        $("[data-filter-origin=#{origin}]").addClass(ACTIVE)

  process_type: (event) =>
    element = $(event.currentTarget)
    type = element.data('filter-type')
    items = element.siblings()
    all = items.filter('[data-filter-type=all]')

    if @filter.type(type)
      element.toggleClass(ACTIVE)
      all.removeClass(ACTIVE)
    else
      items.removeClass(ACTIVE)

      if element.data('filter-type') == 'all'
        element.addClass(ACTIVE)
      else
        element.removeClass(ACTIVE)
        all.addClass(ACTIVE)

  process_origin: (event) =>
    element = $(event.currentTarget)
    origin = element.data('filter-origin')
    @filter.origin(origin)
    element.addClass('active').siblings().removeClass('active')

class SidebarFilter
  CMS_FILTER_COOKIE_NAME = 'cms-filter-string'
  INPUT = '#cms-filter input'
  ALL = 'all'

  @serialized_status: ->
    $.cookie(CMS_FILTER_COOKIE_NAME, path: '/') || '{}'

  @load: ->
    @status ||= JSON.parse(@serialized_status())

  @save: (status) ->
    @status = status
    json = JSON.stringify(status)
    $.cookie(CMS_FILTER_COOKIE_NAME, json, {expires: 30, path: '/'})

  constructor: (@sidebar) ->
    @status = SidebarFilter.load()
    @toolbar = new SidebarToolbar(this)

    $(document).on 'keyup change search click', INPUT, (event) =>
      text = event.currentTarget.value
      @search(text)

    if query = @status.query
      $ -> $(INPUT).val(query)

  save: ->
    SidebarFilter.save(@status)

  filter: ->
    items = @sidebar.items('[data-behavior~="search"]')
    items.removeClass('matched not-matched')

    matched = items

    if query = @status.query
      matched = matched.filter("[data-search*=#{query}]")

    types = for type in @status.types || []
      matched.filter("[data-type~=#{type}]").toArray()
    if types.length > 0
      union_types = Array.from types.reduce(
        (result, current) -> result.union(new Set(current)),
        new Set
      )

      matched = $(_(matched.toArray()).intersection(union_types))

    if origin = @status.origin
      matched = matched.filter("[data-origin~=#{origin}]")

    matched.show().addClass('matched')

    not_matched = _(items.toArray()).difference(matched.toArray())
    $(not_matched).hide().addClass('not-matched')

    items.filter('.cms-section:has(.matched)').show()

    listings = @sidebar.listings().removeClass('empty')
    listings.filter(':not(:has(.matched))').addClass('empty')

  type: (type) ->
    types = @status.types ||= []
    index = types.indexOf(type)

    if type == ALL
      types = []
    else if index >= 0
      types.splice(index, 1)
    else
      types.push(type)

    @status.types = types

    @filter()
    @save()

    types.length > 0

  origin: (origin) ->
    origin = null if origin == ALL

    @status.origin = origin

    @filter()
    @save()

  search: (string) ->
    if string == ""
      delete @status.query
    else
      @status.query = string

    @filter()
    @save()

class SidebarTemplates
  @root: ({ section, render }) ->
           """
           <ul>
             <li class="cms-section" data-behavior="toggle search">
               <span id="cms-sidebar-collapse-all" class="collapse-button"><i class="folder-open-o fa-fw"></i></span>
               #{ Sidebar.link_to(section.title, section.edit_path) }
               #{ render(section) }
             </li>
             <li class="no-results">No Content Found</li>
           </ul>
           """
  @content: ({ section, pages, files, builtins, sections, render }) ->
              """
              <ul id="cms-sidebar-section-#{ section.id }">
                #{ unless pages then '' else pages.reduce((items, page) ->
                      items += """
                      <li class="cms-page" data-id="#{ page.id }" data-behavior="drag search" data-param="cms_page" #{ Sidebar.search(page) }>
                        #{ Sidebar.icon_link_to('file', page.title, page.edit_path, [page.path, """(#{page.title})"""]) }
                      </li>
                      """
                , '')}

                #{ unless files then '' else files.reduce((items, file) ->
                      items += """
                        <li class="cms-file" data-id="#{ file.id }" data-behavior="drag search" data-param="cms_file" #{ Sidebar.search(file) }>
                          #{ Sidebar.icon_link_to('paperclip', file.attachment_file_name, file.edit_path) }
                        </li>
                      """
                , '')}

                #{ unless builtins then '' else builtins.reduce((items, builtin) ->
                      items += """
                        <li class="cms-builtin" data-id="#{ builtin.id }" data-behavior="drag search" data-param="cms_builtin" #{ Sidebar.search(builtin) }>
                          #{ Sidebar.icon_link_to('cog', builtin.title, builtin.edit_path) }
                        </li>
                      """
                , '')}

                #{ unless sections then '' else sections.reduce((items, section) ->
                      items += """
                        <li class="cms-section" data-id="#{ section.id }" data-behavior="toggle drag search" data-param="cms_section" #{ Sidebar.search(section) }>
                          #{ Sidebar.icon('folder-open fa-fw') }
                          #{ Sidebar.link_to(section.title, section.edit_path) }
                          #{ render(section) }
                        </li>
                      """
                , '')}
              </ul>
              """
  @layouts: ({ layouts }) ->
              """
              <h3>Layouts</h3>
              <ul>
                #{ unless layouts then '' else layouts.reduce((items, layout) ->
                      items += """
                        <li #{ Sidebar.search(layout) } data-behavior="search">
                          #{ Sidebar.icon_link_to('code', layout.title, layout.edit_path) }
                        </li>
                      """
                , '')}
                #{ if layouts?.length == 0 then '<li data-behavior="search">No Layouts</li>' else '' }
                <li class="no-results">No Layouts Found</li>
              </ul>
              """
  @portlets: ({ portlets }) ->
               """
               <h3>Portlets</h3>
               <ul>
                 #{ unless portlets then '' else portlets.reduce((items, portlet) ->
                   items += """
                     <li #{ Sidebar.search(portlet) }>
                       #{ Sidebar.icon_link_to('rocket', portlet.title, portlet.edit_path) }
                     </li>
                   """
                 , '')}
                 #{ if portlets?.length == 0 then '<li data-behavior="search">No Portlets</li>' else '' }
                 <li class="no-results">No Portlets Found</li>
               </ul>
               """
  @partials: ({ partials }) ->
               """
               <h3>Partials</h3>
               <ul>
                 #{ unless partials then '' else partials.reduce((items, partial) ->
                   items += """
                     <li #{ Sidebar.search(partial) } data-behavior="search">
                       #{ Sidebar.icon_link_to('puzzle-piece', partial.system_name, partial.edit_path) }
                     </li>
                   """
                 , '')}
                 #{ if partials?.length == 0 then '<li data-behavior="search">No Partials</li>' else '' }
                 <li class="no-results">No Partials Found</li>
               </ul>
               """

class SidebarToggle
  COOKIE_NAME = 'cms-toggle-ids'

  @loadAndMarkPacked: ->
    existing = []
    for id in SidebarToggle.load()
      element = $('#' + id)

      if element.length > 0
        existing.push(id)
        @get(element).pack(0)

  @get: (element) ->
    el = $(element)
    el.data('toggle') || new SidebarToggle(el)

  constructor: (@el) ->
    throw new Error('SidebarToggle needs an element') unless @el
    @id = @el.attr('id')
    throw new Error('SidebarToggle needs element with an ID') unless @id
    @el.data('toggle', this)

  save: ->
    ids = SidebarToggle.load()

    if @el.hasClass('packed')
      ids.push(@id) if ids.indexOf(@id) < 0
      @el.trigger('toggle:pack')
    else
      i = ids.indexOf(@id)
      ids.splice(i, 1) if i >= 0
      @el.trigger('toggle:unpack')

    unless _(ids).isEqual(SidebarToggle.load())
      SidebarToggle.save(ids)

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

document.addEventListener 'DOMContentLoaded', () -> new Sidebar('#cms-sidebar')
