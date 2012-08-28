class TestStore
	constructor: (@log, @guests) ->
	
	addOrUpdateGuest: (guest, callback) =>
		guests = @guests
		guests.push guest
		callback null, guest

	findAllGuests: (callback) =>
		callback null, @guests

	findGuestById: (id, callback) =>
		for guest in @guests
			if guest.id == id
				callback null, guest
				return
		callback "Guest #{id} not found", null

	removeGuestById: (id, callback) =>
		guests = @guests
		@findGuestById id, (err, guest) ->
			index = guests.indexOf guest
			guests.splice index, 1
			callback null, guest



class Factory
	createLogWithNameAndStreams: (name,streams) =>
		Logger = require("bunyan")
		log = new Logger(
			name: name
			streams: streams
			serializers:
				req: Logger.stdSerializers.req
				res: Logger.stdSerializers.res
		)
		return log	

	createProductionLog: () =>
		name = "guestpager-prod"
		streams = [{stream: process.stdout, level: "debug"}]
		log = @createLogWithNameAndStreams(name,streams)
		return log	

	createTestGuests: () =>
		testGuests = [
			{id: 1, name:"Kenn", description:"party of 2", mobileNumber:"6785551001"}, 
			{id: 2, name:"Christine", description:"party of 4", mobileNumber:"7705551900"}]


	createTestLog: () =>
		name = "guestpager-test"
		streams = [{path: "#{name}.log", level: "debug"}]
		log = @createLogWithNameAndStreams(name,streams)
		return log	

	createProductionStore: (log, guests) =>
		return @createTestStore(log, guests)

	createTestStore: (log, guests) =>
		return new TestStore(log, guests)


module.exports = new Factory()
