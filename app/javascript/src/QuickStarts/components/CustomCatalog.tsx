/* eslint-disable @typescript-eslint/no-non-null-assertion */

import { useContext, useMemo } from 'react'
import {
  QuickStartCatalogHeader,
  QuickStartCatalogSection,
  QuickStartContext,
  QuickStartTile,
  getQuickStartStatus,
  LoadingBox
} from '@patternfly/quickstarts'
import {
  Gallery,
  GalleryItem,
  Text,
  TextContent
} from '@patternfly/react-core'

import type {
  QuickStart,
  QuickStartContextValues } from '@patternfly/quickstarts'

import './QuickStartContainer.scss'

interface Category {
  id: string;
  title: string;
}

export const CustomCatalog: React.FC = () => {
  const { activeQuickStartID, allQuickStartStates, allQuickStarts, loading } =
    useContext<QuickStartContextValues>(QuickStartContext)

  // Notes:
  // - The sections will appear in the order specified in the array
  // - The 'id' must be included in the QuickStart yaml metadata as 'category', e.g.
  //   metadata:
  //     name: getting-started-with-quick-starts
  //     category: basic-api-integration-setup
  const categories: Category[] = [
    {
      id: 'threescale-api-management-features',
      title: '3scale API Management features'
    },
    {
      id: 'common-instance',
      title: 'Common instance for creating and tracking APIs'
    },
    {
      id: 'basic-api-integration-setup',
      title: 'Basic API integration setup'
    }
  ]

  // eslint-disable-next-line @typescript-eslint/naming-convention -- Following PF team guidelines
  const CatalogWithSections = useMemo(
    () => (
      <>
        {categories.map(category => {
          return (
            <QuickStartCatalogSection key={category.id}>
              <TextContent>
                <Text className="catalog" component="h2">{category.title}</Text>
              </TextContent>
              <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
                {allQuickStarts!
                  .filter((quickStart: QuickStart) => quickStart.metadata.labels?.category == category.id)
                  .map((quickStart: QuickStart) => {
                    const {
                      metadata: { name: id }
                    } = quickStart
                    return (
                      <GalleryItem key={id} className="pfext-quick-start-catalog__gallery-item">
                        <QuickStartTile
                          isActive={id === activeQuickStartID}
                          quickStart={quickStart}
                          status={getQuickStartStatus(allQuickStartStates!, id)}
                        />
                      </GalleryItem>
                    )
                  })}
              </Gallery>
            </QuickStartCatalogSection>
          )
        })}
      </>
    ),
    [activeQuickStartID, allQuickStartStates, allQuickStarts]
  )

  const quickStartCatalog = useMemo(() => {
    return CatalogWithSections
  }, [CatalogWithSections, allQuickStarts!.length])

  if (loading) {
    return <LoadingBox />
  }

  return (
    <>
      <QuickStartCatalogHeader hint="Learn how to create, import, and run applications with step-by-step instructions and tasks." title="Quick starts" />
      {quickStartCatalog}
    </>
  )
}
