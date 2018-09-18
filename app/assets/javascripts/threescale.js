// /*
//  Behaviour for usages static display
// */
//
/*Array.prototype.sum = function(){
 for(var i=0,sum=0;i<this.length;sum+=this[i++]);
 return sum;
};
Array.prototype.max = function(){
 return Math.max.apply({},this);
};
Array.prototype.min = function(){
 return Math.min.apply({},this);
};
*/

if(typeof ThreeScale == 'undefined'){
  var ThreeScale = {};
};

if(typeof ThreeScale.Helper == 'undefined'){
  ThreeScale.Helper = {};
};

// Helper object contains an assortment of methods for general assistance.

ThreeScale.Helper.General = {
	months: ['January', 'February', 'March', 'April', 'May', 'June', 'July',
			'August', 'September', 'October', 'November', 'December'],

  numberPadding: function(number, decimals){
    var n = number, c = isNaN(decimals = Math.abs(decimals)) ? 2 : decimals,
        d = ".",
        t = ",",
        i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
        s = n < 0 ? "-" : "",
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
      (c ? d + Match.abs(n - i).toFixed(c).slice(2) : "");
    },

    // Formats a date to work with the 3scale stats API
    dateDashed: function(date) {
      if(typeof date == 'undefined'){
        date = new Date();
      }
      var y = date.getFullYear(),
          d = date.getDate(),
          m = date.getMonth() + 1;

      return y + "-" + m + "-" + d;
    },

    currentDateDashed: function(){
      var date = new Date();

      var y = date.getFullYear(),
          d = date.getDate(),
          m = date.getMonth() + 1;

      return y + "-" + m + "-" + d;
    },


    // Takes a string representing a URL and returns an object of URL hash key value pairs.
    // If no URL is passed, current browser location is used.
    urlParamsToHash: function(url) {
        if (!url) {
            url = location.href;
        }

        var map = {};
        var parts = url.replace(/[#?&]+([^=&]+)=([^&]*)/gi,
        function(m, key, value) {
            map[key] = value;
        });
        return map;
    },

    dateParser: function(date, period){

      // If period set to year, then set to 1st of month

      // 2010-06-01T00:00:00+02:00
      var exp = /^(\d{4})-(\d\d)-(\d\d)[T](\d\d:\d\d:\d\d)(\+\d\d:\d\d)*(((-|\+)\d\d:\d\d)|Z)$/,
          p = exp.exec(date);
      if(p) {
        var t = p[4].split(":"),
            h = t[0],
            m = t[1],
            s = t[2];

        if(typeof period != null && period == 'year') p[3] = 10;

        var x = new Date(Date.UTC(p[1],(p[2]-1),p[3],h,m,s));
            return x;
        } else {
          alert(date)
          throw "Invalid string representation of date";
      }
    },


    /**
     * Based on http://www.php.net/manual/en/function.strftime.php
     * @param {String} format
     * @param {Number} timestamp
     * @param {Boolean} capitalize
     */
    dateFormat: function(format, timestamp, capitalize) {
    	function pad (number) {
    		return number.toString().replace(/^([0-9])$/, '0$1');
    	}

    	if (!defined(timestamp)) return 'Invalid date';


    	var date = new Date(timestamp * timeFactor),

    		// get the basic time values
    		hours = date[getHours](),
    		day = date[getDay](),
    		dayOfMonth = date[getDate](),
    		month = date[getMonth](),
    		fullYear = date[getFullYear](),
    		lang = defaultOptions.lang,
    		langWeekdays = lang.weekdays,
    		langMonths = lang.months,

    		// list all format keys
    		replacements = {

    			// Day
    			'a': langWeekdays[day].substr(0, 3), // Short weekday, like 'Mon'
    			'A': langWeekdays[day], // Long weekday, like 'Monday'
    			'd': pad(dayOfMonth), // Two digit day of the month, 01 to 31
    			'e': dayOfMonth, // Day of the month, 1 through 31

    			// Week (none implemented)

    			// Month
    			'b': langMonths[month].substr(0, 3), // Short month, like 'Jan'
    			'B': langMonths[month], // Long month, like 'January'
    			'm': pad(month + 1), // Two digit month number, 01 through 12

    			// Year
    			'y': fullYear.toString().substr(2, 2), // Two digits year, like 09 for 2009
    			'Y': fullYear, // Four digits year, like 2009

    			// Time
    			'H': pad(hours), // Two digits hours in 24h format, 00 through 23
    			'I': pad((hours % 12) || 12), // Two digits hours in 12h format, 00 through 11
    			'l': (hours % 12) || 12, // Hours in 12h format, 1 through 12
    			'M': pad(date[getMinutes]()), // Two digits minutes, 00 through 59
    			'p': hours < 12 ? 'AM' : 'PM', // Upper case AM or PM
    			'P': hours < 12 ? 'am' : 'pm', // Lower case AM or PM
    			'S': pad(date.getSeconds()) // Two digits seconds, 00 through  59

    		};


    	// do the replaces
    	for (var key in replacements) format = format.replace('%'+ key, replacements[key]);

    	// Optionally capitalize the string and return
    	return capitalize ? format.substr(0, 1).toUpperCase() + format.substr(1) : format;
    }

};
