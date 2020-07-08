import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'
import { IDeveloperAccount, IApplication } from 'types'

// Union Type of the different Data Types a DataListContext will hold
export type DataState = IDeveloperAccount[] | IApplication[]

// Action Handlers
const SET_DATA = 'SET_DATA'

type SetDataAction = Action<DataState>

const filtersActionHandlers: ActionHandlers<DataState, DataState> = {
  [SET_DATA]: (state, action: SetDataAction) => action.payload
}

// Reducer
const dataReducer = createReducer(filtersActionHandlers)

// Hook
interface IUseData {
  state: Record<'data', DataState>
  dispatch: React.Dispatch<Action<DataState>>
}
const useData = ({ state, dispatch }: IUseData) => ({
  data: state.data,
  setData: (data: DataState) => dispatch({ type: SET_DATA, payload: data })
})

export { dataReducer, useData }
