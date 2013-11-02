require.config({
  baseUrl: "/js",
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
    }
  }
});
