sty  = require 'sty'

String::beginsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

# Return false if empty, true otherwise.
exports.notEmpty = (s) -> not (s.trim() == '')

# log a message to the user, with increasing levels of importance:
# DEBUG, INFO, WARN, ERROR and FATAL (for non-checks)
exports.log = (level, msg) ->
  switch level
    when 'FATAL', 5
      console.error "#{sty.red 'ERROR'}: #{msg}"
      process.exit 1
    when 'ERROR', 4
      console.error "#{sty.red 'ERROR'}: #{msg}"
    when 'WARN', 3
      console.warn "#{sty.yellow 'WARN'}:  #{msg}"
    when 'INFO', 2
      console.log "#{sty.green 'INFO'}: #{msg}"
    else
      process.stdout.write "#{sty.blue 'DEBUG'}:"
      console.dir msg

# Return true if object is an array
# From http://stackoverflow.com/a/16608045/4126114
exports.isArray = (a) -> (!!a) && (a.constructor is Array)

# Merge multiple objects, last key wins
exports.merge = (xs...) ->
  if xs?.length > 0
    exports.tap {}, (m) -> m[k] = v for k, v of x for x in xs

# Invoke function with object, return object
exports.tap = (o, fn) -> fn(o); o
