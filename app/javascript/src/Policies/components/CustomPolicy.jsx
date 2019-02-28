import React, { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import 'codemirror/mode/javascript/javascript'
import Form from 'react-jsonschema-form'

import 'Policies/styles/policies.scss'

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

  const schemaValid = state.valid
  const icon = schemaValid ? 'check' : 'times'
  const cls = schemaValid ? 'valid' : 'invalid'
  const hiddenClass = schemaValid ? 'is-hidden' : ''
  const errorClass = schemaValid ? '' : 'CustomPolicy-error'

  return (
    <div className={`${errorClass} panel panel-default`}>
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
      <div className={hiddenClass}> There's an error in the JSON Schema</div>
    </div>
  )
}

function CustomPolicy () {
  const [schema, setSchema] = useState(schemaSample)

  const onSchemaEdited = schema => setSchema(schema)

  return (
    <section className="CustomPolicy">
      <header className='CustomPolicy-header'>
        <h2 className="CustomPolicy-title">Custom Policy</h2>
      </header>
      <div className="CustomPolicy-editor">
        <Editor className="CustomPolicy-code" code={schema} onChange={onSchemaEdited} />
        <Form className="CustomPolicy-form" schema={schema} />
      </div>
    </section>
  )
}

export { CustomPolicy }
