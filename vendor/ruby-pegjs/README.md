ruby-jison
==========

Ruby, Jison Compiler

[Jison is Your friendly JavaScript parser generator!](http://zaach.github.io/jison/)

```Ruby
require 'jison'
javascript_text = Jison.parse File.read('/path/to/grammar.js.jison')
```

Prerequesites
-------------
1. You must have the [jison, npm module](https://npmjs.org/package/jison "jison")
installed and on your `$PATH`, and it must be executable by your application.

```Shell
npm install jison
```

To accomplish this brutal task, you will probably need to add
[npm](https://github.com/isaacs/npm "npm") to your `$PATH`. To execute it, you
may even need [node.js](http://nodejs.org/ "node.js"), but that's not for me to
judge -- I'll let every man decide for himself.

Note that if you receive an exception, like

```
Errno::ENOENT: No such file or directory - jison
        from /usr/lib/ruby/2.0.0/open3.rb:211:in `spawn'
        from /usr/lib/ruby/2.0.0/open3.rb:211:in `popen_run'
        from /usr/lib/ruby/2.0.0/open3.rb:99:in `popen3'
        from /usr/lib/ruby/2.0.0/open3.rb:279:in `capture3'
        ...
```

then you probably do not have the [jison, npm module](https://npmjs.org/package/jison "jison")
installed or it is not on your `$PATH`.

Operations
----------

### Jison.parse

Accepts a string representing a Jison grammar, and returns another string
representing its JavaScript equivalent.

```Ruby
require 'jison'

begin
  # `grammar` is a string consisting of a Jison grammar
  javascript_text = Jison.parse(grammar)

  # do something with javascript_text
rescue Jison::ExecutionError => error
  $stderr.puts "jison command terminated with exit code #{error.exit_code}"
  $stderr.puts "#{error.message}\n  #{error.backtrace.join("\n  ")}"
rescue Errno::ENOENT => error
  $stderr.puts "#{error.message}\n  #{error.backtrace.join("\n  ")}"
  cmd = error.message[/\b\w+$/, 0]
  $stdout.puts "Please be sure #{cmd} is installed and on your $PATH"
end
```

### Jison.version

Returns an instance of `Jison::Version` containing the major, minor and micro
versions of the jison on your `$PATH`.  `Jison::Version` implements `Comparable`
and may be compared against other `Jison::Version`s, `String`s and `Fixnum`s.

```Ruby
require 'jison'

version = Jison.version
version.class #-> Jison::Version
version.to_s #-> "0.4.13"

version.major #-> 0
version.minor #-> 4
version.micro #-> 13

version == version #-> true

version < Jison::Version.new(1,0,0) #-> true
version > Jison::Version.from_string '0.1.0' #-> true
version > Jison::Version.new(1) #-> false

version.between?(0,1) #-> true
version.between?(1,2) #-> false
version.between?('0.1', '0.5') #-> true
```
