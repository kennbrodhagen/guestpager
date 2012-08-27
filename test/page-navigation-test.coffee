libxmljs			= require "libxmljs"
request				= require "request"
should				= require "should"

# Helper for the root uri to be used in various functions
uriRoot = (app) ->
	#console.log "*** before app = #{app}"
	"http://localhost:#{app.server.settings.port}"
	#console.log "*** after app = #{app}"

# Test the main page navigation
describe 'Page Navigation', ->
	_bodyDoc = null
	app = null

	# Start and stop the web server on the boundaries of this test suite.
	before (done) ->
		factory = require "../factory"
		App = require "../app"
		log = factory.createTestLog()
		app = new App log, factory.createTestStore(log, factory.createTestGuests())
		app.server.listen app.server.settings.port, () ->
			app.log.info "STARTING Page Navigation test server listening on port #{app.server.settings.port} in #{app.server.settings.env} mode"
			done()

	after (done) ->
		app.log.info "FINISHED Page Navigation test. Shutting down server."
		app.server.close()
		app = null
		done()


	# Helper method to make a request, confirm it was successful, and parse the body
	_requestConfirmAndParse = (uri, callback) ->
			#app.log.info "*** REQUESTING URI: #{uri}"
			request.get {uri:uri}, (err, response, body) ->
				_confirmRequestStatusAndParseHtml err, response, body, callback


	# Helper method to confirm a response was successful
	# Parses and save the body as an html dom object.
	# It's nice to provide the additional description argument since these functions are guested from many places.
	_confirmRequestStatusAndParse = (expectedStatus, err, response, body, parse, callback) ->
		#app.log.info {response: body}, "Response #{response}"
		should.not.exist err, "Request returned an error: #{JSON.stringify(err)}."
		should.exist  response, "Response is null."
		response.should.have.status expectedStatus, "Response did not return expected status."
		should.exist body, "Body is null."
		bodyDoc = parse body
		should.exist bodyDoc, "Body parsed into null document."
		# app.log.info "*** REQUEST SUCCESSFUL.  \n*** RESPONSE:\n"
		# app.log.info "*** REQUEST SUCCESSFUL.  \n*** BODY:\n #{JSON.stringify(body)}\n"
		# app.log.info "*** REQUEST SUCCESSFUL.  \n*** BODYDOC:\n #{JSON.stringify(bodyDoc)}\n"
		callback(bodyDoc)

	_fetchPage = (page, callback) ->
		request.get {uri:"#{uriRoot(app) + page}"}, (err, response, body) ->
			_confirmRequestStatusAndParseHtml 200, err, response, body, (bodyDoc) ->	
				_bodyDoc = bodyDoc	
				callback(bodyDoc)	

	_confirmRequestStatusAndParseHtml = (expectedStatus, err, response, body, callback) ->
		_confirmRequestStatusAndParse expectedStatus, err, response, body, libxmljs.parseHtmlString, callback

	_confirmRequestStatusAndParseXml = (expectedStatus, err, response, body, callback) ->
		_confirmRequestStatusAndParse expectedStatus, err, response, body, libxmljs.parseXmlString, callback

	# Tests for the various page navigation
	describe 'View the root page /', ->

		it "should redirect to the home page for more Google juice", (done) ->
			request.get {uri:"#{uriRoot(app)}/", followRedirect:false}, (err, response, body) ->
				_confirmRequestStatusAndParseHtml 302, err, response, body, () ->
					done()

	describe 'View the home page /home', ->

		before (done) ->
			_fetchPage "/home", ->
				done()

		it "should have should have the site name in the title", (done) ->
			_bodyDoc.get("//head/title").should.match /Phone System/
			done()

		it "should have a link to the guests list", (done) ->
			_bodyDoc.get("//a[@id='guests-index' and @href='/guests']").should.match /Guests/
			done()

	describe "View the guests page /guests", ->

		before (done) ->
			_fetchPage "/guests", ->
				done()

		it "should have guests in the title", ->
			_bodyDoc.get("//head/title").should.match /Guests/i

		it "should have a grid of guests", ->
			listItems = _bodyDoc.find("//section[@id='guestsGrid']")
			should.exist listItems
			listItems.length.should.be.greaterThan 0, "failed to find nodes matching xpath"

		it "should have a guest with the mobile number 6785551001", ->
			_bodyDoc.get("//table/tbody/tr[1]/td[4]").should.match /6785551001/, "test number not shown"

		it "should have a button to add a new guest", ->
			_bodyDoc.get("//a[@href='/guests/new']").should.match /Add Guest/

		it "should have a button to page a guest", ->
			_bodyDoc.get("//a[@href='/guests/1/page']").should.match /Page/

		it "should have a button to edit a guest", ->
			_bodyDoc.get("//a[@href='/guests/1/edit']").should.match /Edit/

		it "should have a button to delete a guest", ->
			_bodyDoc.get("//a[@href='/guests/1/delete']").should.match /Remove/

	describe "Add a new guest", ->

		it "should have a screen to add a new guest /guests/new", (done) ->
			_fetchPage "/guests/new", ->
				_bodyDoc.get("//head/title").should.match /Add Guest/i
				done()

		it "should show the new guest on /guests", (done) ->
			body =
				name: "Joe Guest"
				description: "Party of 5"
				mobileNumber: "4045551212"

			request.post {uri:"#{uriRoot(app)}/guests", form: body, followAllRedirects:true}, (err, response, body) ->				
				_confirmRequestStatusAndParseHtml 200, err, response, body, (bodyDoc) ->
					bodyDoc.get("//table/tbody/tr[3]/td[2]").should.match /Joe Guest/, "new guest not added"
					done()

	describe "Edit a guest", ->

		it "should have a screen to edit the guest at /guests/:id/edit", (done) ->
			_fetchPage "/guests/1/edit", ->
				_bodyDoc.get("//head/title").should.match /Edit Guest/i
				done()

		# it "should display the posted edit on /guests", (done) ->
		# 	body =
		# 		id: 2
		# 		name: "Edited Guest"
		# 		description: "Edited Description"
		# 		mobileNumber: "9995551212"

		# 	request.post {uri:"#{uriRoot(app)}/guests", form: body, followAllRedirects:true}, (err, response, body) ->
		# 		_confirmRequestStatusAndParseHtml 200, err, response, body, (bodyDoc) ->
		# 			app.log.info {body: body}, "Response from /guests after edit"
		# 			_containsTextUnderElement("Edited Guest", bodyDoc, "//table/tbody/tr[1]/td[2]").should.equal true, "edited guest should appear as name after edit."


	describe "Delete a guest", ->
		it "should remove the guest from the /guests page"

	describe "Page a guest", ->
		it "should trigger an SMS to page the guest"






