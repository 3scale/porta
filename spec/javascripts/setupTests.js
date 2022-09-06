// @flow

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import $ from 'jquery'
global.jQuery = $

Enzyme.configure({ adapter: new Adapter() })
