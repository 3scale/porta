import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
// @ts-ignore
import { useA11yRouteChange, useDocumentTitle, useAlertsContext } from 'components'
import {
  Toolbar,
  DataListProvider,
  SearchWidget,
  PaginationWidget,
  useDataListPagination
} from 'components/data-list'
import {
  PageSection,
  TextContent,
  Title,
  Text,
  Card,
  CardBody,
  Button
} from '@patternfly/react-core'
import { BellIcon } from '@patternfly/react-icons'

import {
  DataToolbarItem,
  DataToolbarContent
} from '@patternfly/react-core/dist/js/experimental'

const categories = [
  {
    name: 'admin',
    humanName: 'Admin'
  },
  {
    name: 'group',
    humanName: 'Organization / Group'
  },
  {
    name: 'state',
    humanName: 'State',
    options: [
      {
        name: 'active',
        humanName: 'Active'
      },
      {
        name: 'pending',
        humanName: 'Pending'
      }
    ]
  }
]

const List = ({ list }: any) => {
  const { startIdx, endIdx } = useDataListPagination()
  console.log(startIdx, endIdx)
  return (
    <ul>
      {list.slice(startIdx, endIdx).map((item: any) => <li>{item}</li>)}
    </ul>
  )
}

const Overview: React.FunctionComponent = () => {
  const { t } = useTranslation('overview')

  useA11yRouteChange()
  useDocumentTitle(t('page_title'))
  const { addAlert } = useAlertsContext()
  const list = new Array(1000).map((item, i) => i)
  return (
    <>
      <PageSection variant="light">
        <TextContent>
          <Title size="3xl">{t('body_title')}</Title>
          <Text>
            {t('subtitle')}
          </Text>
        </TextContent>
      </PageSection>
      <PageSection>
        <Card>
          <CardBody>
            <TextContent>
              <p>{t('shared:format.uppercase', { text: 'Ohai' })}</p>
              {/* This is just for testing, will be removed */}
              <Button
                icon={<BellIcon />}
                onClick={() => {
                  const id = Date.now().toString()
                  addAlert({ id, variant: 'info', title: `Test Alert ${id}` })
                }}
              >
                Add an Alert
              </Button>
            </TextContent>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <DataListProvider>
              <Toolbar>
                <DataToolbarContent>
                  <DataToolbarItem>
                    <SearchWidget categories={categories} />
                  </DataToolbarItem>
                  <DataToolbarItem>
                    <PaginationWidget itemCount={1000} />
                  </DataToolbarItem>
                </DataToolbarContent>
              </Toolbar>
              <List list={list} />
            </DataListProvider>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Overview
