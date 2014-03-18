fs = require 'fs'
data = fs.readFileSync process.argv[2], 'utf8'
arr = JSON.parse data
posts = []
comments = []
for obj in arr
 if obj.comment?
  comments.push obj
 else
  posts.push obj

post_props = ['id', 'time', 'points', 'comments_count', 'username', 'title']
comment_props = ['id', 'parentId', 'time', 'username', 'comment']

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

fs.writeFileSync "comments.csv", getHeader comment_props
for p in comments
 fs.appendFileSync "comments.csv", getObjString p, comment_props

