/* eslint-disable react/jsx-curly-newline */
import { useState } from 'react'
import {
  Button,
  Card,
  CardBody,
  Flex,
  FlexItem,
  PageSection,
  PageSectionVariants,
  Radio,
  Text,
  TextContent
} from '@patternfly/react-core'

import { ManualForm } from 'Products/components/ManualForm'
import { ServiceDiscoveryForm } from 'Products/components/ServiceDiscoveryForm'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
import type { Props as ManualFormProps } from 'Products/components/ManualForm'

import './NewPage.scss'

interface Props {
  service: ManualFormProps['service'];
  isServiceDiscoveryAccessible: boolean;
  isServiceDiscoveryUsable: boolean;
  serviceDiscoveryAuthenticateUrl: string;
  providerAdminServiceDiscoveryServicesPath: string;
  adminServicesPath: string;
}

const NewPage: FunctionComponent<Props> = ({
  service,
  isServiceDiscoveryAccessible,
  isServiceDiscoveryUsable,
  serviceDiscoveryAuthenticateUrl,
  providerAdminServiceDiscoveryServicesPath,
  adminServicesPath
}) => {
  const [manualMode, setManualMode] = useState(true)
  const [loadingProjects, setLoadingProjects] = useState(false)

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">New Product</Text>
        </TextContent>
      </PageSection>

      {/* <PageSection>
        <Form>
          <Card>
            <FormFieldGroupExpandable
              isExpanded
              aria-label="Manual form"
              header={
                <FormFieldGroupHeader
                  actions={}
                  titleDescription=""
                  titleText={{ text: 'Define manually', id: 'manual-form' }}
                />
              }
              toggleAriaLabel="Details"
            >
              <FormGroup isRequired fieldId="1-expanded-group1-label1" label="Name">
                <TextInput
                  isRequired
                  id="1-expanded-group1-label1"
                  name="1-expanded-group1-label1"
                  value="Pepe API"
                  onChange={console.log}
                />
              </FormGroup>

              <FormGroup isRequired fieldId="1-expanded-group1-label1" label="System name">
                <TextInput
                  isRequired
                  id="1-expanded-group1-label1"
                  name="1-expanded-group1-label1"
                  value="pepe-api"
                  onChange={console.log}
                />
              </FormGroup>

              <FormGroup isRequired fieldId="1-expanded-group1-label1" label="Description">
                <TextArea
                  isRequired
                  id="1-expanded-group1-label1"
                  name="1-expanded-group1-label1"
                  value=""
                  onChange={console.log}
                />
              </FormGroup>
            </FormFieldGroupExpandable>
          </Card>

          <Card>
            <FormFieldGroupExpandable
              isExpanded
              aria-label="Service discovery form"
              header={
                <FormFieldGroupHeader
                  actions={}
                  titleDescription="Choosing this option will also create a Backend"
                  titleText={{ text: 'Import from Openshift', id: 'service-discovery-form' }}
                />
              }
              toggleAriaLabel="Details"
            >
              <FormGroup isRequired fieldId="1-expanded-group1-label1" label="Label 1">
                <TextInput
                  isRequired
                  id="1-expanded-group1-label1"
                  name="1-expanded-group1-label1"
                  value="pepe"
                  onChange={console.log}
                />
              </FormGroup>
            </FormFieldGroupExpandable>
          </Card>
        </Form>
      </PageSection> */}

      <PageSection>
        <Flex direction={{ default: 'column' }}>
          {isServiceDiscoveryAccessible && (
            <FlexItem flex={{ default: 'flex_1' }}>
              <Card>
                <CardBody>
                  <Radio
                    id="radio-manual"
                    isChecked={manualMode}
                    isDisabled={loadingProjects}
                    label="Define manually"
                    name="form-mode"
                    onChange={() => { setManualMode(true) }}
                  />
                  <Radio
                    description="Choosing this option will also create a Backend"
                    id="radio-service-discovery"
                    isChecked={!manualMode}
                    isDisabled={!isServiceDiscoveryUsable || loadingProjects}
                    label={(
                      <>
                        <span>Import from Openshift </span>
                        {isServiceDiscoveryUsable || (
                          <Button
                            isInline
                            component="a"
                            href={serviceDiscoveryAuthenticateUrl}
                            variant="link"
                          >
                            (Authenticate to enable this option)
                          </Button>
                        )}
                      </>
                    )}
                    name="form-mode"
                    onChange={() => { setManualMode(false) }}
                  />
                </CardBody>
              </Card>
            </FlexItem>
          )}

          <FlexItem flex={{ default: 'flex_1' }}>
            <Card>
              <CardBody>
                {manualMode ? (
                  <ManualForm
                    action={adminServicesPath}
                    disabled={loadingProjects}
                    service={service}
                  />
                ) : (
                  <ServiceDiscoveryForm
                    action={providerAdminServiceDiscoveryServicesPath}
                    loading={loadingProjects}
                    setLoadingProjects={setLoadingProjects}
                  />
                )}
              </CardBody>
            </Card>
          </FlexItem>
        </Flex>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewPageWrapper = (props: Props, containerId: string): void => { createReactWrapper(<NewPage {...props} />, containerId) }

export type { Props }
export { NewPage, NewPageWrapper }
