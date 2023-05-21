window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">
  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    url: window.location.origin + "/venom-devnet/swagger",
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
    requestInterceptor: function (req) {
      req.headers = {
        'X-API-KEY': 'b17a652df5d642a6aa6e9dae4601685a',
      };
      return req;
    }
  });

  //</editor-fold>
};
