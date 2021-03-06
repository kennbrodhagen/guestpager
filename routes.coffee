# HTTP 	Verb		Path								action			used for
# GET						/guests							index				display a list of all guests
# GET						/guests/new					new					return an HTML form for creating a new todo
# POST					/guests							create			create a new todo
# GET						/guests/:id					show				display a specific todo
# GET						/guests/:id/edit		edit				return an HTML form for editing a todo
# PUT/POST			/guests/:id					update			update a specific todo
# DELETE				/guests/:id					destroy			delete a specific todo

router = (app) ->
	#app.log.info {store: app.store}, "router init store = #{app.store}"
	HomeController =  require("./controllers/home")
	homeController =  new HomeController(app)

	GuestsController = require("./controllers/guests")
	guestsController = new GuestsController(app)


	app.server.get '/', (req, res) ->
		res.redirect '/home'

	app.server.get '/home', homeController.index
	app.server.get '/guests', guestsController.index
	app.server.get '/guests/new', guestsController.new
	app.server.post '/guests', guestsController.create
	app.server.get '/guests/:id/edit', guestsController.edit
	app.server.post '/guests/:id', guestsController.update
	app.server.delete '/guests/:id', guestsController.destroy

module.exports = router
