class HomeController
	constructor: (@app) ->

	index: (req, res) =>
		res.render 'home-index', { title: 'Phone System' }

module.exports = HomeController
