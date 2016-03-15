# Main class
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
yargs = require 'yargs'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
{string} = require 'alinex-util'
fs = require 'alinex-fs'
logo = require('alinex-core').logo 'Script Console'
# include classes and helpers
scripter = require './index'

process.title = 'Scripter'


# Error management
# -------------------------------------------------
exit = (code = 0, err) ->
  # exit without error
  process.exit code unless err
  # exit with error
  console.error chalk.red.bold "FAILED: #{err.message}"
  console.error err.description if err.description
  process.exit code

process.on 'SIGINT', -> exit 130, new Error "Got SIGINT signal"
process.on 'SIGTERM', -> exit 143, new Error "Got SIGTERM signal"
process.on 'SIGHUP', -> exit 129, new Error "Got SIGHUP signal"
process.on 'SIGQUIT', -> exit 131, new Error "Got SIGQUIT signal"
process.on 'SIGABRT', -> exit 134, new Error "Got SIGABRT signal"
process.on 'exit', ->
  console.log "Goodbye\n"


# Main routine
# -------------------------------------------------
console.log logo
console.log "Initializing..."

scripter.setup (err) ->
  exit 1, err if err
  # Start argument parsing
  yargs
  .usage "\nUsage: $0 <job> [options]"
  # examples
  .example '$0 --update', 'to initialize and update the scripts'
  .example '$0 <job>', 'to simply run the job script'
  # general options
  .env 'SCRIPTER'
  .options
    help:
      alias: 'h',
      description: 'display help message'
    nocolors:
      alias: 'C'
      describe: 'turn of color output'
      type: 'boolean'
      global: true
    verbose:
      alias: 'v'
      describe: 'run in verbose mode (multiple makes more verbose)'
      count: true
      global: true
    mail:
      alias: 'm'
      describe: 'try run which wont change the emails'
      global: true
      type: 'string'
    update:
      alias: 'u'
      describe: 'update scripts'
      type: 'boolean'
  .group ['u'], 'Core Options:'
  # add the jobs
  jobs = path.join path.dirname(__dirname), 'var/lib/script/index.js'
  if fs.existsSync jobs
    jobs = require jobs
    jobs.addTo yargs
  # help
  yargs.help 'help'
  .updateStrings
    'Options:': 'General Options:'
    'Commands:': 'Jobs:'
  .epilogue "For more information, look into the man page."
  # validation
  .strict()
  .fail (err) ->
    err = new Error "CLI #{err}"
    err.description = 'Specify --help for available options'
    exit 1, err
  args = yargs.argv
  # implement some global switches
  chalk.enabled = false if args.nocolors

  unless args.update
    exit 1, new Error "Nothing to do specify --help for available options"
  console.log "Updating scripts..."
  # update scripts
  require('./update') (err) ->
    exit 1, err if err
