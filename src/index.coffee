# Main controlling class
# =================================================
# This is the real main class which can be called using it's API. Other modules
# like the cli may be used as bridges to this.


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter'
chalk = require 'chalk'
# include alinex modules
Report = require 'alinex-report'
{string} = require 'alinex-util'
async = require 'alinex-async'
Exec = require 'alinex-exec'
database = require 'alinex-database'
# include classes and helpers


# Helper
# -------------------------------------------------
exports.setup = (cb) ->
  async.each [Exec, database], (mod, cb) ->
    mod.setup cb
  , cb

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
  lib = require file
  # setup module
  lib.report = new Report()
  # return builder and handler
  builder: (yargs) ->
    yargs
    .demand 1
    .usage "\nUsage: $0 #{name} [options]"
    # add options
    yargs.option key, def for key, def of lib.options
    yargs.group Object.keys(lib.options), "#{string.ucFirst name} Job Options:"
    # help
    yargs.help 'h'
    .alias 'h', 'help'
    .epilogue "For more information, look into the man page."
#      .strict()
  handler: (args) ->
    debug "run #{name} handler..."
    lib.handler args, require('debug')("scripter:#{name}"), (err) ->
      exit 1, err if err
      exit 0
