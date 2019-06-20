const fs = require('fs')
const fse = require('fs-extra')
const path = require('path')
const concat = require('concat')
const { getStylesheetPaths, transform } = require('@patternfly/patternfly/scripts/ie-conversion-utils')
// const myAppStylesheetPath = path.resolve(__dirname, './main.css')
const toPath = 'app/assets/stylesheets/provider/_patternfly-ie11.scss'

// const filesThatNeedPathAdjustments = [
//   path.resolve(__dirname, './node_modules/@patternfly/patternfly/components/BackgroundImage/background-image.css'),
//   path.resolve(__dirname, './node_modules/@patternfly/patternfly/components/AboutModalBox/about-modal-box.css')
// ]

// function fixAssetPaths (files) {
//   // fix path discrepancy between .pf-c-background-image and font definitions
//   files.map(filePath => {
//     const startingCss = fs.readFileSync(filePath, 'utf8').match(/[^\r\n]+/g)
//     const cssWithFixedPaths = startingCss.map(
//       line => {
//         const re = new RegExp('../../assets', 'g')
//         return (line.includes('../../assets')) ? line.replace(re, './assets') : line
//       }).join('\n')

//     // update these files in place
//     fs.writeFileSync(
//       filePath,
//       cssWithFixedPaths
//     )
//   })
// }

// fixAssetPaths(filesThatNeedPathAdjustments)
const patternflyBasePath = path.resolve(__dirname, './node_modules/@patternfly/patternfly/patternfly-base.css')

const pfStylesheetsGlob = path.resolve(__dirname, './node_modules/@patternfly/patternfly/{components,layouts,utilities}/{Page,Nav,Header}/*.css')
const stylesheetsToExclude = []

getStylesheetPaths(pfStylesheetsGlob, stylesheetsToExclude, [])
  .then(concat)
  .then(concatCss => transform(concatCss, patternflyBasePath))
  .then(ie11ReadyStylesheet => {
    fs.writeFileSync(
      path.resolve(__dirname, toPath),
      ie11ReadyStylesheet
    )

    const sourceAssetsDir = path.resolve(__dirname, './node_modules/@patternfly/patternfly/assets')
    const newAssetDir = path.resolve(__dirname, './app/assets/patternfly')

    fse.copy(sourceAssetsDir, newAssetDir, function (error) {
      if (error) {
        throw new Error(error)
      }
    })
  })
  .catch(error => {
    throw new Error(error)
  })
