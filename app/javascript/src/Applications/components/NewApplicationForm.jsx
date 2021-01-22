// @flow

import React, {useState } from 'react'

import {
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextInput,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import { CSRFToken } from 'utilities/utils'

const buyers = [
  {disabled: true, id: 'foo', name: 'Select an Account'},
  {disabled: false, id: '0', name: 'Account 0'},
  {disabled: false, id: '1', name: 'Account 1'},
  {disabled: false, id: '2', name: 'Account 2'},
  {disabled: false, id: '3', name: 'Account 3'}
]

const servicePlans = [
  {disabled: true, id: 'foo', name: 'Select an Application plan'},
  {disabled: false, id: '0', name: 'Service plan 0'},
  {disabled: false, id: '1', name: 'Service plan 1'}
]

// type ServicePlan = {
//   id: number,
//   name: string,
//   default: boolean
// }

type ApplicationPlan = {
  id: number,
  name: string,
  issuer_id: number // TODO: change to productId in app/helpers/buyers/applications_helper.rb:14
}

type Product = {
  id: number,
  name: string
}

type Props = {
  createApplicationPath: string,
  createServicePlanPath: string,
  createApplicationPlanPath: string,
  products: Array<Product>,
  applicationPlans: Array<ApplicationPlan>,
  servicePlansAllowed: boolean,
  // Needed?
  // relationServiceAndServicePlans: {[number]: Array<ServicePlan>},
  // relationPlansServices: {[number]: number},
  servicesContracted?: any,
  servicePlanContractedForService?: any,
  buyerId?: string
}

const DEFAULT_PRODUCT = { disabled: true, id: 'foo', name: 'Select a Product' }
const DEFAULT_APP_PLAN = { disabled: true, id: 'foo', name: 'Select an Application Plan' }

function toFormSelectOption (p: { disabled?: boolean, name: string, id: number }) {
  return <FormSelectOption isDisabled={p.disabled} key={p.id} value={p.id} label={p.name} />
}

const NewApplicationForm = (props: Props) => {
  console.log(props)
  console.time('render NewApplicationForm')
  const { buyerId, createApplicationPath, servicePlansAllowed, products, applicationPlans, createApplicationPlanPath } = props

  const [buyer, setBuyer] = useState(buyers[0])
  const [product, setProduct] = useState(DEFAULT_PRODUCT)
  const [plan, setPlan] = useState(DEFAULT_APP_PLAN)
  const [servicePlan, setServicePlan] = useState(servicePlans[0])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')

  const buyerValid = buyerId !== undefined || buyer.id !== 'foo'
  const servicePlanValid = !servicePlansAllowed || servicePlan.id !== 'foo'
  const isFormComplete = name &&
    buyerValid &&
    product !== DEFAULT_PRODUCT &&
    plan !== DEFAULT_APP_PLAN &&
    servicePlanValid

  const availablePlans = applicationPlans.filter(p => p.issuer_id === product.id)

  console.timeEnd('render NewApplicationForm')
  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        // className="formtastic cinstance"
        // id="new_cinstance"
        // FIXME: make 'isWidthLimited' work
        acceptCharset="UTF-8"
        method="post"
        action={createApplicationPath.replace(':id', buyerId)}
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓"/>

        {/* Buyer */}
        {buyerId === undefined && (
          <FormGroup label="Account" fieldId="account_id">
            <FormSelect
              value={buyer.id}
              onChange={(id) => setBuyer(buyers.find(a => a.id === id))}
              id="account_id"
              name="account_id"
            >
              {buyers.map((b) => (
                <FormSelectOption isDisabled={b.disabled} key={b.id} value={b.id} label={b.name} />
              ))}
            </FormSelect>
          </FormGroup>
        )}

        {/* Product */}
        <FormGroup label="Product" fieldId="product">
          <FormSelect
            value={product.id}
            onChange={(id: string) => setProduct(products.find(p => p.id === Number(id)))}
            id="product"
          >
            {[DEFAULT_PRODUCT, ...products].map(toFormSelectOption)}
          </FormSelect>
        </FormGroup>

        {/* Application Plan */}
        <FormGroup
          label="Application plan"
          // isRequired
          validated="default"
          fieldId="cinstance_plan_id"
        >
          <FormSelect
            isDisabled={product === DEFAULT_PRODUCT || !availablePlans.length}
            value={plan.id}
            onChange={(id) => setPlan(applicationPlans.find(p => p.id === Number(id)))}
            id="cinstance_plan_id"
            name="cinstance[plan_id]"
          >
            {[DEFAULT_APP_PLAN, ...availablePlans].map(toFormSelectOption)}
          </FormSelect>
          {product !== DEFAULT_PRODUCT && !availablePlans.length && (
            <Button component="a" href={createApplicationPlanPath.replace(':id', product.id)} variant="link">
              Create your first application plan.
            </Button>
          )}
        </FormGroup>

        {/* Service Plan */}
        {servicePlansAllowed && (
          <FormGroup
            label="Service plan"
            // isRequired
            validated="default"
            fieldId="cinstance[service_plan_id]"
          >
            <FormSelect
              value={servicePlan.id}
              onChange={(id) => setServicePlan(servicePlans.find(a => a.id === id))}
              id="cinstance_service_plan_id"
              name="cinstance[service_plan_id]"
            >
              {servicePlans.map((p) => (
                <FormSelectOption isDisabled={p.disabled} key={p.id} value={p.id} label={p.name} />
              ))}
            </FormSelect>
          </FormGroup>
        )}

        {/* Name */}
        <FormGroup
          label="Name"
          // isRequired show only after first attempt?
          validated="default"
          fieldId="cinstance_name"
        >
          <TextInput
            type="text"
            id="cinstance_name"
            name="cinstance[name]"
            value={name}
            onChange={setName}
          />
        </FormGroup>

        {/* Description */}
        <FormGroup
          label="Description"
          // isRequired show only after first attempt?
          validated="default"
          fieldId="cinstance_description"
        >
          <TextInput
            type="text"
            id="cinstance_description"
            name="cinstance[description]"
            value={description}
            onChange={setDescription}
          />
        </FormGroup>

        <ActionGroup>
          <Button
            variant="primary"
            type="submit"
            isDisabled={!isFormComplete}
          >
            Create Application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

export { NewApplicationForm }
