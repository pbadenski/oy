fs           = require 'fs'
request      = require 'request'
cheerio      = require 'cheerio'
google       = require 'google'
argv         = require('minimist')(process.argv.slice(2))
colors       = require('colors')
childProcess = require('child_process')
cfg          = require('home-config').load('.oyrc')

wrap = require('wordwrap')(120)

printUsage = ->
  console.log 'Usage:'
  console.log '  oy <engine> "<query>"'
  console.log '  oy show <position>'
  console.log ''
  console.log 'Engines: google (g), stackoverflow (so)'

if argv._.length < 2
  printUsage()
  return

ask = (query) ->
  cfg.last_query = query
  cfg.save()
  google query, (error, response) ->
    return if error
    console.log "Results for '#{query}':"
    response.links
      .filter (result) -> result.link?
      .forEach (result, idx) ->
        console.log "#{idx + 1}. #{result.title}"
        coloredDescription = result.description.replace(/\n|\r/g, "")
        if coloredDescription
          query.split(" ").forEach (queryWord) ->
            coloredDescription = coloredDescription.replace new RegExp("\\b#{queryWord}\\b", "gi"), (match) -> match.red
          console.log wrap(coloredDescription)
        console.log ""

command = argv._[0]
if command == "show"
  if not cfg.last_query
    console.log 'First run: oy <engine> "<query>"'
    return
  listOfPositions = String(argv._[1])
  positions = listOfPositions.split(/,/).map(parseFloat).map((num) -> num - 1)
  google cfg.last_query, (error, response) ->
    positions.forEach (position) ->
      childProcess.exec("open -a 'Google Chrome' '#{response.links[position].link}'")
else if command == "google" or command == "g"
  query = argv._[1]
  ask(query)
else if command == "stackoverflow" or command == "so"
  query = argv._[1]
  ask("site:stackoverflow.com #{query}")
else
  printUsage()
