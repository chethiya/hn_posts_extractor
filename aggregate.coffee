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
 all = [comments, posts]
 console.log JSON.stringify all

files = fs.readdirSync DIR
console.log files
regex = new RegExp "^#{set}_.*json$"
if files?
 files.sort()
 for file in files
  console.log file
  path = "#{DIR}/#{file}"
  if regex.test file
   if (fs.lstatSync path)?.isFile()
    data = null
    try
     data = fs.readFileSync path, 'utf8'
    if data?
     obj = JSON.parse data
     load obj
print()
