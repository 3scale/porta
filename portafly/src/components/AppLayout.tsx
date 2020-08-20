import * as React from 'react'
import {
  Nav,
  NavList,
  Page,
  PageHeader,
  PageSidebar,
  SkipToContent,
  PageHeaderProps
} from '@patternfly/react-core'
import { AppNavExpandable, IAppNavExpandableProps } from 'components/AppNavExpandable'
import { AppNavGroup, IAppNavGroupProps } from 'components/AppNavGroup'
import { AppNavItem, IAppNavItemProps } from 'components/AppNavItem'

export interface IAppLayoutContext {
  setBreadcrumb: (breadcrumb: React.ReactNode) => void
}

export const AppLayoutContext = React.createContext<IAppLayoutContext>({
  setBreadcrumb: () => 0
})

export interface IAppLayoutProps extends Pick<PageHeaderProps, 'logo' | 'logoProps' | 'headerTools'> {
  navVariant?: 'vertical' | 'horizontal'
  navItems?: Array<IAppNavItemProps | IAppNavExpandableProps | IAppNavGroupProps | undefined>
  navGroupsStyle?: 'grouped' | 'expandable'
  startWithOpenNav?: boolean
  theme?: 'dark' | 'light'
  mainContainerId?: string
}

export const AppLayout: React.FunctionComponent<IAppLayoutProps> = ({
  logo,
  logoProps,
  navVariant = 'horizontal',
  navItems = [],
  navGroupsStyle = 'grouped',
  headerTools,
  startWithOpenNav = true,
  theme = 'dark',
  mainContainerId = 'main-container',
  children
}) => {
  const [isNavOpen, setIsNavOpen] = React.useState(startWithOpenNav)
  const [isMobileView, setIsMobileView] = React.useState(true)
  const [isNavOpenMobile, setIsNavOpenMobile] = React.useState(false)
  const [breadcrumb, setBreadcrumb] = React.useState<React.ReactNode | undefined>()
  const previousBreadcrumb = React.useRef<React.ReactNode | null>()

  const handleSetBreadcrumb = React.useCallback(
    (newBreadcrumb: React.ReactNode) => {
      if (previousBreadcrumb.current !== newBreadcrumb) {
        previousBreadcrumb.current = newBreadcrumb
        setBreadcrumb(previousBreadcrumb.current)
      }
    },
    [setBreadcrumb, previousBreadcrumb]
  )

  const onNavToggleMobile = React.useCallback(() => {
    setIsNavOpenMobile(!isNavOpenMobile)
  }, [setIsNavOpenMobile, isNavOpenMobile])

  const onNavToggle = React.useCallback(() => {
    setIsNavOpen(!isNavOpen)
  }, [setIsNavOpen, isNavOpen])

  const onPageResize = (props: { mobileView: boolean; windowSize: number }) => {
    setIsMobileView(props.mobileView)
  }

  React.useEffect(() => {
    setIsNavOpen(startWithOpenNav)
  }, [startWithOpenNav, setIsNavOpen])

  const isVertical = navVariant === 'vertical'
  const variant = isVertical ? 'default' : 'horizontal'

  const Navigation = React.useMemo(
    () => navItems.length > 0 && (
    <Nav id="nav-primary-simple" theme={theme} variant={variant}>
      <NavList id="nav-list-simple">
        {navItems.map((navItem) => {
          // eslint-disable-next-line no-prototype-builtins
          if (navItem && navItem.hasOwnProperty('items') && isVertical) {
            if (navGroupsStyle === 'expandable') {
              const { title, to, items } = navItem as IAppNavExpandableProps
              return <AppNavExpandable title={title} to={to} items={items} key={title} />
            }

            const { title, items } = navItem as IAppNavGroupProps
            return <AppNavGroup title={title} items={items} key={title} />
          }

          // TODO: extract NavItemSeparator from AppNavItem to clean this up
          const item = navItem as (IAppNavItemProps | undefined)
          return (
            <AppNavItem
              title={item?.title}
              to={item?.to}
              exact={item?.exact}
              key={item?.title}
            />
          )
        })}
      </NavList>
    </Nav>
    ),
    [isVertical, navGroupsStyle, navItems, theme, variant]
  )

  const Header = React.useMemo(
    () => (
      <PageHeader
        logo={logo}
        logoProps={logoProps}
        headerTools={headerTools}
        showNavToggle={isVertical}
        isNavOpen={isVertical && isNavOpen}
        onNavToggle={isMobileView ? onNavToggleMobile : onNavToggle}
        topNav={isVertical ? undefined : Navigation}
      />
    ),
    [
      logo,
      logoProps,
      headerTools,
      isVertical,
      isNavOpen,
      isMobileView,
      onNavToggle,
      onNavToggleMobile,
      Navigation
    ]
  )

  const Sidebar = React.useMemo(
    () => navVariant === 'vertical' && (
    <PageSidebar
      nav={Navigation}
      isNavOpen={isMobileView ? isNavOpenMobile : isNavOpen}
      theme={theme}
      data-testid="app-sidebar"
    />
    ),
    [navVariant, Navigation, isMobileView, isNavOpenMobile, isNavOpen, theme]
  )
  const PageSkipToContent = (
    <SkipToContent href="#primary-app-container">
      Skip to Content
    </SkipToContent>
  )
  return (
    <AppLayoutContext.Provider value={{ setBreadcrumb: handleSetBreadcrumb }}>
      <Page
        mainContainerId={mainContainerId}
        header={Header}
        sidebar={Sidebar}
        breadcrumb={breadcrumb}
        onPageResize={onPageResize}
        skipToContent={PageSkipToContent}
      >
        {children}
      </Page>
    </AppLayoutContext.Provider>
  )
}
