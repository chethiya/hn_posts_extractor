jsdom = require("jsdom")
fs = require("fs")
jquery = fs.readFileSync("./jquery.js", "utf-8")

MORE_HREF = '\/x?fnid='
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
setInterval check, 5000

loadPosts = (url) ->
 jsdom.env
   url: "http://news.ycombinator.com#{url}",
   src: [jquery],
   done: (errors, window) ->
     time = new Date().getTime()
     $ = window.$
     list = $("td.title a")
     each = (ind) ->
       return if ind is list.length
       href = $(list[ind]).attr 'href'
       if typeof href is 'string' and MORE_HREF is href.substr(0, MORE_HREF.length)
        nextUrl = href
        console.error "Total count: #{cnt}"
        console.error "Total error: #{errCnt}"
        console.error "next url: #{nextUrl}"
        return

       err = false
       d =
        title: ''
        points: 0
        username: ''
        time: ''
        id: -1
        comments_count: 0

       d.title = $(list[ind]).text()

       tr = $(list[ind]).parent().parent()
       tr = tr.next()
       text = $('td', tr).text()
       a = $($('a', tr)[1])
       if a.text().search('discuss') isnt -1 or a.text().search('comment') isnt -1
        d.id = parseInt a.attr('href').substr 8
       if a.text().search('comment') isnt -1
        arr2 = a.text().split(' ')
        for v, i in arr2
         if v is 'comment' or v is 'comments'
          if i is 0
           d.comments_count = -1
          else
           d.comments_count = parseInt arr2[i-1]
       else if a.text().search('discuss') isnt -1
        d.comments_count = 0

       arr = text.split(' ')
       for v,i in arr
        if v is 'point' or v is 'points' and i > 0
         d.points = parseInt(arr[i-1])
         err = true if isNaN d.points
        else if v is 'by' and i < arr.length-1
         d.username = arr[i+1]
        else if v is 'ago' and i > 1
         d.time = arr[i-2] + ' ' + arr[i-1]
         t = parseInt arr[i-2]
         m = arr[i-1]
         s = -1
         if m is 'hour' or m is 'hours'
          s = 60*60*1000
         else if m is 'minute' or m is 'minutes'
          s = 60*1000
         else if m is 'day' or m is 'days'
          s = 60*60*24*1000
       err = true if isNaN t or s is -1
       if not err
        d.time = new Date(time - t*s)
       err = true if d.id is -1 or isNaN d.id
       err = true if isNaN d.comments_count
       if not err
        done = (res) ->
         d.comments_count = res.cnt if d.comments_count is -1
         cCnt += res.cnt
         cErrCnt += res.errCnt

         console.error "Total Comments count: #{cCnt}"
         console.error "Total Comments error: #{cErrCnt}"

         console.log ',' if cnt - errCnt isnt 0
         console.log JSON.stringify d
         cnt++
         each ind + 1

        comments = ->
         loadComments d.id, "/item?id=#{d.id}", (res) ->
          done res

        if d.comments_count is 0
         done cnt: 0, errCnt: 0
        else
         setTimeout comments, 1000
       else
        console.error d
        errCnt++
        cnt++
        each ind + 1
     each 0


loadComments = (parentId, url, callback) ->
 res =
  cnt: 0
  errCnt: 0
 if not url? or url is ''
  callback res
  return

 jsdom.env
   url: "http://news.ycombinator.com#{url}",
   src: [jquery],
   done: (errors, window) ->
     time = new Date().getTime()
     $ = window.$
     list = $("span.comment")

     if list.length is 0
      callback res
      return
     list.each (index) ->
       d =
        parentId: parentId
        comment: ''
        id: -1
        username: ''
        time: ''
       err = false

       d.comment = $(this).text()
       td = $(this).parent()
       a = $($('a', td)[1])
       if a.text().search('link') isnt -1
        d.id = parseInt a.attr('href').substr 8

       text = a.parent().text()
       arr = text.split(' ')
       d.username = arr[0] if arr.length > 0
       for v,i in arr
        if v is 'ago' and i > 1
         d.time = arr[i-2] + ' ' + arr[i-1]
         t = parseInt arr[i-2]
         m = arr[i-1]
         s = -1
         if m is 'hour' or m is 'hours'
          s = 60*60*1000
         else if m is 'minute' or m is 'minutes'
          s = 60*1000
         else if m is 'day' or m is 'days'
          s = 60*60*24*1000
       err = true if isNaN t or s is -1
       if not err
        d.time = new Date(time - t*s)
       err = true if d.id is -1 or isNaN d.id
       err = true if d.comment is '' or d.username is ''

       if not err
        console.log ','
        console.log JSON.stringify d
       else
        console.error d
        res.errCnt++
       res.cnt++

       if index is list.length-1
        callback res
        return false



