class Rule
	# symbols is an array of string, regex, and nonterminal
	constructor: (@name, @symbols, @postprocess) -> @

	toString: (pos = 0) ->
		stringify = (e) -> e.literal and JSON.stringify(e.literal) or e.toString()
		tokens    = @symbols.map(stringify)

		return "#{name} → #{tokens.join ' '}" if pos is 0

		matched   = tokens.slice(0,  pos).join ' '
		unmatched = tokens.slice(pos    ).join ' '

		return "#{@name} → #{matched} ● #{unmatched}"

# a State is a rule at a position from a given starting point in the input stream (reference)
class State
	constructor: (@rule, @expect, @reference = 0) -> @data = []

	toString: -> "{#{ @rule.toString(@expect) }}, from #{ @reference or 0 }"

	nextState: (extra) ->
		state = new State @rule, @expect + 1, @reference

		state.data = @data.slice() # make a cheap copy of currentState's data
		state.data.push extra      # append the passed data

		return state

	consumeNonTerminal: (inp) -> @nextState inp if @rule.symbols[@expect] is inp

	consumeTerminal: (inp) ->
		sym = @rule.symbols[@expect]

		return unless sym

		return @nextState(inp) if sym.literal is inp or sym.test? inp

	process: (location, table, rules, addedRules) ->
		# have we completed a rule?
		if @expect is @rule.symbols.length
			if @rule.postprocess
				@data = @rule.postprocess @data, @reference

			# we need a `while` here - the empty
			# rule will modify table[@reference]
			w = 0
			while w < table[@reference].length
				s = table[@reference][w]

				x = s.consumeNonTerminal @rule.name

				if x
					x.data[x.data.length - 1] = @data
					table[location].push x

				w++

		# rule isnt finished, but maybe we can predict something
		else
			exp = @rule.symbols[@expect]

			# we expect it and it has not been added yet
			for r in rules when r.name is exp and r not in addedRules
				s = null

				# this is the null rule, we push a copy of it advanced one position
				if r.symbols.length is 0
					s = @consumeNonTerminal r.name
					s.data[s.data.length - 1] = r.postprocess?([], @reference) or []
				else
					# make a note that we've added this (^we don't record null^)
					addedRules.push r
					s = new State r, 0, location

				table[location].push s

class Parser
	constructor: (rs, start) ->
		@table      = [ [] ]
		@rules      = rs.map (r) -> new Rule r.name, r.symbols, r.postprocess
		@start      = start or rules[0]
		@current    = 0
		addedRules = [] # we avoid adding duplicate rules with this

		for r in @rules when r.name is @start
			addedRules.push r
			@table[0].push new State r, 0, 0

		@advanceTo 0, addedRules

	advanceTo: (n, addedRules) ->
		# this need sto be a while, @table[n] is added to in .process()
		w = 0
		while w < @table[n].length
			@table[n][w].process n, @table, @rules, addedRules
			w++

	finish: -> t.data for t in @table[@table.length - 1] when t.rule.name is @start and t.reference is 0 and t.expect is t.rule.symbols.length

	feed: (chunk) ->
		for _, i in chunk
			@table.push [] # we add new states to the next parse index

			# if the production matches, add
			# the next expectation in the rule
			for s in @table[@current + i]
				x = s.consumeTerminal chunk[i]

				if x
					@table[@current + i + 1].push x

			@advanceTo @current + i + 1, []

			# we couldn't parse anything :'(  -> bitch at the user
			if @table[@table.length - 1].length is 0
				e = new Error "nearley: no possible parsings! (@#{@current + i}: '#{chunk[i]}'"
				e.offset = @current + i
				throw e

		@current += i
		@results  = @finish() # collect parsings after each chunk

		# allow chaining b/c peer pressure
		return @

if module?.exports?
	module.exports = { Parser, Rule }
else
	window.nearley = { Parser, Rule }
