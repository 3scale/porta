# PortaFly
A React SPA crafted with the ambitious purpose of replacing Porta UI, currently residing inside the Rails App.

## Getting up and running
1. Clone the `porta` repository to your local machine
2. Create a `.env` file:
  * Create a new file in the `/portafly` root folder, and name it `.env`
  * Paste `REACT_APP_API_HOST="https://multitenant-admin.preview01.3scale.net"` into it, and Save
3. Create an Access token:
  * Access your local Porta build (or access [Preview](https://multitenant-admin.preview01.3scale.net/))
  * Navigate to Settings > Personal > Tokens
  * Click the "Add Access Token" button
  * Give your access token a Name
  * Select all scopes
  * Set permissions to Read & Write
  * Create the access token
  * Copy the access token
4. Allow CORS requests in your browser:
  * Install the CORS browser extension ([Google Chrome extension](https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf))
  * Click on the extension icon in the browser  toolbar and activate it by clicking on its logo
5. Run PortaFly: 
  * Open a terminal session
  * Navigate to `/portafly`
  * Run `yarn install`
  * Run `yarn start`
  * If the home page hasn't been displayed, open [http://localhost:3003](http://localhost:3003) in your browser.
  * Enter your access token in the input field

## Available Scripts

Inside the `portafly` directory, you can run:

### `yarn start`

Runs the app in the development mode.
Open [http://localhost:3003](http://localhost:3003) to view it in the browser.

The page will reload if you make edits.
You will also see any lint errors in the console.

### `yarn test`

Launches the test runner in the interactive watch mode.
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `yarn lint`

Runs the linter on all the JS/TS files of the project. Append `--fix` in order to apply all automatic fixes.
```
$ yarn lint --fix
```

### `yarn build`

Builds the app for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

## Environment Variables

There are some environment variables that we need and we are not happy with Create React App resolution of including `.env` files in version control.
One could decide to have a local `.env` / `.env.development` files or defining them in `.zshrc` / `.bashrc` or before  running the commands.

### Playing along with Porta

In order to avoid Node to look up tree dependencies
```bash
SKIP_PREFLIGHT_CHECK=true
```

### Development mode

Porta runs in 3000 by default (and so does CRA), so we need to choose an alternative port
```bash
PORT=3003
```
