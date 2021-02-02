// @flow

import React, { useState, useEffect } from 'react'

import {
  Form,
  ActionGroup,
  Button,
  Modal,
  PageSection,
  PageSectionVariants,
  // Table,
  InputGroup,
  TextInput,
  // SearchIcon,
  Pagination,
  Toolbar,
  ToolbarItem
} from '@patternfly/react-core'
import {
  BuyerSelect,
  ProductSelect,
  ApplicationPlanSelect,
  ServicePlanSelect,
  NameInput,
  DescriptionInput
} from 'NewApplication'
import { CSRFToken } from 'utilities/utils'

import type { Buyer, Product, ServicePlan, ApplicationPlan } from 'NewApplication/types'

import './NewApplicationForm.scss'

type Props = {
  createApplicationPath: string,
  createApplicationPlanPath: string,
  products: Product[],
  servicePlansAllowed: boolean,
  buyer?: Buyer
}

const NewApplicationForm = ({
  buyer,
  createApplicationPath,
  servicePlansAllowed,
  products,
  createApplicationPlanPath
}: Props) => {
  // const [buyer, setBuyer] = useState(buyers[0])
  const [product, setProduct] = useState<Product | null>(null)
  const [servicePlan, setServicePlan] = useState<ServicePlan | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan | null>(null)
  const [name, setName] = useState<string>('')
  const [description, setDescription] = useState<string>('')

  const [loading, setLoading] = useState<boolean>(false)
  const [modalOpen, setModalOpen] = useState<boolean>(false)
  console.log(`Modal is ${modalOpen ? 'open' : 'close'}`)

  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan !== null
  const isFormComplete = name &&
    buyerValid &&
    product !== null &&
    appPlan !== null &&
    servicePlanValid

  // useEffect(() => {
  //   if (buyer !== BUYER_PLACEHOLDER) {
  //     setProduct(PRODUCT_PLACEHOLDER)
  //     setAppPlan(APP_PLAN_PLACEHOLDER)
  //   }
  // }, [buyer])

  useEffect(() => {
    if (product !== null) {
      setAppPlan(null)

      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      setServicePlan(contractedServicePlan || null)
    }
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  const contract = buyer && product && buyer.contractedProducts.find(p => p.id === product.id)
  const contractedServicePlan = (contract && contract.withPlan) || (product && product.defaultServicePlan)

  // const modalColumns = [
  //   {title: 'Name'},
  //   {title: 'System Name'},
  //   {title: 'Last updated'}
  // ]
  // const modalRows = [
  //   ['Product-01', 'product-01-sys-name', '04 Oct 2020, 08:05am']
  // ]

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <Form
          acceptCharset='UTF-8'
          method='post'
          action={url}
          onSubmit={e => setLoading(true)}
        >
          <CSRFToken />
          <input name='utf8' type='hidden' value='✓' />

          {!buyer && <BuyerSelect />}

          <ProductSelect
            product={product}
            products={products}
            onSelect={setProduct}
            onShowAll={() => setModalOpen(true)}
            isDisabled={!buyer}
          />

          {servicePlansAllowed && (
            <ServicePlanSelect
              servicePlan={servicePlan}
              servicePlans={product ? product.servicePlans : []}
              onSelect={setServicePlan}
              isRequired={contractedServicePlan === null}
              isDisabled={product === null || contractedServicePlan !== null}
            />
          )}

          <ApplicationPlanSelect
            appPlan={appPlan}
            appPlans={product ? product.appPlans : []}
            onSelect={setAppPlan}
            createApplicationPlanPath={createApplicationPlanPath.replace(
              ':id',
              product ? product.id.toString() : ''
            )}
            isDisabled={product === null}
          />

          <NameInput name={name} setName={setName} />

          <DescriptionInput
            description={description}
            setDescription={setDescription}
          />

          <ActionGroup>
            <Button
              variant='primary'
              type='submit'
              isDisabled={!isFormComplete || loading}
            >
              Create Application
            </Button>
          </ActionGroup>
        </Form>
      </PageSection>

      <Modal
        title='Select a Product'
        isLarge={true}
        isOpen={modalOpen}
        isFooterLeftAligned={true}
        actions={[
          <Button key='add' variant='primary'>
            Add
          </Button>,
          <Button key='cancel' variant='secondary'>
            Cancel
          </Button>
        ]}
      >

        {/* Toolbar is a component in the css, but a layout in react, so the class names are mismatched (pf-c-toolbar vs pf-l-toolbar) Styling doesn't work, but if you change it to pf-c in the inspector, it works */}
        <Toolbar className="pf-c-toolbar pf-u-justify-content-space-between">
          <ToolbarItem>
            <InputGroup>
              <TextInput name="searchInput" id="searchInput" type="search" aria-label="search for a product" />
              <Button variant="control" aria-label="search button for search input">
                search icon{/* <SearchIcon /> */}
              </Button>
            </InputGroup>
          </ToolbarItem>
          <ToolbarItem>
            <Pagination
              itemCount={8}
              isCompact={true}
              // perPage={this.state.perPage}
              // page={this.state.page}
              // onSetPage={this.onSetPage}
              // widgetId="pagination-options-menu-top"
              // onPerPageSelect={this.onPerPageSelect}
            />
          </ToolbarItem>
        </Toolbar>
        {/* <Table
          caption='Products'
          // sortBy={sortBy}
          // onSort={this.onSort}
          cells={modalColumns}
          rows={modalRows}
        >
        </Table> */}
      </Modal>
    </>
  )
}

export { NewApplicationForm }
