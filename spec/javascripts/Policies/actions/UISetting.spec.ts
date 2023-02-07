import * as UISetting from 'Policies/actions/UISettings'

it('#showUiComponent should create an action', () => {
  const component = 'chain'
  expect(UISetting.showUiComponent(component)).toEqual({ type: 'SHOW_UI_COMPONENT', component })
})

it('#hideUiComponent should create an action', () => {
  const component = 'registry'
  expect(UISetting.hideUiComponent(component)).toEqual({ type: 'HIDE_UI_COMPONENT', component })
})

it('#uiComponentTransition should create an action', () => {
  const hide = 'policyConfig'
  const show = 'chain'
  expect(UISetting.uiComponentTransition({ hide, show })).toEqual({ type: 'UI_COMPONENT_TRANSITION', hide, show })
})
