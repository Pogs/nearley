#!/usr/bin/env coffee

fs            = require 'fs'
nomnom        = require 'nomnom'

nearley       = require '../lib/nearley.coffee'
Compile       = require '../lib/compile.coffee'
StreamWrapper = require '../lib/stream.coffee'
generate      = require '../lib/generate.coffee'

opts = nomnom.script('nearleyc')
	.option('file', { position: 0, help: 'An input .ne file (if not provided then read from stdin)' })
	.option('out', { abbr: 'o', help: 'File to output to (defaults to stdout)' })
	.option('export', { abbr: 'e', help: 'Variable to set the parser to', default: 'grammar' })
	.option('version', { abbr: 'v', flag: true, help: 'Print version and exit', callback: -> require('../package.json').version })
	.parse()

input   = opts.file and fs.createReadStream(opts.file) or process.stdin
output  = opts.out  and fs.createWriteStream(opts.out) or process.stdout

grammar = new require '../lib/nearley-language-bootstrapped.js'
parser  = new nearley.Parser grammar.ParserRules, grammar.ParserStart
sp      = new StreamWrapper parser

input.pipe(sp).on 'finish', ->
	c = Compile parser.results[0], opts
	output.write generate c, opts.export
