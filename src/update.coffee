# Update scripts
# =================================================
# This will search for scripts and copy or compiles them.


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'scripter:update'
chalk = require 'chalk'
path = require 'path'
# include alinex modules
fs = require 'alinex-fs'
async = require 'alinex-async'
# include classes and helpers


# Execution
# -------------------------------------------------

module.exports = (cb) ->
  target = path.join path.dirname(__dirname), 'var/lib/script'
  # delete old files
  debug "remove old #{target} directory"
  fs.remove target, (err) ->
    return cb err if err
    fs.mkdirs target, (err) ->
      return cb err if err
      # search
      debug "search for scripts..."
      return cb()

###
      fs.readFile file, 'utf8', (err, data) ->
        return cb err if err
        jsfile = path.basename(file, '.coffee') + '.js'
        mapfile = path.basename(file, '.coffee') + '.map'
        console.log chalk.grey "Compile #{file}" if options.verbose
        compiled = coffee.compile data,
          filename: path.basename file
          generatedFile: jsfile
          sourceRoot: path.relative path.dirname(file), dir
          sourceFiles: [ file ]
          sourceMap: true
        compiled.js += "\n//# sourceMappingURL=#{path.basename mapfile}"
        # write files
        filepathjs = path.join lib, path.dirname(file)[src.length..], jsfile
        filepathmap = path.join lib, path.dirname(file)[src.length..], mapfile
        async.parallel [
          (cb) ->
            fs.mkdirs path.dirname(filepathjs), (err) ->
              return cb err if err and err.code isnt 'EEXIST'
              fs.writeFile filepathjs, compiled.js, cb
          (cb) ->
            fs.mkdirs path.dirname(filepathmap), (err) ->
              return cb err if err and err.code isnt 'EEXIST'
              fs.writeFile filepathmap, compiled.v3SourceMap, cb
        ], (err) ->
          return cb err if err or not options.uglify
###
