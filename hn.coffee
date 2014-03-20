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
p = null

console.log "[#{JSON.stringify {}}"
loadPosts = (url) ->
 if 'No' is url.substr 0, 2
  console.log "]"
  process.exit 0
 p = child_process.execFile(
   'coffee'
   ['./child.coffee', cnt, errCnt, cCnt, cErrCnt, url]
   maxBuffer: 100*1024*1024
   (err, stdout, stderr) ->
    console.error "Process error: ", err

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
    console.error "|#{nextUrl}|"
 )

 p.stdout.on 'data', (data) ->
  process.stdout.write data

 p.stderr.on 'data', (data) ->
  process.stderr.write data
