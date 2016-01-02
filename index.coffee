util        = require 'util'
_           = require 'underscore'
_s          = require 'underscore.string'
htmlparser  = require 'htmlparser'

helper = require './helper'
transform = null

# TAGS THAT WE SHOULD SKIP
TYPES_TO_SKIP = [ 'style', 'script' ]

convertHTMLToReactNative = ( html ) ->

	defaultHandlerFunction = ( err, dom ) -> return

	handler = new htmlparser.DefaultHandler defaultHandlerFunction, {
		verbose: true,
		ignoreWhitespace: true
	}

	transform = require( './transform' )( transformHTMLTags )

	new htmlparser.Parser( handler ).parseComplete( html )
	filteredDOM = filterDOM( handler.dom )
	result = transformHTMLTags( filteredDOM )
	_s.trim( result )

filterDOM = ( dom ) ->
	dom[0].children

checkIfNeedsSpace = ( result ) ->
	whiteSpaceRegex = /\S$/
	whiteSpaceRegex.test( result )

handleText = ( el, result ) ->
	el.needsSpace = checkIfNeedsSpace( result )
	transform.text( el )

handleTag = ( el, tag, result, style ) ->
	switch tag
		when 'img'
			transform.image( el )
		when 'a'
			elem.needsSpace = checkIfNeedsSpace( result )
			transform.link( el )
		when 'p'
			transform.paragraph( el )
		when 'li'
			transform.list( el )
		when 'h1', 'h2', 'h3', 'h4'
			transform.heading( el )
		when 'br'
			transform.lineBreak( el )
		when 'hr'
			transform.horizontalLine( el )
		when 'strong', 'b', 'bold'
			transform.bold( el )
		else
			{ children = [] } = el
			transformHTMLTags( children, result )

transformHTMLTags = ( dom, result = '', style = {} ) ->
	# check for each element on the DOM the tag
	_.each dom, ( el ) ->
		{ type, raw, name, children = [] } = el
		if type is 'text' and raw isnt '\r\n'
			result += handleText( el )
		else if type is 'tag'
			tag = name.toLowerCase()
			if tag in [ 'a', 'p', 'li', 'h1', 'h2', 'h3', 'h4', 'br', 'hr', 'img', 'bold', 'strong', 'b'  ]
				result += handleTag( el, tag, result )
			else
				result = handleTag( el, tag, result )
		else
			if !_.include( TYPES_TO_SKIP, type )
				result = transformHTMLTags( children, result )
	# return the result that we have so far
	return result

exports.fromString = (str) ->
	return htmlToText(str || {})
