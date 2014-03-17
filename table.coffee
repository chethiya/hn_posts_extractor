fs = require 'fs'
data = fs.readFileSync process.argv[2], 'utf8'
arr = JSON.parse data
posts = []
comments = []
for obj in arr
 posts.push obj

post_props = ['id', 'time', 'points', 'comments_count', 'username', 'title']

getObjString = (o, p) ->
 str = ''
 for k in p
  str += ',' if str isnt ''
  if typeof o[k] is 'string'
   v = o[k].replace /"/g, "\"\""
  else
   v = o[k]
  str += "\"#{v}\""
 str + '\n'

getHeader = (p) ->
 str = ''
 for k in p
  str += ',' if str isnt ''
  str += "\"#{k}\""
 str + '\n'

fs.writeFileSync "posts.csv", getHeader post_props
for p in posts
 fs.appendFileSync "posts.csv", getObjString p, post_props

