import * as index from 'services/index'

describe('Services index', () => {
  beforeEach(() => {
    // document.cookie = 'cms-toggle-ids=; path=/; expires=Thu, 21 Sep 1979 00:00:01 UTC;'
    localStorage.clear()
    const basicStructure = `
      <div id='widget_1' class='service-widget is-closed'>
        <article>
          <p id='title_1' class='title-toggle'>Title</p>
          <button class='button-to edit'>Edit</button>
          <div id='service_1' class='content-service'>Article</div>
        </article>
      </div>
      <div id='widget_2' class='service-widget is-closed'>
        <article>
          <p id='title_2' class='title-toggle'>Title</p>
          <button class='button-to edit'>Edit</button>
          <div id='service_2' class='content-service'>Article</div>
        </article>
      </div>`

    document.body.innerHTML = basicStructure
  })

  it('attaches the click event to the title-toggle element', () => {
    const widget = document.body.querySelector('#widget_1')
    const toggle = widget.querySelector('#title_1')

    expect(widget.classList.contains('is-closed')).toBe(true)
    index.initialize()
    toggle.click()
    expect(widget.classList.contains('is-closed')).toBe(false)
  })
})
