import React from 'react'
import {
  useDocumentTitle,
  Loading
} from 'components'
import {
  ApplicationsDataListTable,
  CreateApplicationButton
} from 'components/pages/applications'
import {
  Alert,
  PageSection,
  TextContent,
  Text,
  Flex,
  FlexItem
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { getApplications } from 'dal/applications'
import { useAsync } from 'react-async'

interface Props {}

const ApplicationsIndexPage: React.FunctionComponent<Props> = () => {
  const { t } = useTranslation('applicationsIndex')
  useDocumentTitle(t('page_title'))

  const { data: applications, isPending, error } = useAsync(getApplications)

  return (
    <>
      <PageSection variant="light">
        <Flex>
          <FlexItem>
            <TextContent>
              <Text component="h1">{t('body_title')}</Text>
            </TextContent>
          </FlexItem>
          <FlexItem align={{ default: 'alignRight' }}>
            <CreateApplicationButton />
          </FlexItem>
        </Flex>
      </PageSection>

      <PageSection>
        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {applications && <ApplicationsDataListTable applications={applications} />}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default ApplicationsIndexPage
