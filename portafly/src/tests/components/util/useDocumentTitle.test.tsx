import * as React from 'react'
import { render } from 'tests/custom-render'
import { useDocumentTitle } from 'components'

const SamplePage = () => {
  useDocumentTitle('This is a test title')

  return null
}

describe('useDocumentTitle tests', () => {
  test('should change the document title', async () => {
    const { container } = render(<SamplePage />)
    expect(container.ownerDocument!.title).toBe('This is a test title')
  })
})
