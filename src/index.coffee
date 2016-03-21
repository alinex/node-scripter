# Main controlling class
# =================================================
# This is the real main class which can be called using it's API. Other modules
# like the cli may be used as bridges to this.


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
Report = require 'alinex-report'
{string} = require 'alinex-util'
async = require 'alinex-async'
Exec = require 'alinex-exec'
config = require 'alinex-config'
database = require 'alinex-database'
mail = require 'alinex-mail'
# include classes and helpers


# Helper
# -------------------------------------------------
exports.setup = (cb) ->
  async.each [Exec, database, mail], (mod, cb) ->
    mod.setup cb
  , (err) ->
    return cb err if err
# no own schema
#    # add schema for module's configuration
#      config.setSchema '/scripter', schema
    # set module search path
    config.register 'scripter', path.dirname __dirname
    cb()


# Error management
# -------------------------------------------------
exit = (code = 0, err) ->
  # exit without error
  process.exit code unless err
  # exit with error
  console.error chalk.red.bold "FAILED: #{err.message}"
  console.error err.description if err.description
  process.exit code

# Get the job
# -------------------------------------------------
exports.job = (name, file) ->
  try
    lib = require file
  catch error
    exit 1, error if error
  # setup module
  lib.name = name
  lib.report = new Report()
  lib.debug = require('debug') "scripter:#{name}"
  # return builder and handler
  builder: (yargs) ->
    yargs
    .usage "\nUsage: $0 #{name} [options]"
    # add options
    yargs.option key, def for key, def of lib.options
    yargs.group Object.keys(lib.options), "#{string.ucFirst name} Job Options:"
    # help
    yargs.strict()
    yargs.help 'h'
    .alias 'h', 'help'
    .epilogue "For more information, look into the man page."
#    .strict()
  handler: (args) ->
    # init report
    lib.start = new Date()
    # run job
    debug "run #{name} handler..."
    try
      lib.handler args, (err) ->
        exit 1, err if err
        debug "finished #{name} handler"
        lib.end = new Date()
        finish lib, args
    catch error
      error.description = error.stack.split(/\n/)[1..].join '\n'
      exit 1, error
    return true

finish = (job, args) ->
  console.log 'Done.'
  console.log()
  console.log job.report.toConsole()
  console.log()
  if args.mail
    debug "sending email..."
    mail.send
      base: args.mail
    ,
      title: string.ucFirst job.name
      description: job.description
      start: job.start
      end: job.end
      report: job.report.toString()
    , (err) ->
      exit 1, err if err
      exit 0
  else
    exit 0
