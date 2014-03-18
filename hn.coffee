child_process = require 'child_process'

nextUrl = process.argv[2] #'/news'
nextUrl = '/news' if not nextUrl?

cnt = 0
errCnt = 0
cCnt = 0
cErrCnt = 0

check = ->
 if nextUrl isnt ''
  loadPosts nextUrl
  nextUrl = ''

setTimeout check, 10
setInterval check, 3000

loadPosts = (url) ->
 child_process.execFile 'coffee', ['./child.coffee', cnt, errCnt, cCnt, cErrCnt, url], {}, (err, stdout, stderr) ->
  console.log stdout
  arr = stderr.split '\n'
  n = arr.length
  last = arr[n-1]
  last = arr[n-2] if last is ''
  nums = last.split ' '
  cnt = parseInt nums[0]
  errCnt = parseInt nums[1]
  cCnt = parseInt nums[2]
  cErrCnt = parseInt nums[3]
  nextUrl = nums[4]

  console.error line for line in arr
