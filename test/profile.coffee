nearley = require '../lib/nearley.coffee'
grammar = require './parens.js'

String::repeat ?= (n) -> new Array(Math.max(n, 0) + 1).join @

profile = (n, type) ->
	test = '('.repeat(n) + 'acowcowcowcowcowcowcowcowcow' + ')'.repeat(n)

	starttime   = process.hrtime()
	startmemory = process.memoryUsage().heapUsed

	p = new nearley.Parser(grammar.ParserRules, grammar.ParserStart).feed test

	console.assert(p.results[0])

	switch type
		when 'TIME'
			tdiff = process.hrtime(starttime)[1]
			console.log ' '.repeat(Math.round(tdiff / 1e9 * 80)) + '*' # how much of one second

		when 'MEMO'
			mdiff = process.memoryUsage().heapUsed - startmemory
			console.log ' '.repeat(Math.round(mdiff / 1e8 * 80)) + '+'


console.log """
	Nearley test.
	=============
	Test operate on the grammar p -> "(" p ")" | [a-z]"
	An input of size n is 2n + 1 characters long and of the form (((..a..)))."


	Running time tests.
	-------------------
	Each star corresponds to the time taken to parse an input of that size with a recursive grammar.

	SCALE
	#{' '.repeat 20} 0.25s
	#{' '.repeat 40} 0.50s
	#{' '.repeat 60} 0.75s
	#{' '.repeat 80} 1.00s
	"""

for i in [0...5e4] by 2e3
	console.log "#{i} iterations" if i % 1e4 is 0
	profile i, 'TIME'

console.log """
	Running memory tests.
	---------------------
	Each star corresponds to the memory taken to parse an input of that size with a recursive grammar.
	Occasional outliers may be caused by gc runs. Nearley profiling doesn't explicitly call the gc before each run.

	SCALE
	#{' '.repeat 20}25MB
	#{' '.repeat 40}50MB
	#{' '.repeat 60}75MB
	#{' '.repeat 80}100MB
	"""

for i in [0...5e4] by 2e3
	console.log "#{i} iterations" if i % 1e4 is 0
	profile i, 'MEMO'
