fs      = require 'fs'
request = require 'request'
cheerio = require 'cheerio'
google  = require 'google'
argv    = require('minimist')(process.argv.slice(2))
colors  = require('colors')

wrap = require('wordwrap')(120)
query = argv._[0]
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
