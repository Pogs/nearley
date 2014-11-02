{Writable} = require 'stream'

class StreamWrapper extends Writable
	# `extends` does about the same job as util.inherits()
	# this is the only difference (afaict):
	@super_ = @__super__

	constructor: (@_parser) -> super

	_write: (chunk, encoding, callback) ->
		@_parser.feed chunk.toString()
		callback()

module.exports = StreamWrapper
