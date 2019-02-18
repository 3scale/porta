import React, { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import 'codemirror/mode/javascript/javascript'
import Form from 'react-jsonschema-form'

const fromJson = json => JSON.parse(json)
const toJson = val => JSON.stringify(val, null, 2)

// Sample
const schemaSample = {
  title: 'Custom Policy',
  description: 'An epic policy yet to code.',
  type: 'object',
  required: ['name'],
  properties: {
    name: {
      type: 'string',
      title: 'Name',
      default: 'Mashing'
    },
    version: {
      type: 'integer',
      title: 'Version',
      default: 1
    }
  }
}

const cmOptions = {
  theme: 'default',
  height: 'auto',
  viewportMargin: Infinity,
  mode: {
    name: 'javascript',
    json: true,
    statementIndent: 2
  },
  lineNumbers: true,
  lineWrapping: true,
  indentWithTabs: false,
  tabSize: 2
}

function Editor (props) {
  const { onChange } = props
  const [ state, setState ] = useState({valid: true, code: toJson(props.code)})

  const onCodeChange = (editor, metadata, code) => {
    setState({ valid: true, code })
    setImmediate(() => {
      try {
        onChange(fromJson(code))
      } catch (err) {
        setState({ valid: false, code })
      }
    })
  }

  const icon = state.valid ? 'check' : 'times'
  const cls = state.valid ? 'valid' : 'invalid'

  return (
    <div className="panel panel-default">
      <div className="panel-heading">
        <span className={`${cls} fa fa-${icon}`} />
        {'JSON Schema'}
      </div>
      <CodeMirror
        value={state.code}
        onChange={onCodeChange}
        autoCursor={false}
        options={cmOptions}
      />
    </div>
  )
}

function CustomPolicy () {
  const [schema, setSchema] = useState(schemaSample)

  const onSchemaEdited = schema => setSchema(schema)

  return (
    <div>
      <Editor code={schema} onChange={onSchemaEdited} />
      <Form schema={schema} />
    </div>
  )
}

export { CustomPolicy }
