// @flow

import * as React from 'react'
import { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import SchemaForm from 'react-jsonschema-form'
import { fromJsonString, toJsonString } from 'Policies/util'
import type { Policy } from 'Policies/types/Policies'
import type {InputEvent} from 'Policies/types'
import 'codemirror/mode/javascript/javascript'
import 'Policies/styles/policies.scss'

type OnChange = (InputEvent) => void

const CM_OPTIONS = {
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

const POLICY_TEMPLATE: Policy = {
  schema: {
    '$schema': 'http://apicast.io/policy-v1/schema#manifest#',
    'name': '[Name of the policy]',
    'summary': '[A brief description of what it does.]',
    'version': '[0.0.1]',
    'configuration': {
      'type': 'object',
      'properties': {
        'property': {
          'description': 'A description of your property',
          'type': 'string'
        }
      }
    }
  },
  directory: '',
  id: 0
}

function CSRFToken ({win = window}: {win?: any}): React.Node {
  const getMetaContent = meta => win.document.head.querySelector(`meta[name~=${meta}][content]`).content
  const props = {
    name: getMetaContent('csrf-param'),
    value: getMetaContent('csrf-token'),
    type: 'hidden'
  }
  return (
    <input {...props} />
  )
}

function Editor ({onChange, code}: {onChange: (Object) => void, code: Object}): React.Node {
  const [ state, setState ] = useState({valid: true, code: toJsonString(code)})

  const checkConfiguration = (schema) => {
    if (!schema.configuration) throw new Error('Policy configuration not found')
  }

  const onCodeChange = (editor, metadata, code) => {
    try {
      const schema = fromJsonString(code)
      checkConfiguration(schema)
      onChange(schema)
      setState({ valid: true, code })
    } catch (err) {
      console.warn(err)
      setState({ valid: false, code })
    }
  }

  const [ icon, cls, hiddenClass, errorClass ] = state.valid
    ? [ 'check', 'valid', 'is-hidden', '' ]
    : [ 'times', 'invalid', '', 'CustomPolicy-error' ]

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
        options={CM_OPTIONS}
      />
      <div className={hiddenClass}> There's an error in the JSON Schema</div>
    </div>
  )
}

function CustomPolicyForm ({policy, onChange}: {policy: Policy, onChange: OnChange}): React.Node {
  const isNewPolicy = !(policy.id && policy.id !== 0)
  const action = (isNewPolicy) ? '/p/admin/registry/policies/' : `/p/admin/registry/policies/${policy.id}`
  return (
    <form action={action} method="post">
      <label>
        Directory:
        <input type="text" name="directory" value={policy.directory} onChange={onChange} disabled={!isNewPolicy} />
      </label>
      <input type="hidden" name="id" value={policy.id} disabled={true} />
      <input name="schema" type="hidden" value={JSON.stringify(policy.schema)} />
      {(!isNewPolicy) ? <input name="_method" type="hidden" value='put' /> : ''}
      <input type="submit" />
      <CSRFToken />
    </form>
  )
}

function Form ({initialPolicy}: {initialPolicy: Policy}): React.Node {
  const [policy, setPolicy] = useState(initialPolicy)
  const onSchemaEdited = (schema: Object) => setPolicy(prevPolicy => ({ ...prevPolicy, ...{ schema } }))
  const handleChange = (ev: InputEvent) => {
    ev.persist()
    return setPolicy(prevPolicy => ({ ...prevPolicy, ...{ [ev.target.name]: ev.target.value } }))
  }

  return (
    <div>
      <div className="CustomPolicy-editor">
        <Editor className="CustomPolicy-code" code={policy.schema} onChange={onSchemaEdited} />
        <div>
          <h3>Form Preview</h3>
          <SchemaForm className="CustomPolicy-form" schema={policy.schema.configuration}>
            <button type="submit" className="is-hidden">Submit</button>
          </SchemaForm>
        </div>
      </div>
      <CustomPolicyForm policy={policy} onChange={handleChange} />
    </div>
  )
}

function CustomPolicy ({policy = POLICY_TEMPLATE}: {policy: Policy}): React.Node {
  const CANCEL_POLICY_HREF = '/p/admin/registry/policies'
  return (
    <section className="CustomPolicy">
      <header className='CustomPolicy-header'>
        <h2 className="CustomPolicy-title">Custom Policy</h2>
        <a className="CustomPolicy-cancel" href={CANCEL_POLICY_HREF} >
          <i className="fa fa-times-circle" /> Cancel
        </a>
      </header>
      <Form initialPolicy={policy} />
    </section>
  )
}

export {
  CustomPolicy,
  CustomPolicyForm,
  Editor,
  CSRFToken,
  CM_OPTIONS,
  POLICY_TEMPLATE
}
