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


Scripts
-------------------------------------------------
To add functionality you have to write your own scripts like:

    comming soon...

This script has to be stored in

- subfolder `var/script`
- `/etc/scripter/script`
- `~/.scripter/script`

as JavaScript or CoffeeScript.

To include them you have to call the scripter once with it's `--update` option:

    > scripter --update


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
