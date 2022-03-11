# Testing the Bugsnag Cocoa notifier

## End-to-end tests

These tests are implemented with our notifier testing tool [Maze runner](https://github.com/bugsnag/maze-runner).

End to end tests are written in cucumber-style `.feature` files, and need Ruby-backed "steps" in order to know what to
run. The tests are located in the ['features'](/features/) directory.

### Requirements

- Xcode
- Make
- BrowserStack credentials or device running a modern version of iOS.

### Building the test fixture apps

Build the test fixtures:
```shell script
make test-fixtures
```

### Running tests on BrowserStack (typically Bugsnag employees only)

1. Ensure the following environment variables are set:
   - `BROWSERSTACK_USERNAME` - your BrowserStack App Automate Username
   - `BROWSERSTACK_ACCESS_KEY` - your BrowserStack App Automate Access Key
   - `MAZE_BS_LOCAL` - location of the `BrowserStackLocal` executable on your local file system
2. See https://www.browserstack.com/local-testing/app-automate for details of the required local testing binary.
3. Check the contents of `Gemfile` to select the version of `maze-runner` to use
4. To run all features (on iOS):
    ```shell script
    bundle exec maze-runner --app=./features/fixtures/app/build/ios/ipa/app.ipa \
                            --farm=bs                                           \
                            --device=IOS_14
    ```

### Running tests on your own device

#### Prerequisites

1. Install a proxy server such as `mitmproxy`:
   ```shell script
   brew install mitmproxy
   ```
2. Install Appium
   ```
   npm install -g appium@1.21
   ```
3. Set `MAZE_APPLE_TEAM_ID` to your Apple Developer Team Id.
4. The test fixture is hard-coded to send requests to `bs-local.com:9339` (BrowserStack's approach to local testing).  
   Add an entry for bs-local.com to `/etc/hosts`:
   ```
   127.0.0.1       bs-local.com
   ```
5. Run the proxy
    ```shell script
   mitmproxy
   ```
6. Set a manual proxy on your device's network connection to the IP of your Mac and port of the proxy
   (8080 by default for `mitmproxy`).

#### Running tests

1. Run Maze Runner as follows, adjusting for your specific device:
    ```shell script
    bundle exec maze-runner --app=./features/fixtures/app/build/ios/ipa/app.ipa \
                            --udid=<udid>                                       \
                            --os=ios                                            \
                            --os-version=14
    ```
   `<udid>` is the device Identifier found under Devices and Simulators in Xcode.

### Notes

1. Maze Runner supports various other options, as well as all those that Cucumber does. For full details run:
    ```shell script
    `bundle exec maze-runner --help`
    ```
