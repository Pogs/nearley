nearley = window?.nearley or require '../lib/nearley.coffee'

Compile = (structure, opts) ->
	id = 0 # for making unique names

	outputRules = []
	body        = [] # @directives list

	buildProcessedRule = (name, rule) ->
		tokenList = []

		for t in rule.tokens
			if t.literal
				str = t.literal

				if str.length is 1
					tokenList.push literal: str
				else
					rules = str.split('').map (x) -> literal: x

					newname = "#{name}$#{++id}"

					buildProcessedRule newname, { tokens: rules, postprocess: -> Array::join.call arguments, '' }
					tokenList.push newname

			else if typeof t is 'string'
				if t isnt 'null'
					tokenList.push t

			else if t instanceof RegExp
				tokenList.push t

			else
				throw new Error 'Should never get here'

		outputRules.push new nearley.Rule name, tokenList, rule.postprocess

	firstName = null

	for production in structure
		if production.body
			# this isn't a rule, it's a @directive
			body.push production.body
		else
			firstName ?= production.name

			buildProcessedRule production.name, r for r in production.rules

	return rules: outputRules, body: body, start: firstName

if module?.exports?
	module.exports = Compile
else
	window.Compile = Compile
