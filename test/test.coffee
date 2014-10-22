findtime = require '../findtime'


# s = '[10/Oct/2000:13:55:36]other message 2010-01-01 09:08:10+08:00 other message'
s = "this is message"
start = (new Date()).getTime()
console.log findtime(s)
end = (new Date()).getTime()

console.log end - start

# person = 
#   name : 'mingqi'
#   title : 'sde'

# if m = person.name
#   console.log "aa #{m}"
