// @flow

import React, { useState, useEffect } from 'react'

import {
  Form,
  FormGroup,
  FormSelect,
  TextInput,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
// $FlowFixMe: import throwing an error but it should not
import { ProductFormSelector, ApplicationPlanSelect, DEFAULT_APP_PLAN } from 'Applications'
import { CSRFToken } from 'utilities/utils'
import { toFormSelectOption } from 'utilities/patternfly-utils'

import type { Buyer, Product, ServicePlan } from 'Applications/types'

import './NewApplicationForm.scss'

const DEFAULT_BUYER: Buyer = { disabled: true, id: '-1', name: 'Select an Account', contractedProducts: [], servicePlans: [], createApplicationPath: '' }
const DEFAULT_PRODUCT: Product = { disabled: true, id: -1, name: 'Select a Product', appPlans: [], servicePlans: [], defaultServicePlan: null }
const DEFAULT_SERVICE_PLAN: ServicePlan = { disabled: true, id: -1, name: 'Select a Service Plan', issuer_id: -1, default: false }

type Props = {
  createApplicationPath: string,
  createServicePlanPath: string,
  createApplicationPlanPath: string,
  products: Product[],
  servicePlansAllowed: boolean,
  buyer?: Buyer
}

const NewApplicationForm = (props: Props) => {
  console.log(props)
  console.time('render NewApplicationForm')
  const { buyer, createApplicationPath, servicePlansAllowed, products, createApplicationPlanPath } = props

  // const [buyer, setBuyer] = useState(buyers[0])
  const [product, setProduct] = useState(DEFAULT_PRODUCT)
  const [appPlan, setAppPlan] = useState(DEFAULT_APP_PLAN)
  const [servicePlan, setServicePlan] = useState(DEFAULT_SERVICE_PLAN)
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [loading, setLoading] = useState(false)

  const buyerValid = buyer && (buyer.id !== undefined || buyer.id !== DEFAULT_BUYER.id)
  const servicePlanValid = !servicePlansAllowed || servicePlan.id !== DEFAULT_SERVICE_PLAN.id
  const isFormComplete = name &&
    buyerValid &&
    product !== DEFAULT_PRODUCT &&
    appPlan !== DEFAULT_APP_PLAN &&
    servicePlanValid

  useEffect(() => {
    if (product !== DEFAULT_PRODUCT) {
      setAppPlan(DEFAULT_APP_PLAN)
      if (product.defaultServicePlan) {
        setServicePlan(product.defaultServicePlan)
      } else {
        setServicePlan(DEFAULT_SERVICE_PLAN)
      }
    }
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  console.timeEnd('render NewApplicationForm')
  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        // FIXME: make 'isWidthLimited' work
        acceptCharset="UTF-8"
        method="post"
        action={url}
        onSubmit={e => setLoading(true)}
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓"/>

        {/* Buyer */}
        {buyer === undefined && (
          <FormGroup
            label="Account"
            isRequired
            fieldId="account_id"
          >
            <FormSelect
              value={undefined}
              onChange={(id) => console.log('setBuyer(buyers.find(a => a.id === id))')}
              id="account_id"
              name="account_id"
            >
              {/* {buyers.map((b) => (
                <FormSelectOption isDisabled={b.disabled} key={b.id} value={b.id} label={b.name} />
              ))} */}
            </FormSelect>
          </FormGroup>
        )}

        {/* Product (fancy selector) */}
        <ProductFormSelector
          products={products}
          onSelect={console.log}
        />

        {/* Product */}
        <FormGroup
          // Not to be submitted
          isRequired
          label="Product"
          fieldId="product"
        >
          <FormSelect
            value={product.id}
            onChange={(id: string) => setProduct(products.find(p => p.id === Number(id)) || DEFAULT_PRODUCT)}
            id="product"
          >
            {/* $FlowFixMe */}
            {[DEFAULT_PRODUCT, ...products].map(toFormSelectOption)}
          </FormSelect>
        </FormGroup>

        {/* Application Plan */}
        <FormGroup
          label="Application plan"
          isRequired
          validated="default"
          fieldId="cinstance_plan_id"
        >
          <ApplicationPlanSelect
            isDisabled={product === DEFAULT_PRODUCT}
            appPlans={product.appPlans}
            appPlan={appPlan}
            setAppPlan={setAppPlan}
            createApplicationPlanPath={createApplicationPlanPath.replace(':id', product.id.toString())}
          />
        </FormGroup>

        {/* Service Plan */}
        {servicePlansAllowed && (
          <FormGroup
            label="Service plan"
            isRequired
            validated="default"
            fieldId="cinstance_service_plan_id"
          >
            <FormSelect
              // Disable if no product is selected OR buyer has that products contracted already
              isDisabled={product === DEFAULT_PRODUCT || product.defaultServicePlan}
              value={servicePlan.id}
              onChange={(id) => setServicePlan(product.servicePlans.find(p => p.id === Number(id)) || DEFAULT_SERVICE_PLAN)}
              id="cinstance_service_plan_id"
              name="cinstance[service_plan_id]"
            >
              {/* $FlowFixMe */}
              {[DEFAULT_SERVICE_PLAN, ...product.servicePlans].map(toFormSelectOption)}
            </FormSelect>
            {product !== DEFAULT_PRODUCT && !product.servicePlans.length && (
              <p className="hint">
                In order to subscribe the Application to a Product’s Application plan, this Account needs to subscribe to a Product’s Service plan.
              </p>
            )}
          </FormGroup>
        )}

        {/* Name */}
        <FormGroup
          label="Name"
          isRequired
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
            isDisabled={!isFormComplete || loading}
          >
            Create Application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

export { NewApplicationForm }
