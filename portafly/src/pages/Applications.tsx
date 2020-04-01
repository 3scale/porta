import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import { useFetch } from 'react-async'
import { useDocumentTitle } from 'components'
import {
  PageSection,
  PageSectionVariants,
  TextContent,
  Text,
  TextVariants
} from '@patternfly/react-core'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'

const Applications: React.FunctionComponent = () => {
  const { t } = useTranslation('applications')
  useDocumentTitle(t('page_title'))

  const columns = [
    'Name',
    'State',
    'Account',
    'Plan',
    'Created at'
  ]
  let rows

  const { data, isPending } = useFetch<any>(
    '/applications',
    { headers: { Accept: 'application/json' } }
  )

  if (!isPending && data) {
    const applications = data.applications.application // TODO: Check the server side xml2json
    const applicationsArray = Array.isArray(applications) ? applications : [{ ...applications }]

    rows = applicationsArray.map(
      (app: any) => ({
        cells: [
          app.name,
          app.state,
          'Developer',
          app.plan.name,
          app.created_at
        ]
      })
    )
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">{t('body_title')}</Text>
        </TextContent>
        <TextContent>
          <Text component={TextVariants.p}>
            {t('subtitle')}
          </Text>
        </TextContent>
      </PageSection>

      <PageSection>
        {rows
          && (
            <Table cells={columns} rows={rows}>
              <TableHeader />
              <TableBody />
            </Table>
          )}
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Applications
