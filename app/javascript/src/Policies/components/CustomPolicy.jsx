import React, { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import { Form as SchemaForm } from 'react-jsonschema-form'
import {parsePolicy, fromJson, toJson} from 'Policies/util'
import 'codemirror/mode/javascript/javascript'

import 'Policies/styles/policies.scss'

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

function Form ({policy}) {
  const {name, description, summary} = policy
  const [schema, setSchema] = useState(policy.schema)
  const onSchemaEdited = schema => setSchema(schema)

  return (
    <form>
      <input type="text" value={name} />
      <textarea name="summary" id="" cols="30" rows="10" value={summary}></textarea>
      <textarea name="description" id="" cols="30" rows="10" value={description}></textarea>
      <input type="hidden" value={schema}/>
      <div className="CustomPolicy-editor">
        <Editor className="CustomPolicy-code" code={schema} onChange={onSchemaEdited} />
        <SchemaForm className="CustomPolicy-form" schema={schema} />
      </div>
    </form>
  )
}

function CustomPolicy ({jsonPolicy}: {jsonPolicy: string}) {
  const rawPolicy = fromJson(jsonPolicy)
  const policy = parsePolicy(Object.keys(rawPolicy)[0], Object.values(rawPolicy)[0])

  return (
    <section className="CustomPolicy">
      <header className='CustomPolicy-header'>
        <h2 className="CustomPolicy-title">Custom Policy</h2>
      </header>
      <Form policy={policy} />
    </section>
  )
}

export { CustomPolicy }
