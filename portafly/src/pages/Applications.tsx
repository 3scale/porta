import React from 'react'
import { useDocumentTitle, Loading, ApplicationsTable } from 'components'
import {
  Alert,
  PageSection,
  PageSectionVariants,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core'
import { useGetApplications } from 'dal/Applications'

const Applications: React.FunctionComponent = () => {
  useDocumentTitle('Applications')

  const { applications, error, isPending } = useGetApplications()

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">Applications</Text>
        </TextContent>
        <TextContent>
          <Text component={TextVariants.p}>
            This is the applications screen.
          </Text>
        </TextContent>
      </PageSection>

      <PageSection>
        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {applications && <ApplicationsTable applications={applications} />}
      </PageSection>
    </>
  )
}

export default Applications
