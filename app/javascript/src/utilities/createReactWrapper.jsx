// @flow

import { render } from 'react-dom'

export function createReactWrapper <ElementType: React$ElementType> (element: React$Element<ElementType>, containerId: string) {
  const container = document.getElementById(containerId)

  if (container == null) {
    throw new Error(`${containerId} is not part of the DOM`)
  }

  render(element, container)
}
