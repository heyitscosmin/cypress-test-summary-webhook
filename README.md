# cypress-test-summary-webhook
## Cypress Test Automation Summary with MS Teams Notifications
This project provides a practical example of how to send a Microsoft Teams notification with a test results summary using a shell script. It demonstrates generating Cypress test reports and automating the notification process directly from your pipeline.  
## Dependencies
```shell
npm install --save-dev cypress-multi-reporters
```
```shell
npm install --save-dev mocha-junit-reporter
```
## Cypress configuration
In your cypress.config.js file, configure the reporters as follows:
```javascript
module.exports = defineConfig({
  reporter: 'cypress-multi-reporters',
  reporterOptions: {
    reporterEnabled: 'spec, mocha-junit-reporter',
    mochaJunitReporterReporterOptions: {
      mochaFile: './test-results/[suiteFilename].xml',
    },
  },
});
```
### Explanation
* cypress-multi-reporters: Enables the use of multiple reporters simultaneously.
* mocha-junit-reporter: Generates JUnit-style XML files under the test-results folder after tests are executed.
* [suiteFilename].xml: Allows saving results with a specific naming format for easy identification.
## Running the tests
```shell
npx cypress run
```
After the tests finish executing, a test-results folder will be created in the project directory, containing the test result XML files.
## Sending Results to Microsoft Teams 
```shell
./notify.sh <WEBHOOK>
```
The notify.sh script inspects the test-results folder to extract detailed information about test outcomes, including the number of passed tests, failed tests and the total number of tests executed.
For more details on how it is made, take a look inside notify.sh