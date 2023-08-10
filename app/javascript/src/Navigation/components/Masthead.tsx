import { useState } from 'react'
import {
  Brand,
  Button,
  Dropdown,
  DropdownItem,
  DropdownToggle,
  MastheadBrand,
  MastheadContent,
  MastheadMain,
  MastheadToggle,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem
} from '@patternfly/react-core'
import QuestionCircleIcon from '@patternfly/react-icons/dist/js/icons/question-circle-icon'
import UserIcon from '@patternfly/react-icons/dist/js/icons/user-icon'
import BoltIcon from '@patternfly/react-icons/dist/js/icons/bolt-icon'
import BarsIcon from '@patternfly/react-icons/dist/js/icons/bars-icon'

import { createReactWrapper } from 'utilities/createReactWrapper'
import { ContextSelector } from 'Navigation/components/ContextSelector'
import { InlineIcon } from 'Navigation/components/InlineIcon'

import type { Props as ContextSelectorProps } from 'Navigation/components/ContextSelector'
import type { FunctionComponent } from 'react'

import './Masthead.scss'

interface Props {
  brandHref: string;
  contextSelectorProps: ContextSelectorProps;
  currentAccount: string;
  currentUser: string;
  documentationMenuItems: {
    title: string;
    href: string;
    icon: string;
    target?: string;
  }[];
  impersonating?: boolean;
  signOutHref: string;
  verticalNavHidden?: boolean;
}

