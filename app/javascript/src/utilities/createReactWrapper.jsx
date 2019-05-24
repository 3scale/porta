// @flow

import { render } from 'react-dom'

export function createReactWrapper <ElementType: React$ElementType> (element: React$Element<ElementType>, target: string | Element) {
  let container: ?Element

  if (typeof target === 'string') {
    container = document.getElementById(target)

    if (container == null) {
      throw new Error(`${target} is not part of the DOM`)
    }
  } else {
    container = target
  }

  render(element, container)
}
