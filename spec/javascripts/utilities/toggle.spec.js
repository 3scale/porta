import { toggle, toggleState, recoverState, moveState } from 'utilities/toggle'

describe('Toggle', () => {
  let icon, article

  beforeEach(() => {
    localStorage.clear()
    icon = document.createElement('i')
    article = document.createElement('div')
    article.className = 'u-closed'
    article.setAttribute('id', 'article')
  })

  it('attaches the click event handler to the icon element', () => {
    expect(article).toHaveClass('u-closed')
    toggle(article.id, article.classList, icon, 'u-closed')
    icon.click()
    expect(article).not.toHaveClass('u-closed')
  })

  it('returns function which removes the click event handler', () => {
    expect(article).toHaveClass('u-closed')
    let returnValue = toggle(article.id, article.classList, icon, 'u-closed')
    returnValue()
    icon.click()
    expect(article).toHaveClass('u-closed')
  })

  it('toggles class for the element', () => {
    expect(article).toHaveClass('u-closed')
    toggleState(article.id, article.classList, 'u-closed')
    expect(article).not.toHaveClass('u-closed')
  })

  it('recovers class from the storage', () => {
    expect(article).toHaveClass('u-closed')
    toggleState(article.id, article.classList, 'u-closed')
    expect(article).not.toHaveClass('u-closed')
    article.className = 'u-closed'
    expect(article).toHaveClass('u-closed')
    recoverState(article.id, article.classList, 'u-closed')
    expect(article).not.toHaveClass('u-closed')
  })

  it('allows for renaming the class', () => {
    expect(article).toHaveClass('u-closed')
    toggleState(article.id, article.classList, 'u-closed')
    expect(article).not.toHaveClass('u-closed')
    article.className = 'is-closed'
    moveState(article.id, 'u-closed', 'is-closed')
    recoverState(article.id, article.classList, 'is-closed')
    expect(article).not.toHaveClass('is-closed')
  })

  it('fires window resize event on click', () => {
    let event = spyOnEvent(window, 'resize')
    toggle(article.id, article.classList, icon, 'toggle')

    icon.click()

    expect(event).toHaveBeenTriggered()
  })
})
