// @flow

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
    expect(article.classList.contains('u-closed')).toBe(true)
    toggle(article.id, article.classList, icon, 'u-closed')
    icon.click()
    expect(article.classList.contains('u-closed')).toBe(false)
  })

  it('returns function which removes the click event handler', () => {
    expect(article.classList.contains('u-closed')).toBe(true)
    let returnValue = toggle(article.id, article.classList, icon, 'u-closed')
    returnValue()
    icon.click()
    expect(article.classList.contains('u-closed')).toBe(true)
  })

  it('toggles class for the element', () => {
    expect(article.classList.contains('u-closed')).toBe(true)
    toggleState(article.id, article.classList, 'u-closed')
    expect(article.classList.contains('u-closed')).toBe(false)
  })

  it('recovers class from the storage', () => {
    expect(article.classList.contains('u-closed')).toBe(true)
    toggleState(article.id, article.classList, 'u-closed')
    expect(article.classList.contains('u-closed')).toBe(false)
    article.className = 'u-closed'
    expect(article.classList.contains('u-closed')).toBe(true)
    recoverState(article.id, article.classList, 'u-closed')
    expect(article.classList.contains('u-closed')).toBe(false)
  })

  it('allows for renaming the class', () => {
    expect(article.classList.contains('u-closed')).toBe(true)
    toggleState(article.id, article.classList, 'u-closed')
    expect(article.classList.contains('u-closed')).toBe(false)
    article.className = 'is-closed'
    moveState(article.id, 'u-closed', 'is-closed')
    recoverState(article.id, article.classList, 'is-closed')
    expect(article.classList.contains('is-closed')).toBe(false)
  })

  it('fires window resize event on click', () => {
    // $FlowIgnore[cannot-resolve-name]
    global.onresize = jest.fn()
    const event = jest.spyOn(global, 'onresize')
    toggle(article.id, article.classList, icon, 'toggle')

    icon.click()

    // $FlowIgnore[incompatible-call]
    expect(event).toHaveBeenCalled()
  })
})