const srcSet = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMzY0IDI0NCI+PGRlZnM+PHN0eWxlPi5he2ZpbGw6I2ZmZjt9LmJ7ZmlsbDojZTAwO308L3N0eWxlPjwvZGVmcz48dGl0bGU+TG9nby1SZWRfSGF0LTNzY2FsZV9BUElfTWFuYWdlbWVudC1BLVJldmVyc2UtUkdCPC90aXRsZT48cGF0aCBjbGFzcz0iYSIgZD0iTTI1MC44OSwyMjAuODljLTEwLjE5LDAtMjAuMjgtMy40My0yNy41Ni0xMC43MWw3LTYuNTZjNi43Niw2LjU2LDEyLjksOC4zMiwyMC40OSw4LjMyLDEwLjMsMCwxNy4xNi01LjMsMTcuMTYtMTIuNjgsMC02LjU2LTYuMTQtMTEuNTUtMTYuNTQtMTEuNTVoLTYuMzR2LTguNDJoNS41MWM5LjI2LDAsMTQuODgtNS45MywxNC44OC0xMi42OVMyNTguOSwxNTUsMjUwLjQ4LDE1NWMtNy4xOCwwLTEyLjQ4LDItMTkuMzUsOC43NGwtNy02LjY2YTM3LDM3LDAsMCwxLDI2LjUyLTExLjEzYzE0LjU2LDAsMjUuMDYsOC4zMiwyNS4wNiwyMCwwLDctNC4xNiwxMy4zMS0xMS44NiwxNi44NSw5LjE2LDIuNywxNC41Nyw5LjM2LDE0LjU3LDE3LjA2QzI3OC40NiwyMTIuMDUsMjY2LjkxLDIyMC44OSwyNTAuODksMjIwLjg5WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNMjkwLDIwNi4xMmEyNy4yMywyNy4yMywwLDAsMCwxNy4yNiw2LjY2YzguMzIsMCwxMi42OS0zLjY0LDEyLjY5LTcuOTEsMC0zLjc0LTIuNi01LjkzLTguNTMtNi43NmwtOS41Ny0xLjM1QzI5MS40NSwxOTUuMywyODYsMTkwLjMxLDI4NiwxODIuMWMwLTkuNjgsOC41My0xNiwyMC43LTE2YTM2LjM0LDM2LjM0LDAsMCwxLDIxLjMyLDYuNzZsLTUuMyw2Ljg2Yy01LjEtMy40My0xMC40LTUuNTEtMTYuNzUtNS41MS02LjEzLDAtMTAuNjEsMi43MS0xMC42MSw3LjE4LDAsMy45NSwyLjUsNS43Miw4Ljc0LDYuNjVsOS41NywxLjM2YzEwLjcxLDEuNTYsMTYsNi42NSwxNiwxNC43NiwwLDkuNTctOS41NywxNi42NC0yMi4xNiwxNi42NC04Ljg0LDAtMTcuMTYtMi42LTIzLjE5LTcuOFoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTM3Ny43NywyMDUuMThsNi4yNCw2Ljc2YTI5LjI1LDI5LjI1LDAsMCwxLTIwLjksOC44NCwyNy40NiwyNy40NiwwLDAsMSwwLTU0LjkxLDMwLjMyLDMwLjMyLDAsMCwxLDIxLjMyLDguODRsLTYuNTUsNy4wN2ExOS42OCwxOS42OCwwLDAsMC0xNC41Ni02LjY1Yy05LjY4LDAtMTcuMTcsOC0xNy4xNywxOC4yLDAsMTAuNCw3LjYsMTguMywxNy4zNywxOC4zQzM2OC45MywyMTEuNjMsMzczLjYxLDIwOS40NSwzNzcuNzcsMjA1LjE4WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNMzg5LjgzLDIwNC42NmMwLTEwLjYsOS4wNS0xNi4xMiwyMS40My0xNi4xMmEzNi40MSwzNi40MSwwLDAsMSwxNC40NSwyLjkydi01LjYyYzAtNy40OS00LjQ3LTExLjIzLTEyLjg5LTExLjIzLTUuMSwwLTEwLjMsMS41Ni0xNi40Myw0LjQ3bC0zLjg1LTcuOGM3LjQ5LTMuNTQsMTQuMzUtNS40MSwyMS43My01LjQxLDEzLjYzLDAsMjEuNjQsNi42NiwyMS42NCwxOC45M3YzNWgtMTAuMnYtNC41OGMtNC41NywzLjc1LTEwLDUuNTEtMTYuNDMsNS41MUMzOTcuNzQsMjIwLjc4LDM4OS44MywyMTQuMTMsMzg5LjgzLDIwNC42NlptMjEuODQsOC40M2EyMC4zOCwyMC4zOCwwLDAsMCwxNC01di05LjI2YTI3LjczLDI3LjczLDAsMCwwLTEzLjYyLTMuMTJjLTcuMjgsMC0xMi4yNywzLjIyLTEyLjI3LDguNzRDMzk5LjgyLDIwOS42Niw0MDQuNzEsMjEzLjA5LDQxMS42NywyMTMuMDlaIi8+PHBhdGggY2xhc3M9ImEiIGQ9Ik00NTguMjYsMjE5Ljg1aC0xMC40di03Mi44bDEwLjQtMi4yOVoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTQ5NC41NiwxNjYuMDhjMTQuNTYsMCwyNS41OCwxMi4wNiwyNS41OCwyNy42NnYzaC00MS44YTE3Ljg0LDE3Ljg0LDAsMCwwLDE3Ljg4LDE1LjE4LDIwLjU2LDIwLjU2LDAsMCwwLDEzLjQyLTQuNjhsNi42Niw2LjU2YTMxLjI1LDMxLjI1LDAsMCwxLTIwLjQ5LDdjLTE1LjYsMC0yNy43Ny0xMi0yNy43Ny0yNy40NUM0NjgsMTc4LjE0LDQ3OS41OCwxNjYuMDgsNDk0LjU2LDE2Ni4wOFpNNDc4LjQ0LDE4OWgzMS40MWMtMS40Ni04LjExLTcuOC0xNC4xNC0xNS41LTE0LjE0QzQ4Ni4yNCwxNzQuODIsNDgwLDE4MC42NCw0NzguNDQsMTg5WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNNTc1Ljg5LDE0Ny4wNWgxMi43OWwyOS43NSw3Mi44SDYwNi41N2wtOC40My0yMS4zMkg1NjUuNTlsLTguNTMsMjEuMzJINTQ1LjczWm0xOC43Miw0Mi40My0xMi42OS0zMS45My0xMi42OSwzMS45M1oiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTYyNS45MSwxNDcuMDVoMzMuN2MxNC4zNSwwLDIzLjgxLDguOTQsMjMuODEsMjEuODQsMCwxMi41OC05LjQ2LDIxLjYzLTIzLjgxLDIxLjYzSDYzNi44M3YyOS4zM0g2MjUuOTFabTEwLjkyLDkuNTZ2MjQuNjVoMjEuNjNjOC44NCwwLDEzLjk0LTUuMDksMTMuOTQtMTIuMzdzLTUuMS0xMi4yOC0xMy45NC0xMi4yOFoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTY5NC42NSwxNDcuMDVoMTAuOTJ2NzIuOEg2OTQuNjVaIi8+PHBhdGggY2xhc3M9ImEiIGQ9Ik03NTIuMzcsMTYwLjU3djU5LjI4SDc0Mi4xOHYtNzIuOGgxNC41NmwyMi44OCw0Ni40OSwyMi43OC00Ni40OUg4MTd2NzIuOGgtMTAuM1YxNjAuNDZsLTI3LjE0LDU0LjE5WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNODI2LjczLDIwNC42NmMwLTEwLjYsOS0xNi4xMiwyMS40My0xNi4xMmEzNi40MSwzNi40MSwwLDAsMSwxNC40NSwyLjkydi01LjYyYzAtNy40OS00LjQ3LTExLjIzLTEyLjg5LTExLjIzLTUuMSwwLTEwLjMsMS41Ni0xNi40NCw0LjQ3bC0zLjg0LTcuOGM3LjQ4LTMuNTQsMTQuMzUtNS40MSwyMS43My01LjQxLDEzLjYzLDAsMjEuNjQsNi42NiwyMS42NCwxOC45M3YzNWgtMTAuMnYtNC41OGMtNC41NywzLjc1LTEwLDUuNTEtMTYuNDMsNS41MUM4MzQuNjQsMjIwLjc4LDgyNi43MywyMTQuMTMsODI2LjczLDIwNC42NlptMjEuODQsOC40M2EyMC4zOCwyMC4zOCwwLDAsMCwxNC01di05LjI2QTI3LjczLDI3LjczLDAsMCwwLDg0OSwxOTUuNzJjLTcuMjgsMC0xMi4yNywzLjIyLTEyLjI3LDguNzRDODM2LjcyLDIwOS42Niw4NDEuNiwyMTMuMDksODQ4LjU3LDIxMy4wOVoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTg4NC43NiwxNjYuOTFoMTAuNHY1LjNhMjEuNjQsMjEuNjQsMCwwLDEsMTUuOTItNi4zNGMxMi4xNiwwLDIwLjU5LDguNTMsMjAuNTksMjAuN3YzMy4yOGgtMTAuM1YxODguMzRjMC04LjIyLTUtMTMuNDItMTMuMjEtMTMuNDJhMTQuOTIsMTQuOTIsMCwwLDAtMTMsNi44NnYzOC4wN2gtMTAuNFoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTk0MS4xMywyMDQuNjZjMC0xMC42LDktMTYuMTIsMjEuNDItMTYuMTJBMzYuNSwzNi41LDAsMCwxLDk3NywxOTEuNDZ2LTUuNjJjMC03LjQ5LTQuNDctMTEuMjMtMTIuOS0xMS4yMy01LjA5LDAtMTAuMjksMS41Ni0xNi40Myw0LjQ3bC0zLjg1LTcuOGM3LjQ5LTMuNTQsMTQuMzYtNS40MSwyMS43NC01LjQxLDEzLjYzLDAsMjEuNjMsNi42NiwyMS42MywxOC45M3YzNUg5Nzd2LTQuNThjLTQuNTgsMy43NS0xMCw1LjUxLTE2LjQzLDUuNTFDOTQ5LDIyMC43OCw5NDEuMTMsMjE0LjEzLDk0MS4xMywyMDQuNjZaTTk2MywyMTMuMDlhMjAuMzgsMjAuMzgsMCwwLDAsMTQtNXYtOS4yNmEyNy43OCwyNy43OCwwLDAsMC0xMy42Mi0zLjEyYy03LjI4LDAtMTIuMjgsMy4yMi0xMi4yOCw4Ljc0Qzk1MS4xMSwyMDkuNjYsOTU2LDIxMy4wOSw5NjMsMjEzLjA5WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNOTk2Ljg3LDE5My4xMkEyNi43MSwyNi43MSwwLDAsMSwxMDIzLjcxLDE2NmEyNS41NiwyNS41NiwwLDAsMSwxNS43LDUuMzF2LTQuMzdoMTAuM3Y1My4zNWMwLDEzLjk0LTguNzQsMjEuNDMtMjQuMjQsMjEuNDNhNDQuMDYsNDQuMDYsMCwwLDEtMjEuMzItNS4ybDQuMDYtOC4xMWM2LDMuMTIsMTEuMzMsNC41NywxNyw0LjU3LDkuMjYsMCwxNC4xNS00LjI2LDE0LjE1LTEyLjU4di01LjcyYTI0LjY5LDI0LjY5LDAsMCwxLTE1LjgxLDUuNjFDMTAwOC41MiwyMjAuMjYsOTk2Ljg3LDIwOC4zLDk5Ni44NywxOTMuMTJabTI3Ljg4LDE4LjFhMTkuMSwxOS4xLDAsMCwwLDE0LjU2LTYuMTRWMTgxLjE2YTE5LjEsMTkuMSwwLDAsMC0xNC41Ni02LjE0Yy0xMCwwLTE3LjY5LDcuOTEtMTcuNjksMTguMVMxMDE0Ljc2LDIxMS4yMiwxMDI0Ljc1LDIxMS4yMloiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTEwODYsMTY2LjA4YzE0LjU2LDAsMjUuNTksMTIuMDYsMjUuNTksMjcuNjZ2M2gtNDEuODFhMTcuODQsMTcuODQsMCwwLDAsMTcuODgsMTUuMTgsMjAuNTQsMjAuNTQsMCwwLDAsMTMuNDItNC42OGw2LjY2LDYuNTZhMzEuMjUsMzEuMjUsMCwwLDEtMjAuNDksN2MtMTUuNiwwLTI3Ljc3LTEyLTI3Ljc3LTI3LjQ1QzEwNTkuNDgsMTc4LjE0LDEwNzEsMTY2LjA4LDEwODYsMTY2LjA4Wk0xMDY5Ljg4LDE4OWgzMS40MWMtMS40Ni04LjExLTcuOC0xNC4xNC0xNS41LTE0LjE0QzEwNzcuNjgsMTc0LjgyLDEwNzEuNDQsMTgwLjY0LDEwNjkuODgsMTg5WiIvPjxwYXRoIGNsYXNzPSJhIiBkPSJNMTEyMS4zNiwxNjYuOTFoMTAuNHY0Ljg5YTIwLjIzLDIwLjIzLDAsMCwxLDE0Ljc3LTUuOTMsMTguODcsMTguODcsMCwwLDEsMTYuNDMsOC43NGM0LjI2LTUuNzIsMTAuMy04Ljc0LDE3Ljg5LTguNzQsMTEuNjUsMCwxOS43Niw4LjUzLDE5Ljc2LDIwLjd2MzMuMjhoLTEwLjNWMTg4LjM0YzAtOC4yMi00LjU3LTEzLjQyLTEyLjE2LTEzLjQyLTUuMzEsMC05LjQ3LDIuNDktMTIuMzgsNy4wN2EyMi4yNCwyMi4yNCwwLDAsMSwuNDIsNC41OHYzMy4yOGgtMTAuNFYxODguMzRjMC04LjIyLTQuNTgtMTMuNDItMTIuMDctMTMuNDJhMTMuNzUsMTMuNzUsMCwwLDAtMTIsNi4zNHYzOC41OWgtMTAuNFoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTEyMzYuOSwxNjYuMDhjMTQuNTYsMCwyNS41OSwxMi4wNiwyNS41OSwyNy42NnYzaC00MS44MWExNy44NCwxNy44NCwwLDAsMCwxNy44OSwxNS4xOCwyMC41MSwyMC41MSwwLDAsMCwxMy40MS00LjY4bDYuNjYsNi41NmEzMS4yNSwzMS4yNSwwLDAsMS0yMC40OSw3Yy0xNS42LDAtMjcuNzctMTItMjcuNzctMjcuNDVDMTIxMC4zOCwxNzguMTQsMTIyMS45MywxNjYuMDgsMTIzNi45LDE2Ni4wOFpNMTIyMC43OCwxODloMzEuNDFjLTEuNDUtOC4xMS03LjgtMTQuMTQtMTUuNDktMTQuMTRDMTIyOC41OCwxNzQuODIsMTIyMi4zNCwxODAuNjQsMTIyMC43OCwxODlaIi8+PHBhdGggY2xhc3M9ImEiIGQ9Ik0xMjcyLjI2LDE2Ni45MWgxMC40djUuM2EyMS42NCwyMS42NCwwLDAsMSwxNS45MS02LjM0YzEyLjE3LDAsMjAuNiw4LjUzLDIwLjYsMjAuN3YzMy4yOGgtMTAuM1YxODguMzRjMC04LjIyLTUtMTMuNDItMTMuMjEtMTMuNDJhMTQuOTEsMTQuOTEsMCwwLDAtMTMsNi44NnYzOC4wN2gtMTAuNFoiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTEzMzYuMTIsMTc1LjY1aC0xMS4yNHYtOC43NGgxMS4yNFYxNTMuMzlsMTAuMjktMi41djE2SDEzNjJ2OC43NGgtMTUuNnYyOC43YzAsNS40MSwyLjE5LDcuMzksNy44LDcuMzlhMjAuMjMsMjAuMjMsMCwwLDAsNy42LTEuMjV2OC43M2EzNS41NiwzNS41NiwwLDAsMS05Ljg4LDEuNTZjLTEwLjMsMC0xNS44MS00Ljg4LTE1LjgxLTE0WiIvPjxwYXRoIGNsYXNzPSJiIiBkPSJNMTI5LDg1LjMxYzEyLjUsMCwzMC42MS0yLjU5LDMwLjYxLTE3LjQ3YTE0LDE0LDAsMCwwLS4zMS0zLjQybC03LjQ1LTMyLjM2Yy0xLjczLTcuMTEtMy4yMy0xMC4zNS0xNS43NC0xNi42LTkuNy01LTMwLjgyLTEzLjE1LTM3LjA4LTEzLjE1LTUuODIsMC03LjU0LDcuNTQtMTQuNDQsNy41NC02LjY4LDAtMTEuNjQtNS42LTE3Ljg5LTUuNi02LDAtOS45Miw0LjEtMTIuOTQsMTIuNSwwLDAtOC40LDIzLjcyLTkuNDgsMjcuMTZhNi4xNSw2LjE1LDAsMCwwLS4yMiwyQzQ0LDU1LjA3LDgwLjMxLDg1LjMxLDEyOSw4NS4zMW0zMi41NS0xMS40M2MxLjcyLDguMTksMS43Miw5LjA1LDEuNzIsMTAuMTMsMCwxNC0xNS43MywyMS43Ny0zNi40MywyMS43N0M4MCwxMDUuNzgsMzkuMDYsNzguNDEsMzkuMDYsNjAuM0ExOC40NSwxOC40NSwwLDAsMSw0MC41Nyw1M0MyMy43Niw1My44MywyLDU2Ljg1LDIsNzZjMCwzMS40Nyw3NC41OCw3MC4yNywxMzMuNjUsNzAuMjcsNDUuMjcsMCw1Ni42OS0yMC40OCw1Ni42OS0zNi42NCwwLTEyLjczLTExLTI3LjE3LTMwLjgyLTM1Ljc5Ii8+PHBhdGggZD0iTTE2MS41MSw3My44OGMxLjcyLDguMTksMS43Miw5LjA1LDEuNzIsMTAuMTMsMCwxNC0xNS43MywyMS43Ny0zNi40MywyMS43N0M4MCwxMDUuNzgsMzkuMDYsNzguNDEsMzkuMDYsNjAuM0ExOC40NSwxOC40NSwwLDAsMSw0MC41Nyw1M2wzLjY3LTkuMDZhNi4xNSw2LjE1LDAsMCwwLS4yMiwyQzQ0LDU1LjA3LDgwLjMxLDg1LjMxLDEyOSw4NS4zMWMxMi41LDAsMzAuNjEtMi41OSwzMC42MS0xNy40N2ExNCwxNCwwLDAsMC0uMzEtMy40MloiLz48cGF0aCBjbGFzcz0iYSIgZD0iTTU4MS4yMiw5NC42MmMwLDExLjg4LDcuMTYsMTcuNjYsMjAuMiwxNy42NmE1Miw1MiwwLDAsMCwxMS44OC0xLjY4Vjk2LjgyQTI0LjUsMjQuNSwwLDAsMSw2MDUuNjIsOThjLTUuMzYsMC03LjM2LTEuNjgtNy4zNi02LjczVjcwLjExaDE1LjU3VjU1LjkxSDU5OC4yNnYtMThsLTE3LDMuNjh2MTQuM0g1NzB2MTQuMmgxMS4yNVptLTUyLjk0LjMxYzAtMy42OCwzLjY4LTUuNDcsOS4yNi01LjQ3YTQzLDQzLDAsMCwxLDEwLjA5LDEuMjZ2Ny4xNkEyMS41NSwyMS41NSwwLDAsMSw1MzcsMTAwLjVjLTUuNDcsMC04LjczLTIuMS04LjczLTUuNTdtNS4yLDE3LjU2YzYsMCwxMC44My0xLjI2LDE1LjM1LTQuMzF2My4zN2gxNi44M1Y3NS45YzAtMTMuNTctOS4xNS0yMS0yNC40LTIxLTguNTIsMC0xNi45MywyLTI2LDYuMWw2LjEsMTIuNTJjNi41Mi0yLjc0LDEyLTQuNDIsMTYuODMtNC40Miw3LDAsMTAuNjIsMi43MywxMC42Miw4LjMxVjgwLjFhNDkuNDIsNDkuNDIsMCwwLDAtMTIuNjItMS41OGMtMTQuMywwLTIyLjkyLDYtMjIuOTIsMTYuNzMsMCw5Ljc4LDcuNzgsMTcuMjQsMjAuMTksMTcuMjRNNDQxLDExMS41NWgxOC4wOFY4Mi43M2gzMC4yOXYyOC44Mkg1MDcuNVYzNy45M0g0ODkuNDFWNjYuMjJINDU5LjEyVjM3LjkzSDQ0MVpNMzcyLjExLDgzLjY4YzAtOCw2LjMxLTE0LjA5LDE0LjYyLTE0LjA5QTE3LjE5LDE3LjE5LDAsMCwxLDM5OC41LDczLjlWOTMuMzVhMTYuMzMsMTYuMzMsMCwwLDEtMTEuNzcsNC40MmMtOC4yMSwwLTE0LjYyLTYuMS0xNC42Mi0xNC4wOW0yNi42LDI3Ljg3aDE2LjgzVjM0LjI1bC0xNywzLjY4VjU4Ljg2YTI4LjIzLDI4LjIzLDAsMCwwLTE0LjE5LTMuNjhjLTE2LjIsMC0yOC45MiwxMi41MS0yOC45MiwyOC41YTI4LjI1LDI4LjI1LDAsMCwwLDI4LjM5LDI4LjYsMjUuMSwyNS4xLDAsMCwwLDE0LjkzLTQuODNabS03Ny4xOS00Mi43YzUuMzcsMCw5Ljg5LDMuNDcsMTEuNjgsOC44M0gzMTBjMS42OS01LjU3LDUuODktOC44MywxMS41Ny04LjgzTTI5Mi44MSw4My43OGMwLDE2LjIsMTMuMjUsMjguODIsMzAuMjksMjguODIsOS4zNiwwLDE2LjItMi41MiwyMy4yNC04LjQxbC0xMS4yNS0xMGMtMi42MywyLjc0LTYuNTIsNC4yMS0xMS4xNSw0LjIxYTE0LjM4LDE0LjM4LDAsMCwxLTEzLjY3LTguODNoMzkuNjVWODUuMzZDMzQ5LjkyLDY3LjY5LDMzOCw1NSwzMjEuODQsNTVhMjguNTgsMjguNTgsMCwwLDAtMjksMjguODFNMjYzLjQ3LDUzLjM5YzYsMCw5LjM2LDMuNzksOS4zNiw4LjMxUzI2OS40Nyw3MCwyNjMuNDcsNzBIMjQ1LjU5VjUzLjM5Wm0tMzYsNTguMTZoMTguMDlWODQuNzNoMTMuNzhsMTMuODgsMjYuODJoMjAuMTlMMjc3LjI1LDgyLjFhMjIuMjcsMjIuMjcsMCwwLDAsMTMuODgtMjAuNzJjMC0xMy4yNS0xMC40MS0yMy40NS0yNi0yMy40NUgyMjcuNVoiLz48L3N2Zz4='

