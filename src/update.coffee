# Update scripts
# =================================================
# This will search for scripts and copy or compiles them.


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter:update'
chalk = require 'chalk'
path = require 'path'
coffee = require 'coffee-script'
# include alinex modules
fs = require 'alinex-fs'
async = require 'alinex-async'
# include classes and helpers


# Execution
# -------------------------------------------------

module.exports = (cb) ->
  target = path.join path.dirname(__dirname), 'var/lib/script'
  search = [
    path.join path.dirname(__dirname), 'var/src/script'
    path.join path.dirname(__dirname), 'var/local/script'
    '/etc/scripter/script/'
    (process.env.HOME ? process.env.USERPROFILE) + '.scripter/script'
  ]
  # delete old files
  debug "remove old #{target} directory"
  fs.remove target, (err) ->
    return cb err if err
    fs.mkdirs target, (err) ->
      return cb err if err
      # search
      debug "search for scripts..."
      # filter to only existing directories
      async.filter search, fs.exists, (search) ->
        async.map search, (dir, cb) ->
          debug "-> #{dir}"
          fs.find dir,
            type: 'f'
          , cb
        , (err, results) ->
          return cb err if err
          update results, target, cb

update = (files, target, cb) ->
  debug "copy and compile scripts..."
  # consolidate jobs into map
  jobs = {}
  for dir in files
    for file in dir
      name = path.basename file, path.extname file
      jobs[name] =
        name: name
        type: path.extname(file)[1..]
        source: file
  # copy or compile
  async.each Object.keys(jobs), (name, cb) ->
    job = jobs[name]
    job.to = path.join target, "#{name}.js"
    switch job.type
      when 'coffee'
        debug "-> #{job.to} (compile)"
        fs.readFile job.source, 'utf8', (err, data) ->
          return cb err if err
          compiled = coffee.compile data,
            filename: path.basename file
            generatedFile: path.basename job.to
          fs.writeFile job.to, """
          /** This file has been compiled from #{job.source} */

          #{compiled}
          """, cb
      when 'js'
        debug "-> #{job.to} (copy)"
        fs.copy job.source, job.to, cb
      else
        delete jobs[name]
        debug chalk.magenta "Unsupported file type of #{job.source} ignored"
        cb()
  , (err) ->
    return cb err if err
    debug "generate index..."
    # extract description
    job.description = require(job.to).description for name, job of jobs
    # create index
    index = """
      /** This file is used to include the job commands into yargs. */

      (function() {
        var scripter = require('../../../lib/index');
        exports.addTo = function(yargs) {
          return yargs"""
    for name, job of jobs
      index += ".command('#{name}', '#{job.description}', scripter.job('#{name}', '#{job.to}'))"
    index += """;
        };
      }).call(this);
      """
      # write index
    fs.writeFile path.join(target, 'index.js'), index, cb
