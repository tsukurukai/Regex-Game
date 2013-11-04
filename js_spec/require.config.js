var tests = [];
for (var file in window.__karma__.files) {
  if (window.__karma__.files.hasOwnProperty(file)) {
    if (/Spec\.js$/.test(file)) {
      tests.push(file);
    }
  }
}

require.config({
  baseUrl: "/base/assets/js",
  paths: {
    "underscore": "lib/underscore",
    "backbone": "lib/backbone"
  },
  shim: {
    "underscore": {
      exports: "_"
    },
    "backbone": {
      deps: ["underscore"],
      exports: "Backbone"
    },
    "stopwatch": {
      exports: "Stopwatch"
    }
  },
  deps: tests,
  callback: window.__karma__.start
});

