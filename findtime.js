// Generated by CoffeeScript 1.7.1
(function() {
  var MONTHS, MONTHS_REGEXP, absolute, apache, date, iso8601, iso8601_basic, nginx, patterns, standard, syslog, us;

  us = require('underscore');


  /*
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
   */

  MONTHS_REGEXP = 'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec';

  MONTHS = {
    Jan: 1,
    Feb: 2,
    Mar: 3,
    Apr: 4,
    May: 5,
    Jun: 6,
    Jul: 7,
    Aug: 8,
    Sep: 9,
    Oct: 10,
    Nov: 11,
    Dec: 12
  };

  syslog = {
    regexp: new RegExp("(" + MONTHS_REGEXP + ")\\s+(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})"),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        month: MONTHS[r[i += 1]],
        day: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  standard = {
    regexp: new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})'),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        year: r[i += 1],
        month: r[i += 1],
        day: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  iso8601 = {
    regexp: new RegExp('(20\\d{2})-(\\d{1,2})-(\\d{1,2})T(\\d{1,2}):(\\d{1,2}):(\\d{1,2})'),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        year: r[i += 1],
        month: r[i += 1],
        day: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  absolute = {
    regexp: new RegExp('(\\d{1,2}):(\\d{1,2}):(\\d{1,2})'),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  nginx = {
    regexp: new RegExp('(20\\d{2})/(\\d{1,2})/(\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})'),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        year: r[i += 1],
        month: r[i += 1],
        day: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  apache = {
    regexp: new RegExp("(\\d{1,2})/(" + MONTHS_REGEXP + ")/(20\\d{1,2}):(\\d{1,2}):(\\d{1,2}):(\\d{1,2})"),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        day: r[i += 1],
        month: MONTHS[r[i += 1]],
        year: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  date = {
    regexp: new RegExp("(\\d{1,2})\\s+(" + MONTHS_REGEXP + ")\\s+(20\\d{1,2})\\s+(\\d{1,2}):(\\d{1,2}):(\\d{1,2})"),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        day: r[i += 1],
        month: MONTHS[r[i += 1]],
        year: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  iso8601_basic = {
    regexp: new RegExp("(20\\d{2})(\\d{2})(\\d{2})T(\\d{2})(\\d{2})(\\d{2})"),
    parse: function(str) {
      var i, r;
      r = this.regexp.exec(str);
      i = 0;
      return {
        year: r[i += 1],
        month: r[i += 1],
        day: r[i += 1],
        hour: r[i += 1],
        minute: r[i += 1],
        second: r[i += 1]
      };
    }
  };

  patterns = {
    standard: standard,
    iso8601: iso8601,
    date: date,
    syslog: syslog,
    nginx: nginx,
    apache: apache,
    absolute: absolute,
    iso8601_basic: iso8601_basic
  };

  module.exports = function(str) {
    return us.pairs(patterns).map(function(_arg) {
      var match, name, pattern;
      name = _arg[0], pattern = _arg[1];
      if (match = pattern.regexp.exec(str)) {
        return {
          index: match.index,
          matched_value: match[0],
          parsed_value: us.object(us.map(us.pairs(pattern.parse(str)), function(_arg1) {
            var k, v;
            k = _arg1[0], v = _arg1[1];
            return [k, parseInt(v)];
          }))
        };
      }
    }).filter(function(o) {
      return o != null;
    }).sort(function(a, b) {
      return a.index - b.index;
    });
  };

}).call(this);
