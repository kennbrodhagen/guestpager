require('coffee-script');
factory = require('./factory');

var App = require("./app");
var log = factory.createProductionLog();
var app = new App(log, factory.createProductionStore(log, factory.createTestGuests()));

app.server.listen(app.server.settings.port);
app.log.info("Express server listening on port %d in %s mode", app.server.settings.port, app.server.settings.env);
