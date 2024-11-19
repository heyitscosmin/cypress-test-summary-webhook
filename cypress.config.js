const { defineConfig } = require("cypress");

module.exports = defineConfig({
  e2e: {
    reporter: 'cypress-multi-reporters',
    reporterOptions: {
      reporterEnabled: 'spec, mocha-junit-reporter',
      mochaJunitReporterReporterOptions: {
        mochaFile: './test-results/[suiteFilename].xml',
      },
    },
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
