window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">
  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    url: window.location.origin + "/everscale/swagger",
    // urls: [{url: "http://127.0.0.1:8181/everscale/swagger", name: "Main"}, {url: "http://127.0.0.1:8181/everscale/swagger", name: "Main2"}],
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout",
    onComplete: function() {
      // console.log("ui");
      // console.log(ui);
       // ui.preauthorizeApiKey("api_key", "b17a652df5d642a6aa6e9dae4601685a");
      // ui.preauthorizeBasic("auth_basic", "username", "password");
      // ui.auth();
    },
    requestInterceptor: function (req) {
      req.headers = {
        'X-API-KEY': 'b17a652df5d642a6aa6e9dae4601685a',
      };
      return req;
    }
  });

  //</editor-fold>
};
