fs = require 'fs'
DIR = './output'
set = process.argv[2]
set = 'news' if not set?

posts = {}
comments = {}

load = (arr) ->
 for o in arr
  if o.title?
   cur = posts[o.id]
   if cur?
    o.comments_count = cur.comments_count if o.comments_count is -1
   posts[o.id] = o
  else if o.comment?
   comments[o.id] = o


print = ->
 all = []
 all.push v for k, v of comments
 all.push v for k, v of posts
 console.log JSON.stringify all

files = fs.readdirSync DIR
regex = new RegExp "^#{set}_.*json$"
if files?
 files.sort()
 for file in files
  path = "#{DIR}/#{file}"
  if regex.test file
   if (fs.lstatSync path)?.isFile()
    data = null
    try
     data = fs.readFileSync path, 'utf8'
    if data?
     i = data.length-1
     while i>=0
      if data[i] is '}'
       data += ']'
       break
      else if data[i] is ']'
       break
      --i

     obj = JSON.parse data
     load obj
print()
