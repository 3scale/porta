import { mount } from 'enzyme'

import { useCodeMirror } from 'ActiveDocs/useCodeMirror'

import type { FunctionComponent } from 'react'
import type { Doc, Editor } from 'codemirror'

const setValue = jest.fn()

const on: CodeMirror.Editor['on'] = jest.fn((_event, fn): void => {
  const instance = { getDoc: () => doc } as Editor
  const doc = { getValue: () => 'value' } as Doc

  fn(instance, {} as ClipboardEvent)
})

const fromTextArea = jest.fn(() => {
  return {
    setValue,
    on
  }
})

// @ts-expect-error Mocking CodeMirror
window.CodeMirror = { fromTextArea }

const HookedComponent: FunctionComponent<{ onChange: jest.Mock }> = ({ onChange }) => {
  useCodeMirror('hooked', 'apiJsonSpec', onChange)

  return (
    <textarea id="hooked" />
  )
}

it('should use the text area', () => {
  jest.spyOn(document, 'getElementById').mockImplementation((elementId: string): HTMLTextAreaElement | null => {
    if (elementId === 'hooked') return {} as HTMLTextAreaElement
    return null
  })

  const onChange = jest.fn()

  mount(<HookedComponent onChange={onChange} />)

  expect(fromTextArea).toHaveBeenCalledWith({}, expect.any(Object))
  expect(setValue).toHaveBeenCalledWith('apiJsonSpec')
  expect(onChange).toHaveBeenCalledWith('value')
})
