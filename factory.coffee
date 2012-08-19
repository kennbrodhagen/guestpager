class TestStore
	constructor: (@guests) ->
	
	addOrUpdateGuest: (guest, callback) =>
		guests = @guests
		guests.push guest
		callback null, guest

	findAllGuests: (callback) =>
		callback null, @guests

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

	createProductionStore: (guests) =>
		return @createTestStore(guests)

	createTestStore: (guests) =>
		return new TestStore(guests)


module.exports = new Factory()
