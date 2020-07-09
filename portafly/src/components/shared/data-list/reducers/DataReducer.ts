import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'

export type DataState = { id: number }[]

// Action Handlers
const SET_DATA = 'SET_DATA'

type SetDataAction = Action<DataState>

const filtersActionHandlers: ActionHandlers<DataState, DataState> = {
  [SET_DATA]: (state, action: SetDataAction) => action.payload
}

// Reducer
const dataReducer = createReducer(filtersActionHandlers)

// Hook
interface IUseData<T extends DataState> {
  state: Record<'data', T>
  dispatch: React.Dispatch<Action<T>>
}
const useData = <T extends DataState>({ state, dispatch }: IUseData<T>) => ({
  data: state.data,
  setData: (data: T) => dispatch({ type: SET_DATA, payload: data })
})

export { dataReducer, useData }