const Masthead: FunctionComponent<Props> = ({
  brandHref,
  contextSelectorProps,
  currentAccount,
  currentUser,
  impersonating,
  documentationMenuItems,
  signOutHref,
  verticalNavHidden
}) => {
  const [isDocumentationOpen, setIsDocumentationOpen] = useState(false)
  const [isSessionOpen, setIsSessionOpen] = useState(false)

  const documentationItems = documentationMenuItems.map(({ title, href, icon, target }) => (
    <DropdownItem key={title} href={href} target={target}>
      <InlineIcon icon={icon} />{title}
    </DropdownItem>
  ))

  // TODO: Move this to menu_helper.rb or whatever
  const sessionItems = [
    <DropdownItem key="info" isDisabled className="pf-c-dropdown__session-info">
      { impersonating
        ? <span><BoltIcon />{` Impersonating a virtual admin user from ${currentAccount} as ${currentUser}`}</span>
        : <span>{`Signed in to ${currentAccount} as ${currentUser}`}</span>}
    </DropdownItem>,
    <DropdownItem key="sign-out" href={signOutHref}>
      <InlineIcon icon="times" />Sign Out
    </DropdownItem>
  ]

  const headerToolbar = (
    <Toolbar isFullHeight isStatic id="toolbar">
      <ToolbarContent>
        <ToolbarGroup alignment={{ default: 'alignLeft' }}>
          <ToolbarItem>
            {/* eslint-disable-next-line react/jsx-props-no-spreading -- FIXME */}
            <ContextSelector {...contextSelectorProps} />
          </ToolbarItem>
        </ToolbarGroup>

        <ToolbarGroup
          alignment={{ default: 'alignRight' }}
          variant="icon-button-group"
        >
          <ToolbarItem>
            <Dropdown
              isPlain
              dropdownItems={documentationItems}
              isOpen={isDocumentationOpen}
              position="right"
              title="Documentation"
              toggle={(
                <DropdownToggle aria-label="Documentation toggle" toggleIndicator={null} onToggle={setIsDocumentationOpen}>
                  <QuestionCircleIcon name="Documentation" />
                </DropdownToggle>
              )}
            />
          </ToolbarItem>

          <ToolbarItem>
            <Dropdown
              isPlain
              dropdownItems={sessionItems}
              isOpen={isSessionOpen}
              position="right"
              title="Session"
              toggle={(
                <DropdownToggle aria-label="Session toggle" toggleIndicator={null} onToggle={setIsSessionOpen}>
                  <UserIcon name="Session" />
                  {impersonating && <BoltIcon />}
                </DropdownToggle>
              )}
            />
          </ToolbarItem>
        </ToolbarGroup>
      </ToolbarContent>
    </Toolbar>
  )

  const handleOnClickBars = () => {
    const sidebar = document.querySelector('.pf-c-page__sidebar')
    if (sidebar) {
      sidebar.classList.toggle('pf-m-expanded')
      sidebar.classList.toggle('pf-m-collapsed')
    }
  }

  return (
    <>
      {/* eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing */}
      {verticalNavHidden || (
        <MastheadToggle>
          <Button
            aria-label="Global navigation"
            ouiaId="show_hide_menu"
            variant="plain"
            onClick={handleOnClickBars}
          >
            <BarsIcon />
          </Button>
        </MastheadToggle>
      )}
      <MastheadMain>
        <MastheadBrand href={brandHref}>
          <Brand alt="Red Hat 3scale API Management" widths={{ default: '220px' }}>
            <source srcSet={srcSet} />
          </Brand>
        </MastheadBrand>
      </MastheadMain>
      <MastheadContent>{headerToolbar}</MastheadContent>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const MastheadWrapper = (props: Props, containerId: string): void => { createReactWrapper(<Masthead {...props} />, containerId) }

export type { Props }
export { Masthead, MastheadWrapper }
