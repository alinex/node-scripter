# Main class
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
yargs = require 'yargs'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'
logo = require('alinex-core').logo 'Script Console'
# include classes and helpers
scripter = require './index'

process.title = 'Scripter'


# Support quiet mode through switch
# -------------------------------------------------
quiet = false
for a in ['--get-yargs-completions', 'bashrc', '-q', '--quiet']
  quiet = true if a in process.argv


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
  console.log "Goodbye\n" unless quiet


# Main routine
# -------------------------------------------------
unless quiet
  console.log logo
  console.log chalk.grey "Initializing..."

scripter.setup (err) ->
  exit 1, err if err
  # Start argument parsing
  yargs
  .usage "\nUsage: $0 <job> [options]"
  .env 'SCRIPTER' # use environment arguments prefixed with SCRIPTER_
  # examples
  .example '$0 --update', 'to initialize and update the scripts'
  .example '$0 <job>', 'to simply run the job script'
  # general options
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
    quiet:
      alias: 'q'
      describe: "don't output header and footer"
      type: 'boolean'
      global: true
    mail:
      alias: 'm'
      describe: 'send report using email (address or template name)'
      global: true
      type: 'string'
    json:
      alias: 'j'
      description: 'json formatted data object'
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
  .epilogue """
    You may use environment variables prefixed with 'SCRIPTER_' to set any of
    the options like 'SCRIPTER_MAIL' to set the email address.

    For more information, look into the man page.
    """
  .completion 'bashrc-script', false
  # validation
  .strict()
  .fail (err) ->
    err = new Error "CLI #{err}"
    err.description = 'Specify --help for available options'
    exit 1, err
  # now parse the arguments
  args = yargs.argv
  # implement some global switches
  chalk.enabled = false if args.nocolors

  unless args._.length
    # generall command
    unless args.update
      exit 1, new Error "Nothing to do specify --help for available options"
    console.log "Updating scripts..."
    # update scripts
    require('./update') (err) ->
      exit 1, err if err
