# Main controlling class
# =================================================
# This is the real main class which can be called using it's API. Other modules
# like the cli may be used as bridges to this.


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter'
# include alinex modules
Report = require 'alinex-report'
{string} = require 'alinex-util'
# include classes and helpers


# Helper
# -------------------------------------------------
exports.init = (cb) ->
  cb()


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
    lib.handler args
    process.exit 0
