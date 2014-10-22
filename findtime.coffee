us = require 'underscore'

###
  auto find timestamp from log line

  - rails format: 2014-07-24T10:14:13.789917
  - syslog: Sep 29 06:33:21
  - log4j:
      DEFAULT: 2012-11-02 14:34:02,781
      ISO8601: 2012-11-02T14:34:02,781
      ISO8601_BASIC: 20121102T143402,781
      ABSOLUTE: 14:34:02,781
      DATE: 02 Nov 2012 14:34:02,781
      COMPACT: 20121102143402781
      UNIX: 1351866842
      UNIX_MILLIS: 1351866842781
  - nginx: 2014/09/29 12:05:34
  - apache acess: 10/Oct/2000:13:55:36 -0700
  - apache error: Fri Dec 16 01:46:23 2005

###

MONTHS_REGEXP = 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec'
MONTHS =
  Jan: 1
  Feb: 2
  Mar: 3
  Apr: 4
  May: 5
  Jun: 6
  Jul: 7
  Aug: 8
  Sep: 9
  Oct: 10
  Nov: 11
  Dec: 12

syslog = 
  ## apache error also comply with whit pattern
  ## Sep 29 06:33:21
  regexp : new RegExp("(#{MONTHS_REGEXP})\\s+(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")

  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      month: MONTHS[r[i+=1]]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

standard =
  ## 2012-11-02 14:34:02
  regexp : new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

iso8601 = 
  ## 2012-11-02T14:34:02
  regexp : new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})T(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }

absolute =
  ## 14:34:02,781
  regexp : new RegExp('(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }  

nginx = 
  ##  2014/09/29 12:05:34
  regexp : new RegExp('(20\\d{2})/(\\d{1,2})/(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})')
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    }  

apache =
  ## 10/Oct/2000:13:55:36
  regexp : new RegExp("(\\d{1,2})/(#{MONTHS_REGEXP})/(20\\d{1,2}):(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      day: r[i+=1]
      month: MONTHS[r[i+=1]]
      year: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

date = 
  ## 02 Nov 2012 14:34:02
  regexp : new RegExp("(\\d{1,2})\\s+(#{MONTHS_REGEXP})\\s+(20\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})")
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      day: r[i+=1]
      month: MONTHS[r[i+=1]]
      year: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

iso8601_basic = 
  ## 20121102T143402
  regexp : new RegExp("(20\\d{2})(\\d{2})(\\d{2})T(\\d{2})(\\d{2})(\\d{2})")   
  parse : (str) ->
    r = @regexp.exec(str)
    i = 0
    return {
      year: r[i+=1]
      month: r[i+=1]
      day: r[i+=1]
      hour: r[i+=1]
      minute: r[i+=1]
      second: r[i+=1]
    } 

patterns = 
  standard : standard  # 2012-11-02 14:34:02
  iso8601 : iso8601  # 2012-11-02T14:34:02
  date : date     # 02 Nov 2012 14:34:02
  syslog : syslog   # Sep 29 06:33:21
  nginx : nginx   # 2014/09/29 12:05:34
  apache : apache   # 10/Oct/2000:13:55:36
  absolute : absolute # 14:34:02
  iso8601_basic : iso8601_basic # 20121102T143402


module.exports = (str) ->
  us.pairs(patterns).map(([name, pattern]) ->
    if match = pattern.regexp.exec(str)
      {
        index: match.index 
        matched_value: match[0] 
        parsed_value: us.object(
          us.map(us.pairs(pattern.parse(str)), ([k,v]) ->
            [k, parseInt(v)]
          ) )
      }
  ).filter((o) -> o?).sort( (a,b) ->
    a.index - b.index  
  )
