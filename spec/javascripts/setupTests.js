// @flow

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

Enzyme.configure({adapter: new Adapter()})

import * as utils from 'utilities/utils'
jest.mock('utilities/utils')
jest.spyOn(utils, 'CSRFToken')
  .mockImplementation(() => '')
