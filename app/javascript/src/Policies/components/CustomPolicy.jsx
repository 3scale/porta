// @flow

import * as React from 'react'
import { useState } from 'react'
import SchemaForm from 'react-jsonschema-form'
import { SchemaEditor } from 'Policies/components/SchemaEditor'
import type { Policy, Schema } from 'Policies/types/Policies'
import type {InputEvent} from 'Policies/types'
import 'codemirror/mode/javascript/javascript'
import 'Policies/styles/policies.scss'

type OnChange = (InputEvent) => void

const POLICY_TEMPLATE: Policy = {
  schema: {
    '$schema': 'http://apicast.io/policy-v1/schema#manifest#',
    'name': 'Name of the policy',
    'summary': 'A one-line (less than 75 characters) summary of what this policy does.',
    'description': 'A complete description of what this policy does.',
    'version': '0.0.1',
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
        <SchemaEditor className="CustomPolicy-code" schema={policy.schema} onChange={onSchemaEdited} />
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
  CSRFToken,
  POLICY_TEMPLATE
}
