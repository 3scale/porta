import {
  CustomParameterRow as parameterRow
} from 'ActiveDocs/customize/wrappedComponents/Parameters'

export const WrappedComponentsPlugin = (system) => {
  return {
    wrapComponents: {
      parameterRow
    }
  }
}
