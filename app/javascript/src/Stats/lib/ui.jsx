import $ from 'jquery'
import diff from 'virtual-dom/diff'
import patch from 'virtual-dom/patch'
import h from 'virtual-dom/h'
import createElement from 'virtual-dom/create-element'

export class StatsUI {
  static dom (el, props, ...children) {
    return h(el, props, children)
  }

  constructor ({statsState, container}) {
    this.element = null
    this.tree = null
    this.statsState = statsState
    this.container = container

    this._bindEvents()
  }

  render () {
    let tree = this.template()
    let rootNode = createElement(tree)
    this._appendNodeToContainer(rootNode, this.container)

    this.element = rootNode
    this.tree = tree
  }

  template () {
    throw new Error('It should implement template method in subclasses.')
  }

  refresh () {
    let newTree = this.template()
    let patches = diff(this.tree, newTree)
    this.element = patch(this.element, patches)
    this.tree = newTree
  }

  _appendNodeToContainer (node, container) {
    if (container) {
      $(container).append(node)
    } else {
      throw new Error('There was no container provided.')
    }
  }

  _bindEvents () {
    $(this.statsState).on('refresh pagination series', () => this.refresh())
  }

  _setState (state, topics) {
    this.statsState.setState(state, topics)
  }
}
