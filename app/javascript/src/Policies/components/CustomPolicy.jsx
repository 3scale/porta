// @flow

import * as React from 'react'
import { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import SchemaForm from 'react-jsonschema-form'
import { parsePolicies, fromJson, toJson } from 'Policies/util'
import type { RegistryPolicy, RawRegistry } from 'Policies/types/Policies'
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

function Editor ({onChange, code}): React.Node {
  const [ state, setState ] = useState({valid: true, code: toJson(code)})

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
  const hiddenClass = state.valid ? 'is-hidden' : ''
  const errorClass = state.valid ? '' : 'CustomPolicy-error'

  return (
    <div className={`${errorClass} panel panel-default`}>
      <div className="panel-heading">
        <i className={`${cls} fa fa-${icon}`} />
        {' JSON Schema'}
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

function Form ({policy}: {policy: RegistryPolicy}): React.Node {
  const [pol, setPolicy] = useState(policy)
  const onSchemaEdited = pol => schema => setPolicy({...pol, ...{schema}})
  const handleChange = pol => ev => setPolicy({...pol, ...{[ev.target.name]: ev.target.value}})

  return (
    <div>
      <div className="CustomPolicy-editor">
        <Editor className="CustomPolicy-code" code={pol.schema} onChange={onSchemaEdited(pol)} />
        <SchemaForm className="CustomPolicy-form" schema={pol.schema} />
      </div>
      <form action={`/p/admin/registry/policies/${pol.name}-${pol.version}`} method="post">
        <input type="text" name="name" value={pol.name} onChange={handleChange(pol)} />
        <textarea name="summary" id="" cols="30" rows="10" value={pol.summary} onChange={handleChange(pol)} />
        <textarea name="description" id="" cols="30" rows="10" value={pol.description} onChange={handleChange(pol)} />
        <input type="hidden" value={pol.schema}/>
        <input type="submit" />
      </form>
    </div>
  )
}

function CustomPolicy ({jsonPolicy}: {jsonPolicy: string}): React.Node {
  const rawRegistryPolicy: RawRegistry = fromJson(jsonPolicy)
  const policy = parsePolicies(rawRegistryPolicy)[0]

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
