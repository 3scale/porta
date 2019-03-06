// @flow

import * as React from 'react'
import { useState } from 'react'
import { UnControlled as CodeMirror } from 'react-codemirror2'
import SchemaForm from 'react-jsonschema-form'
import { fromJson, toJson } from 'Policies/util'
import type { RegistryPolicy } from 'Policies/types/Policies'
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

const POLICY_TEMPLATE: RegistryPolicy = {
  $schema: '',
  name: '',
  version: '',
  description: '',
  summary: '',
  configuration: {},
  humanName: ''
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

function Editor ({onChange, code}): React.Node {
  const [ state, setState ] = useState({valid: true, code: toJson(code)})

  const onCodeChange = (editor, metadata, code) => {
    setState({ valid: true, code })
    try {
      onChange(fromJson(code))
    } catch (err) {
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

function FormInput (
  props: {
    type: 'text' | 'textarea',
    humanname: string,
    name: string,
    value?: string,
    onChange: OnChange,
    disabled?: boolean
  }) {
  return (
    <label>
      {`${props.humanname}:`}
      {(props.type === 'text') ? <input type="text" {...props} /> : <textarea {...props} /> }
    </label>
  )
}

function CustomPolicyForm ({policy, onChange, isNewPolicy}: {policy: RegistryPolicy, onChange: OnChange, isNewPolicy: boolean}): React.Node {
  const action = (isNewPolicy) ? '/p/admin/registry/policies/' : `/p/admin/registry/policies/${policy.name}-${policy.version}`
  return (
    <form action={action} method="post">
      <FormInput type="text" name="name" humanname="Name" value={policy.name} onChange={onChange} disabled={!isNewPolicy} />
      <FormInput type="text" name="humanName" humanname="Human Name" value={policy.humanName} onChange={onChange} />
      <FormInput type="text" name="version" humanname="Version" value={policy.version} onChange={onChange} disabled={!isNewPolicy} />
      <FormInput type="textarea" name="summary" humanname="Summary" value={policy.summary} onChange={onChange} />
      <FormInput type="textarea" name="description" humanname="Description" value={policy.description} onChange={onChange} />
      <input name="configuration" type="hidden" value={JSON.stringify(policy.configuration)} />
      {(!isNewPolicy) ? <input name="_method" type="hidden" value='put' /> : ''}
      <input type="submit" />
      <CSRFToken />
    </form>
  )
}

function Form ({policy}: {policy: RegistryPolicy}): React.Node {
  const [pol, setPolicy] = useState(policy)
  const onSchemaEdited = (pol: RegistryPolicy) => (configuration: string) => setPolicy({...pol, ...{configuration}})
  const handleChange = (pol: RegistryPolicy) => (ev: InputEvent) => setPolicy({...pol, ...{[ev.target.name]: ev.target.value}})
  const isNewPolicy = (policy.name.length === 0)

  return (
    <div>
      <div className="CustomPolicy-editor">
        <Editor className="CustomPolicy-code" code={pol.configuration} onChange={onSchemaEdited(pol)} />
        <SchemaForm className="CustomPolicy-form" schema={pol.configuration} />
      </div>
      <CustomPolicyForm policy={pol} onChange={handleChange(pol)} isNewPolicy={isNewPolicy} />
    </div>
  )
}

function CustomPolicy ({policy = POLICY_TEMPLATE}: {policy: RegistryPolicy}): React.Node {
  return (
    <section className="CustomPolicy">
      <header className='CustomPolicy-header'>
        <h2 className="CustomPolicy-title">Custom Policy</h2>
      </header>
      <Form policy={policy} />
    </section>
  )
}

export {
  CustomPolicy,
  CustomPolicyForm,
  FormInput,
  Editor,
  CSRFToken,
  CM_OPTIONS,
  POLICY_TEMPLATE
}
