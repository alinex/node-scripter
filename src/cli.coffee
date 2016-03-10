# Main class
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter'
yargs = require 'yargs'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
config = require 'alinex-config'
Exec = require 'alinex-exec'
{string} = require 'alinex-util'
fs = require 'alinex-fs'
# include classes and helpers
logo = require('alinex-core').logo 'Script Console'
schema = require './configSchema'

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

# Jobs
# -------------------------------------------------
ccc =
  builder: (yargs) ->
    job = 'test'
    console.log 'compile'
    yargs
    .demand 1
    .usage "\nUsage: $0 <job> [options]"
    .option 'xtest',
      alias: 'x'
      type: 'string'
    .group 'x', "#{string.ucFirst job} Job Options:"
    # help
    .help 'h'
    .alias 'h', 'help'
    .epilogue "For more information, look into the man page."
    .strict()
  handler: (args) ->
    console.log 'test'
    console.log args
    exit 0

# Main routine
# -------------------------------------------------
console.log logo
console.log "Initializing..."

# Start argument parsing
args = yargs
.usage "\nUsage: $0 <job> [options]"
# examples
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
  update:
    alias: 'u'
    describe: 'update scripts'
    type: 'boolean'
.group ['u'], 'Core Options:'
# commands (jobs)
target = path.join path.dirname(__dirname), 'var/lib/script'
fs.find target,
  include: '*.js'
, (err, list) ->
  exit err if err
  for script in list
    lib = require script
    debug "loaded #{script}"
    args.command path.basename(script, path.extname script), lib.description, lib
  #.command 'compile', 'compile new coffee scripts'#, compile
  #.command 'test', 'testing...', ccc
  # help
  args.help 'help'
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
  .argv
  # implement some global switches
  chalk.enabled = false if args.nocolors

  console.log "Starting main routine..."
  unless args.update
    exit 1, new Error "Nothing to do specify --help for available options"
  # update scripts
  require('./update')()
