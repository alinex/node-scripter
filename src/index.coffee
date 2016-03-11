# Main controlling class
# =================================================
# This is the real main class which can be called using it's API. Other modules
# like the cli may be used as bridges to this.


# Node Modules
# -------------------------------------------------

# include base modules
# include alinex modules
# include classes and helpers

exports.job = (name, file) ->
  lib = require file
  #-> (ya)


#
#    exports.builder = (yargs) ->
#      job = 'test'
#      console.log 'compile'
#      yargs
#      .demand 1
#      .usage "\nUsage: $0 <job> [options]"
#      .option 'xtest',
#        alias: 'x'
#        type: 'string'
#      .group 'x', "#{string.ucFirst job} Job Options:"
#      # help
#      .help 'h'
#      .alias 'h', 'help'
#      .epilogue "For more information, look into the man page."
#      .strict()
#
#    exports.handler = (args) ->
#      console.log 'test'
#      console.log args
#      process.exit 0
#
