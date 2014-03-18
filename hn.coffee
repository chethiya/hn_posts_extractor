jsdom = require("jsdom")
fs = require("fs")
jquery = fs.readFileSync("./jquery.js", "utf-8")

MORE_HREF = '\/x?fnid='
nextUrl = process.argv[2] #'/news'

cnt = 0
errCnt = 0

check = ->
 if nextUrl isnt ''
  loadPage nextUrl
  nextUrl = ''

setInterval check, 5000

loadPage = (url) ->
 url = '/news' if not url?
 time = new Date().getTime()
 jsdom.env
   url: "http://news.ycombinator.com#{url}",
   src: [jquery],
   done: (errors, window) ->
     $ = window.$
     $("td.title a").each ->
       href = $(this).attr 'href'
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

       d.title = $(this).text()

       tr = $(this).parent().parent()
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
        console.log ',' if cnt - errCnt isnt 0
        console.log JSON.stringify d
       else
        console.error d
        errCnt++
       cnt++

