Package: alinex-scripter
=================================================

[![Build Status](https://travis-ci.org/alinex/node-scripter.svg?branch=master)](https://travis-ci.org/alinex/node-scripter)
[![Coverage Status](https://coveralls.io/repos/alinex/node-scripter/badge.png?branch=master)](https://coveralls.io/r/alinex/node-scripter?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-scripter.png)](https://gemnasium.com/alinex/node-scripter)

The scripter makes the best nodejs easy usable from scripts with the full configuration
support but without the nasty initialization.

So you mainly concentrate on your functional work and get

- remote execution support
- easy database access
- easy web service requests
- reporting
- mail response

It can be started from command line or triggered using cron.

> It is one of the modules of the [Alinex Universe](http://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](http://alinex.github.io/develop).


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-scripter.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-scripter.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-scripter)

Install the package globally using npm on a central server.

``` sh
sudo npm install -g alinex-scripter --production
```

After global installation you may directly call `scripter` from anywhere.

``` sh
scripter --help
```

Always have a look at the latest [changes](Changelog.md).


Usage
-------------------------------------------------

You can simple call the `scripter` command with one of the configured jobs:

    > scripter <job> [<options>]...

    Initializing...
    Run the job...
    ...
    Goodbye

To list all the possible jobs:

    > scripter --help

This will show the possible jobs which are defined as scripts.

### Bash Code completion

If you like, you can add code completion for bash by copying the output of:

``` text
> scripter bashrc
###-begin-cli.coffee-completions-###
#
# yargs command completion script
#
# Installation: scripter completion >> ~/.bashrc
#    or scripter completion >> ~/.bash_profile on OSX.
#
_yargs_completions()
{
    local cur_word args type_list

    cur_word="${COMP_WORDS[COMP_CWORD]}"
    args=$(printf "%s " "${COMP_WORDS[@]}")

    # ask yargs to generate completions.
    type_list=`scripter --get-yargs-completions $args`

    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )

    # if no match was found, fall back to filename completion
    if [ ${#COMPREPLY[@]} -eq 0 ]; then
      COMPREPLY=( $(compgen -f -- "${cur_word}" ) )
    fi

    return 0
}
complete -F _yargs_completions scripter
###-end-cli.coffee-completions-###
```

Put these lines into your `~/.bashrc` file.


Scripts
-------------------------------------------------
To add functionality you have to write your own scripts like:

``` coffee
# Test Script
# ========================================================================

exports.description = 'only for testing'

exports.options =
  xtest:
    alias: 'x'
    type: 'string'

exports.handler = (args, cb) ->
  # shortcuts to predefined objects
  debug = exports.debug
  # do the job
  debug "running now..."
  console.log args
  # done ending function
  cb()
```

The script needs at least a description text and a handler function which will
be called with the arguments and a callback. Optionally you may define some CLI
options specific to these job.

This script has to be stored in

- subfolder `var/script`
- `/etc/scripter/script`
- `~/.scripter/script`

as JavaScript or CoffeeScript.

To include them you have to call the scripter once with it's `--update` option:

    > scripter --update


### Preset instances

The following objects will be preset in the exports object for you to use:

- debug - instance to output debugging messages
- report - specific report object to add to

You may use them like:

``` coffee
exports.handler = (args, cb) ->
  # shortcuts to predefined objects
  debug = exports.debug
  report = exports.report
  # code of the handler using them...
```

### Available packages

Additionally you may use any module which the scripter already installed by only
requiring it like:

- alinex-async - async helper
- alinex-config - configuration settings
- alinex-validator - validation of entries
- alinex-fs - local filesystem manipulation
- alinex-database - database access
- alinex-exec - execution of command line tools, also remote
- alinex-mail - mail sending
- alinex-report - report generation (used to fill the report instance)
- alinex-util - different type utilities
- chalk - color code

More may be added later.


Configuration
-------------------------------------------------

### Exec

You may need the setup under `/exec` like described in
[Exec](http://alinex.github.io/node-exec).
This is used to setup execution with load handling and maybe remote connections.

### Database

Also you need the setup under `/database` like described in
[Database](http://alinex.github.io/node-database).
This is used to make the specific database connections.

### Email

You may need the setup under `/email` like described in
[Mail](http://alinex.github.io/node-mail).
This is used to send emails without detailed call in the script.


License
-------------------------------------------------

Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
