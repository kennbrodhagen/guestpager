should				= require "should"

describe "Controllers", ->
	app = null
	before (done)->
		factory = require "../factory"
		App = require "../app"
		app = new App(factory.createTestLog(), factory.createTestStore(factory.createTestGuests()))
		done()

	describe "Guests Controller", ->

		class ControllerInspector
			constructor: ->
				@redirectedUrl = null
				@renderedTemplate = ""
				@renderedArgs = null
				@req = 
					body: {}
					params: {}

				@res =
					redirect: (url) =>
						@redirectedUrl = url
					render: (template, args) =>
						app.log.info {template: template, args: args}, "ControllerInspector.res.render:"
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






