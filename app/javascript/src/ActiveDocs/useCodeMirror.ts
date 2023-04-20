import 'codemirror/lib/codemirror.css'
import 'codemirror/theme/neat.css'
import 'codemirror/mode/javascript/javascript'
import CodeMirror from 'codemirror'
import { useEffect } from 'react'

import type { Editor } from 'codemirror'

import '../../packs/codemirror-cms.scss'

const useCodeMirror = (textAreaId: string, initialValue: string, onChange: (value: string) => void): void => {
  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- We're sure this is safe
    const textarea = document.getElementById(textAreaId)! as HTMLTextAreaElement
    const editor = CodeMirror.fromTextArea(textarea, {
      // @ts-expect-error TS is complaining, TODO: check @types/codemirror version so it matches with codemirror version
      matchBrackets: true,
      autoCloseBrackets: true,
      mode: 'application/json',
      lineWrapping: true,
      lineNumbers: true,
      theme: 'neat'
    })
    editor.setValue(initialValue)
    editor.on('change', (instance: Editor): void => { onChange(instance.getDoc().getValue()) })
  }, [])
}

export { useCodeMirror }
