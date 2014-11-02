util = require 'util'

serialize = (o, p) ->
	# property-name overrides:
	# 'postprocess' functions are read in as strings
	return o if p is 'postprocess'

	# generic serializing after this..
	return 'null' unless o?

	if util.isRegExp(o) or typeof o isnt 'object'
		if typeof o is 'string'
			return '"' + o.replace(/[\\"]/g, '\\$&').replace(/\n/gm, '\\n') + '"'

		return o.toString?() or toString o

	if util.isArray o
		return '[' + (serialize v for v in o).join(',') + ']'

	# if we're down here we're an object -- we're going to use k in serialize eventually
	return '{' + ("#{serialize k}:#{serialize v, k}" for own k, v of o).join(',') + '}'


generate = (parser, exportName) ->
	"""
		(
			// Generated automatically by nearley
			function ()
			{
				function id(x) { return x[0]; }

				#{parser.body.join '\t\t\r\n'}

				var grammar =
					{
						ParserRules: #{serialize parser.rules},
						ParserStart: #{serialize parser.start}
					}

				if (typeof module !== "undefined" && typeof module.exports !== "undefined")
					module.exports = grammar;
				else
					window[\"#{exportName}\"] = grammar;
			}
		)();
	"""

if module?.exports?
	module.exports = generate
else
	window.generate = generate
