# HTTP 	Verb		Path								action			used for
# GET						/guests							index				display a list of all guests
# GET						/guests/new					new					return an HTML form for creating a new todo
# POST					/guests							create			create a new todo
# GET						/guests/:id					show				display a specific todo
# GET						/guests/:id/edit		edit				return an HTML form for editing a todo
# PUT/POST			/guests/:id					update			update a specific todo
# DELETE				/guests/:id					destroy			delete a specific todo

should				= require "should"

describe "Controllers", ->
	app = null
	before (done) ->		
		factory = require "../factory"
		App = require "../app"
		log = factory.createTestLog()
		app = new App(log, factory.createTestStore(log, factory.createTestGuests()))
		log.info "STARTING Controllers test"
		done()

	after ->
		app.log.info "FINISHED Controllers test"

	describe "Guests Controller", ->

		class ControllerInspector
			constructor: ->
				@redirectedUrl = null
				@renderedTemplate = ""
				@renderedArgs = null
				@req = 
					body: {}
					params: {}
					param: (name) =>
						@req.params[name]

				@res =
					redirect: (url) =>
						#app.log.info {url: url}, "ControllerInspector.res.redirect"
						@redirectedUrl = url
					render: (template, args) =>
						#app.log.info {template: template, args: args}, "ControllerInspector.res.render:"
						@renderedTemplate = template
						@renderedArgs = args

				@items = {}

		_controllerInspector = null
		_controller = null

		beforeEach ->
			_controllerInspector = new ControllerInspector
			_controller = new (require "../controllers/guests")(app)
			
		describe "GuestsController.index method tests", ->		

			it "should render guests-index template", ->
				_controller.index _controllerInspector.req, _controllerInspector.res
				should.exist _controllerInspector.renderedTemplate, "Should render template"
				_controllerInspector.renderedTemplate.should.equal 'guests-index', "Should render guests template"

			it "should include guests in rendered args", ->
				_controller.index _controllerInspector.req, _controllerInspector.res
				should.exist _controllerInspector.renderedArgs, "Should have renderedArgs"
				should.exist _controllerInspector.renderedArgs.guests, "Should have renderedArgs.guests"
				_controllerInspector.renderedArgs.guests.should.be.an.instanceOf(Array)

		describe "GuestsController.create", ->

			it "should create a new entry in the store", (done)->
				_controllerInspector.req.body.name = "Joe Guest"
				_controllerInspector.req.body.description = "Party of 5"
				_controllerInspector.req.body.mobileNumber = "4045551212"

				_controller.create _controllerInspector.req, _controllerInspector.res
				app.store.findAllGuests (err, guests) ->
					foundNewGuest = false
					for guest in guests
						if guest.name = "Joe Guest"
							foundNewGuest = true
					foundNewGuest.should.equal true, "Should find Joe Guest in the store after we post him as a new guest."
					_controllerInspector.redirectedUrl.should.equal "/guests"
					done()

		describe "GuestsController.edit", ->

			it "should render a template to edit the guest", (done) ->
				_controllerInspector.req.params.id = 1
				
				_controller.edit _controllerInspector.req, _controllerInspector.res				
				_controllerInspector.renderedTemplate.should.equal 'guests-edit', "Should render guest edit template"
				_controllerInspector.renderedArgs.guest.id.should.equal 1
				done()

		describe "GuestsController.update", ->

			beforeEach (done) ->
				_controllerInspector.req.params.id = 1
				_controllerInspector.req.body.name = "Edited Guest"
				_controllerInspector.req.body.description = "Party of 5"
				_controllerInspector.req.body.mobileNumber = "4045551212"

				_controller.update _controllerInspector.req, _controllerInspector.res
				done()

			it "should update the store with the new guest information", (done) ->	
				app.store.findGuestById 1, (err, guest) ->
					guest.name.should.equal "Edited Guest"
					done()

			it "should redirect to /guests", (done) ->
				_controllerInspector.redirectedUrl.should.equal "/guests"
				done()







