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
{string, object} = require 'alinex-util'
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
    if lib.options
      yargs.option key, def for key, def of lib.options
      yargs.group Object.keys(lib.options), "#{string.ucFirst name} Job Options:"
    # help
    yargs.strict()
    .help 'h'
    .alias 'h', 'help'
    .epilogue "For more information, look into the man page."
  handler: (args) ->
    try
      args.json = JSON.parse args.json if args.json
    # init report
    lib.start = new Date()
    # run job
    debug "run #{name} handler..."
    console.log()
    try
      lib.handler args, (err) ->
        debug "finished #{name} handler"
        console.log()
        lib.end = new Date()
        finish lib, args, err
    catch error
      error.description = error.stack.split(/\n/)[1..].join '\n'
      exit 1, error
    return true

finish = (job, args, err) ->
  console.log 'Done.'
  console.log()
  console.log job.report.toConsole()
  console.log()
  if args.mail?
    debug "sending email..."
    email = object.extendArrayReplace {}, {base: 'default'}, job.email
    if ~args.mail.indexOf '@'
      email.to = args.mail.split /\s*,\s*/
    else if args.mail and config.get "/email/#{args.mail}"
      object.extend email, {base: args.mail}
    email = mail.resolve email
    if ~args.mail.indexOf '@'
      delete email.cc
      delete email.bcc
    if meta = args.json?._mail
      email.cc = meta.cc
      email.bcc = meta.bcc
      email.subject = "Re: #{meta.subject}" if meta.subject
      if meta.messageId
        email.inReplyTo = meta.messageId
        email.references = [meta.messageId]
    mail.send email,
      title: job.title ? string.ucFirst job.name
      description: job.description
      start: job.start
      end: job.end
      report: job.report.toString()
    , (merr) ->
      console.log chalk.grey "Email was send." unless merr
      exit 1, err if err
      exit 128, merr if merr
      exit 0
  else
    exit 1, err if err
    exit 0
