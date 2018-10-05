import $ from 'jquery'

export class StatsStore {

  constructor (window) {
    this.window = window
    this._bindEvents()
  }

  save (state) {
    this.window.history.pushState(state, '', `#${JSON.stringify(state)}`)
  }

  load () {
    return JSON.parse(decodeURI(this.window.location.hash).replace('#', ''))
  }

  getStateFromURL () {
    if (this.window.location.hash.length > 0) {
      return this.load()
    }
  }

  triggerNavigationEvent () {
    $(this).triggerHandler('navigation')
  }

  _bindEvents () {
    $(this.window).on('popstate', () => this.triggerNavigationEvent())
  }
}
