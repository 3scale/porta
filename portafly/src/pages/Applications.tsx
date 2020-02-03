import React from 'react'
import { useFetch } from 'react-async'
import {useDocumentTitle} from '../components'
import {
  PageSection,
  PageSectionVariants,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core'
import { Table, TableHeader, TableBody } from '@patternfly/react-table'

const Applications: React.FunctionComponent = () => {
  useDocumentTitle('Applications')

  const columns = [
    'Name',
    'State',
    'Account',
    'Plan',
    'Created at'
  ]
  let rows

  const { data, isPending } = useFetch<any>(
    `/applications`,
    { headers: { Accept: 'application/json' } }
  )

  const mapRowsData = (data: any) => {
    if(!data) return
    const applications = data.applications.application // TODO: Check the server side xml2json
    const applicationsArray =  Array.isArray(applications) ? applications : [{...applications}]

    return applicationsArray.map(
      (app: any) => {
        return {
          cells: [
            app.name,
            app.state,
            'Developer',
            app.plan.name,
            app.created_at
          ]
        }
      }
    )
  }

  if (!isPending) {
    rows = mapRowsData(data)
  }

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
        {rows &&
          <Table cells={columns} rows={rows}>
            <TableHeader />
            <TableBody />
          </Table>
        }
      </PageSection>
    </>
  )
}

export default Applications
