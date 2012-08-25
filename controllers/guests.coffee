# HTTP 	Verb		Path								action			used for
# GET						/guests							index				display a list of all guests
# GET						/guests/new					new					return an HTML form for creating a new todo
# POST					/guests							create			create a new todo
# GET						/guests/:id					show				display a specific todo
# GET						/guests/:id/edit		edit				return an HTML form for editing a todo
# PUT/POST			/guests/:id					update			update a specific todo
# DELETE				/guests/:id					destroy			delete a specific todo

buildGuestFromBody = (body) ->
	guest = 
		id: body.id
		name: body.name
		description: body.description
		mobileNumber: body.mobileNumber

class GuestsController
	constructor: (app) ->
		@app = app

	create: (req, res) =>
		app = @app
		guest = buildGuestFromBody(req.body)
		app.store.addOrUpdateGuest buildGuestFromBody(req.body), (err, guest) ->
			res.redirect "/guests"

	index: (req, res) =>
		#@app.log.info {req: req}, "guestsController#index"
		app = @app
		app.store.findAllGuests (err, guests) ->
			renderArgs = {title: 'guests', guests:guests}
			#app.log.info renderArgs, "GuestsController.index:"
			res.render 'guests-index', renderArgs 

	new: (req, res) =>
		#@app.log.info {req: req}, "guestsController#new"
		renderArgs = {title: "Add Guest"}
		res.render 'guests-new', renderArgs

	edit: (req, res) =>
		app = @app
		id = req.param "id"
		app.store.findGuestById id, (err, guest) ->
			renderArgs = {title: "Edit Guest", guest: guest}
			res.render "guests-edit", renderArgs

module.exports = GuestsController