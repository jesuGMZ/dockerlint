args = require('subarg')(process.argv.slice(2), alias:
  d: 'debug'
  f: 'file'
  h: 'help'
  p: 'pedantic')
fs    = require 'fs'
utils = require "#{__dirname}/utils"

# Return the first word from a string
exports.getInstruction = (s) ->
  instruction = s.split(' ')[0]
  if instruction is '#'
    'comment'
  else
    instruction

# Return everything but the first word from a string,
# and remove a trailing '\' if needed
exports.getArguments = (s) ->
  inst = this.getInstruction(s)
  inst = '#' if inst == 'comment'
  [s.replace(inst, '').replace(/\\(\s*)$/, '').trim()]

exports.parser = (dockerfile) ->
  # First try to parse the entire file into `rules` before analyzing it.
  rules = []
  self  = this
  do ->
    lineno = 1
    cont   = false
    rule   = []
    for line in fs.readFileSync(dockerfile).toString().split '\n'
      if utils.notEmpty(line)
        # If the current line ends with \ then set `cont` to true,
        # save the line and instruction and arguments into `rule`.
        if line.endsWith '\\'
          if cont
            # already on a continuation, just append to arguments
            rule[0].arguments = rule[0].arguments.concat self.getArguments(line)
          else
            cont = true
            rule.push line: lineno, instruction: self.getInstruction(line), arguments: self.getArguments(line)
        # if current line does not end with \ and cont is true
        # push the saved rule + arguments of current line into `rules`
        # and set `cont` to false and empty `rule`
        else if cont and not line.endsWith '\\'
          rules.push line: rule[0].line, instruction: rule[0].instruction, arguments: rule[0].arguments.concat self.getArguments(line)
          rule = []
          cont = false
        # Just save the line, nothing fancy going on now.
        else if not (line.endsWith '\\' and cont)
          rules.push line: lineno, instruction: self.getInstruction(line), arguments: self.getArguments(line)

      lineno++
  rules