import { render } from 'react-dom'

export function createReactWrapper<ElementType extends React.ElementType> (
  element: React.ReactElement<React.ComponentProps<ElementType>>,
  containerId: string
): void {
  const container = document.getElementById(containerId)

  if (container == null) {
    throw new Error(`${containerId} is not part of the DOM`)
  }

  render(element, container)
}
