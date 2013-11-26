window.Raffler =
	Models: {}
	Collections: {}
	Views: {}
	Routers: {}
	init: ->
		new Raffler.Routers.Entries
		Backbone.history.start()
		
class Raffler.Views.EntriesIndex extends Backbone.View
	
	template:  _.template($('#item-template').html())
	events:
		'click #new-name': 'createEntry'
		'click #draw': 'drawWinner'
		'click li': 'kill'
		'click #reset': 'resetWinner'
	initialize: ->
		@collection.on('sync', @render, this)
		@collection.on('add', @render, this)
		@collection.on('destroy', @render, this)
	render: ->
		$(@el).html(@template(entries: @collection.toJSON()))
		@
	drawWinner: ->
		@collection.drawWinner()
	createEntry: ->
		@collection.create name: $('#new_entry').val()
	drawWinner: ->
		winner = @collection.shuffle()[0]
		if winner
			winner.set(winner: true);
			winner.save()
	kill: (ev) ->
		console.log $(ev.target).attr('id') # log the jquery selector for debug
		item=@collection.find (model) ->
			model.get("id") is $(ev.target).attr('id')
		item.destroy()
	resetWinner: ->
		winnerCollection = @collection
		winnerCollection.each (entry) ->
			entry.set({winner: false})
			entry.save()
	
class Raffler.Routers.Entries extends Backbone.Router
	routes:
		'': 'index'
		'entries/:id': 'show'
	initialize: ->
		@collection = new Raffler.Collections.Entries()
		@collection.fetch()             
	index: ->
		view = new Raffler.Views.EntriesIndex(collection: @collection)
		$('#container').html(view.render().el)
		
class Raffler.Models.Entry extends Backbone.Model
	defaults: 
		name:''
		winner: false

class Raffler.Collections.Entries extends Backbone.Collection
	model: Raffler.Models.Entry
	localStorage: new Store("backbone-coffee-raffle-mnguyen3")
  
$(document).ready ->
	Raffler.init()