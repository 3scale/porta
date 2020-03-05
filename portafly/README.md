# PortaFly
A React SPA crafted with the ambitious purpose of replacing Porta UI, currently residing inside the Rails App.

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
