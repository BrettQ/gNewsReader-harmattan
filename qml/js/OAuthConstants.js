/*
    Copyright 2011 - Yogeshwar Padhyegurjar

    This file is part of gNewsReader.

    gNewsReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gNewsReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with gNewsReader. If not, see <http://www.gnu.org/licenses/>.
*/

.pragma library

var unreadCounts = new Object();
var Tags = new Object();

var USER_PREFIX="user/-"

function updateUserPrefix(usrPrefix) {
    USER_PREFIX = usrPrefix
    REGX_SHARE = new RegExp(usrPrefix+"/state/com.google/broadcast\"")
}

var GOOGLE_CLIENT_ID=""
var GOOGLE_REDIRECT_URL=""
var GOOGLE_API_SCOPE="https://www.google.com/reader/api/"
var GOOGLE_API_CLIENT_SECRET=""
var GOOGLE_API_TOKEN_URL="https://accounts.google.com/o/oauth2/token"
var GOOGLE_FEED_SEARCH_APIKEY=""

var REGX_READ = new RegExp("/state/com.google/read\"")
var REGX_STAR = new RegExp("/state/com.google/starred\"")
var REGX_SHARE = new RegExp("/state/com.google/broadcast\"")
var REGX_LIKE = new RegExp("/state/com.google/like\"")
var REGX_KEPT_UNREAD = new RegExp("/state/com.google/kept-unread\"")
var REGX_FULL_HTML = new RegExp('<video[^><]*>|<.video[^><]*>|<iframe[^><]*>|<.iframe[^><]*>|<a[^><]*>|<.a[^><]*>','g')
var REGX_HTML_IFRAME_ONLY = new RegExp('<video[^><]*>|<.video[^><]*>|<iframe[^><]*>|<.iframe[^><]*>','g')
var REGX_HTML_ALL_TAGS = new RegExp('(<[^>]+>)','g')

var READ_ACT = "user/-/state/com.google/read"
var STAR_ACT = "user/-/state/com.google/starred"
var SHARE_ACT = "user/-/state/com.google/broadcast"
var LIKE_ACT = "user/-/state/com.google/like"
var KEEP_UNREAD_ACT = "user/-/state/com.google/kept-unread"

function getRenameTagParams(tagId, newtitle, accToken) {
    //console.log(tagId.substring(0, tagId.lastIndexOf("/") + 1))
    return {"param":[{"name":"T", "val":accToken},
                     {"name":"s", "val":encodeURIComponent(tagId)},
                     {"name":"t", "val":encodeURIComponent(tagId.substring(tagId.lastIndexOf("/")+1))},
                     {"name":"dest", "val":encodeURIComponent(tagId.substring(0, tagId.lastIndexOf("/")+1)+newtitle)},
                     {"name":"client", "val":"gNewsReader"}]};
}

function getDisableTagParams(tagId, title, accToken) {
    return {"param":[{"name":"T", "val":accToken},
                     {"name":"s", "val":encodeURIComponent(tagId)},
                     {"name":"t", "val":encodeURIComponent(title)},
                     {"name":"client", "val":"gNewsReader"}]};
}

function getEditTagParams(act, type, tagId, feedUrl, accToken) {
    return {"param":[{"name":"T", "val":accToken},
                     {"name":act, "val":type},
                     {"name":"i", "val":encodeURIComponent(tagId)},
                     {"name":"s", "val":encodeURIComponent(feedUrl)},
                     {"name":"client", "val":"gNewsReader"}]};
}

function getTagEditParamsM(actTypeArray, tagId, feedUrl, accToken, inTagsString) {
    actTypeArray.unshift({"name":"T", "val":accToken})
    actTypeArray.push({"name":"i", "val":encodeURIComponent(tagId)})
    actTypeArray.push({"name":"s", "val":encodeURIComponent(feedUrl)})
    actTypeArray.push({"name":"client", "val":"gNewsReader"})
    return {"param":actTypeArray, "method":"EditTags", "intags": inTagsString};
}

//For sub/unsub and change title
function getEditSubParams(i, act, feedId, title, accToken) {
    if(act == "move" || act == "remove") {
        return {"param":[{"name":"T", "val":accToken},
                         {"name":"s", "val":encodeURIComponent(feedId)},
                         {"name":"t", "val":title},
                         {"name":(act == "move"?"a":"r"), "val":"user/-/label/"+encodeURIComponent(i)},
                         {"name":"ac", "val": "edit"}],"index":i};
    } else {
        return {"param":[{"name":"T", "val":accToken},
                         {"name":"s", "val":encodeURIComponent(feedId)},
                         {"name":"t", "val":title},
                         {"name":"ac", "val":act}],"index":i};
    }
}

function getMarkAsReadParams(i, feedId, title, accToken) {
    return {"param":[{"name":"T", "val":accToken},
                     {"name":"s", "val":encodeURIComponent(feedId)},
                     {"name":"t", "val":encodeURIComponent(title)}],"index":i, "method":"markAllAsRead"};
}

//function getRenameTagParams(i, feedId, title, accToken) {
//    return {"param":[{"name":"T", "val":accToken},
//                     {"name":"s", "val":encodeURIComponent(feedId)},
//                     {"name":"t", "val":encodeURIComponent(title)}],"index":i};
//}

function escapeURLparam(urlParam) {
    var reg = /\s+/g;
    return urlParam.replace(reg,'+')
}

function getTwitterShareUrl(articleUrl, pageTitle) { 
    return encodeURI("http://twitter.com/share?url="+articleUrl+"&text="+escapeURLparam(pageTitle))
}

function getFacebookShareUrl(articleUrl, pageTitle) {
    return encodeURI("http://touch.facebook.com/sharer.php?u="+articleUrl+"&t="+escapeURLparam(pageTitle))
}

function getGooglePlusShareUrl(articleUrl, pageTitle) {
    return encodeURI("https://m.google.com/app/plus/x/?hideloc=1&v=compose&content="+pageTitle+" "+articleUrl)
}

function getGooglePlusOneUrl(articleUrl) {
    return encodeURI("https://plusone.google.com/_/+1/confirm?hl=en&url="+articleUrl)
}

var SERVICE_READ_IT_LATER="READ_IT_LATER"
var SERVICE_INSTAPAPER="INSTAPAPER"

var READ_IT_LATER_ADD_URL="https://readitlaterlist.com/v2/add"

function getReadItLaterParams(username, password, title, url) {
    return {"param":[{"name":"username", "val":username},
                     {"name":"password", "val":encodeURIComponent(password)},
                     {"name":"title", "val":encodeURIComponent(title)},
                     {"name":"url", "val":encodeURIComponent(url)},
                     {"name":"apikey", "val":"dhugav24pe88aa3e32TqoWKRPFA3X550"}],"method":"ReadItLater"};
}

var INSTAPAPER_ADD_URL="https://www.instapaper.com/api/add"

function getInstapaperParams(username, password, title, url) {
    return {"param":[{"name":"username", "val":username},
                     {"name":"password", "val":encodeURIComponent(password)},
                     {"name":"title", "val":encodeURIComponent(title)},
                     {"name":"url", "val":encodeURIComponent(url)}],"method":"Instapaper"};
}

function sanitizeContent(content, isFull) {
    return content.replace(isFull ? REGX_HTML_IFRAME_ONLY : REGX_FULL_HTML,"")
}

function stripHtmlTags(content) {
    return Encoder.htmlDecode(content.replace(REGX_HTML_ALL_TAGS,""))
}

var GOOGLE_FEED_API_URL="https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&num=20"

function getSearchForFeedUrl(query) {
    var url = GOOGLE_FEED_API_URL
    url += "&q="
    url += encodeURIComponent(query)
    url += "&key="
    url += encodeURIComponent(GOOGLE_FEED_SEARCH_APIKEY)
    return url
}

/**
 * A Javascript object to encode and/or decode html characters
 * @Author R Reid
 * source: http://www.strictly-software.com/htmlencode
 * Licence: GPL
 *
 * Revision:
 *  2011-07-14, Jacques-Yves Bleau:
 *       - fixed conversion error with capitalized accentuated characters
 *       + converted arr1 and arr2 to object property to remove redundancy
 */
var Encoder = {
    // When encoding do we convert characters into html or numerical entities
    EncodeType : "entity",  // entity OR numerical

    isEmpty : function(val){
                  if(val){
                      return ((val===null) || val.length==0 || /^\s+$/.test(val));
                  }else{
                      return true;
                  }
              },
    arr1: new Array('&nbsp;','&iexcl;','&cent;','&pound;','&curren;','&yen;','&brvbar;','&sect;','&uml;','&copy;','&ordf;','&laquo;','&not;','&shy;','&reg;','&macr;','&deg;','&plusmn;','&sup2;','&sup3;','&acute;','&micro;','&para;','&middot;','&cedil;','&sup1;','&ordm;','&raquo;','&frac14;','&frac12;','&frac34;','&iquest;','&Agrave;','&Aacute;','&Acirc;','&Atilde;','&Auml;','&Aring;','&Aelig;','&Ccedil;','&Egrave;','&Eacute;','&Ecirc;','&Euml;','&Igrave;','&Iacute;','&Icirc;','&Iuml;','&ETH;','&Ntilde;','&Ograve;','&Oacute;','&Ocirc;','&Otilde;','&Ouml;','&times;','&Oslash;','&Ugrave;','&Uacute;','&Ucirc;','&Uuml;','&Yacute;','&THORN;','&szlig;','&agrave;','&aacute;','&acirc;','&atilde;','&auml;','&aring;','&aelig;','&ccedil;','&egrave;','&eacute;','&ecirc;','&euml;','&igrave;','&iacute;','&icirc;','&iuml;','&eth;','&ntilde;','&ograve;','&oacute;','&ocirc;','&otilde;','&ouml;','&divide;','&Oslash;','&ugrave;','&uacute;','&ucirc;','&uuml;','&yacute;','&thorn;','&yuml;','&quot;','&amp;','&lt;','&gt;','&oelig;','&oelig;','&scaron;','&scaron;','&yuml;','&circ;','&tilde;','&ensp;','&emsp;','&thinsp;','&zwnj;','&zwj;','&lrm;','&rlm;','&ndash;','&mdash;','&lsquo;','&rsquo;','&sbquo;','&ldquo;','&rdquo;','&bdquo;','&dagger;','&dagger;','&permil;','&lsaquo;','&rsaquo;','&euro;','&fnof;','&alpha;','&beta;','&gamma;','&delta;','&epsilon;','&zeta;','&eta;','&theta;','&iota;','&kappa;','&lambda;','&mu;','&nu;','&xi;','&omicron;','&pi;','&rho;','&sigma;','&tau;','&upsilon;','&phi;','&chi;','&psi;','&omega;','&alpha;','&beta;','&gamma;','&delta;','&epsilon;','&zeta;','&eta;','&theta;','&iota;','&kappa;','&lambda;','&mu;','&nu;','&xi;','&omicron;','&pi;','&rho;','&sigmaf;','&sigma;','&tau;','&upsilon;','&phi;','&chi;','&psi;','&omega;','&thetasym;','&upsih;','&piv;','&bull;','&hellip;','&prime;','&prime;','&oline;','&frasl;','&weierp;','&image;','&real;','&trade;','&alefsym;','&larr;','&uarr;','&rarr;','&darr;','&harr;','&crarr;','&larr;','&uarr;','&rarr;','&darr;','&harr;','&forall;','&part;','&exist;','&empty;','&nabla;','&isin;','&notin;','&ni;','&prod;','&sum;','&minus;','&lowast;','&radic;','&prop;','&infin;','&ang;','&and;','&or;','&cap;','&cup;','&int;','&there4;','&sim;','&cong;','&asymp;','&ne;','&equiv;','&le;','&ge;','&sub;','&sup;','&nsub;','&sube;','&supe;','&oplus;','&otimes;','&perp;','&sdot;','&lceil;','&rceil;','&lfloor;','&rfloor;','&lang;','&rang;','&loz;','&spades;','&clubs;','&hearts;','&diams;'),
    arr2: new Array('&#160;','&#161;','&#162;','&#163;','&#164;','&#165;','&#166;','&#167;','&#168;','&#169;','&#170;','&#171;','&#172;','&#173;','&#174;','&#175;','&#176;','&#177;','&#178;','&#179;','&#180;','&#181;','&#182;','&#183;','&#184;','&#185;','&#186;','&#187;','&#188;','&#189;','&#190;','&#191;','&#192;','&#193;','&#194;','&#195;','&#196;','&#197;','&#198;','&#199;','&#200;','&#201;','&#202;','&#203;','&#204;','&#205;','&#206;','&#207;','&#208;','&#209;','&#210;','&#211;','&#212;','&#213;','&#214;','&#215;','&#216;','&#217;','&#218;','&#219;','&#220;','&#221;','&#222;','&#223;','&#224;','&#225;','&#226;','&#227;','&#228;','&#229;','&#230;','&#231;','&#232;','&#233;','&#234;','&#235;','&#236;','&#237;','&#238;','&#239;','&#240;','&#241;','&#242;','&#243;','&#244;','&#245;','&#246;','&#247;','&#248;','&#249;','&#250;','&#251;','&#252;','&#253;','&#254;','&#255;','&#34;','&#38;','&#60;','&#62;','&#338;','&#339;','&#352;','&#353;','&#376;','&#710;','&#732;','&#8194;','&#8195;','&#8201;','&#8204;','&#8205;','&#8206;','&#8207;','&#8211;','&#8212;','&#8216;','&#8217;','&#8218;','&#8220;','&#8221;','&#8222;','&#8224;','&#8225;','&#8240;','&#8249;','&#8250;','&#8364;','&#402;','&#913;','&#914;','&#915;','&#916;','&#917;','&#918;','&#919;','&#920;','&#921;','&#922;','&#923;','&#924;','&#925;','&#926;','&#927;','&#928;','&#929;','&#931;','&#932;','&#933;','&#934;','&#935;','&#936;','&#937;','&#945;','&#946;','&#947;','&#948;','&#949;','&#950;','&#951;','&#952;','&#953;','&#954;','&#955;','&#956;','&#957;','&#958;','&#959;','&#960;','&#961;','&#962;','&#963;','&#964;','&#965;','&#966;','&#967;','&#968;','&#969;','&#977;','&#978;','&#982;','&#8226;','&#8230;','&#8242;','&#8243;','&#8254;','&#8260;','&#8472;','&#8465;','&#8476;','&#8482;','&#8501;','&#8592;','&#8593;','&#8594;','&#8595;','&#8596;','&#8629;','&#8656;','&#8657;','&#8658;','&#8659;','&#8660;','&#8704;','&#8706;','&#8707;','&#8709;','&#8711;','&#8712;','&#8713;','&#8715;','&#8719;','&#8721;','&#8722;','&#8727;','&#8730;','&#8733;','&#8734;','&#8736;','&#8743;','&#8744;','&#8745;','&#8746;','&#8747;','&#8756;','&#8764;','&#8773;','&#8776;','&#8800;','&#8801;','&#8804;','&#8805;','&#8834;','&#8835;','&#8836;','&#8838;','&#8839;','&#8853;','&#8855;','&#8869;','&#8901;','&#8968;','&#8969;','&#8970;','&#8971;','&#9001;','&#9002;','&#9674;','&#9824;','&#9827;','&#9829;','&#9830;'),

    // Convert HTML entities into numerical entities
    HTML2Numerical : function(s){
                         return this.swapArrayVals(s,this.arr1,this.arr2);
                     },

    // HTML Decode numerical and HTML entities back to original values
    htmlDecode : function(s){
                     var c,m,d = s;
                     if(this.isEmpty(d)) return "";

                     // convert HTML entites back to numerical entites first
                     d = this.HTML2Numerical(d);
                     // look for numerical entities &#34;
                     var arr=d.match(/&#[0-9]{1,5};/g);
                     // if no matches found in string then skip
                     if(arr!=null){
                         for(var x=0;x<arr.length;x++){
                             m = arr[x];
                             c = m.substring(2,m.length-1); //get numeric part which is refernce to unicode character
                             // if its a valid number we can decode
                             if(c >= -32768 && c <= 65535){
                                 // decode every single match within string
                                 d = d.replace(m, String.fromCharCode(c));
                             }else{
                                 d = d.replace(m, ""); //invalid so replace with nada
                             }
                         }
                     }
                     return d;
                 },

    // Function to loop through an array swaping each item with the value from another array e.g swap HTML entities with Numericals
    swapArrayVals : function(s,arr1,arr2){
                        if(this.isEmpty(s)) return "";
                        var re;
                        if(arr1 && arr2){
                            //ShowDebug("in swapArrayVals arr1.length = " + arr1.length + " arr2.length = " + arr2.length)
                            // array lengths must match
                            if(arr1.length == arr2.length){
                                for(var x=0,i=arr1.length;x<i;x++){
                                    re = new RegExp(arr1[x], 'g');
                                    s = s.replace(re,arr2[x]); //swap arr1 item with matching item from arr2
                                }
                            }
                        }
                        return s;
                    }
}

/*
* Javascript Humane Dates
* Copyright (c) 2008 Dean Landolt (deanlandolt.com)
* Re-write by Zach Leatherman (zachleat.com)
*
* Adopted from the John Resig's pretty.js
* at http://ejohn.org/blog/javascript-pretty-date
* and henrah's proposed modification
* at http://ejohn.org/blog/javascript-pretty-date/#comment-297458
*
* Licensed under the MIT license.
*/
function humaneDate(date, compareTo){
    var lang = {
            ago: qsTr('ago'),
            from: qsTr('From Now'),
            now: qsTr('just now'),
            minute: qsTr('min'),
            minutes: qsTr('mins'),
            hour: qsTr('hr'),
            hours: qsTr('hrs'),
            day: qsTr('day'),
            days: qsTr('days'),
            week: qsTr('wk'),
            weeks: qsTr('wks'),
            month: qsTr('mth'),
            months: qsTr('mths'),
            year: qsTr('yr'),
            years: qsTr('yrs')
        },
        formats = [
            [60, lang.now],
            [3600, lang.minute, lang.minutes, 60], // 60 minutes, 1 minute
            [86400, lang.hour, lang.hours, 3600], // 24 hours, 1 hour
            [604800, lang.day, lang.days, 86400], // 7 days, 1 day
            [2628000, lang.week, lang.weeks, 604800], // ~1 month, 1 week
            [31536000, lang.month, lang.months, 2628000], // 1 year, ~1 month
            [Infinity, lang.year, lang.years, 31536000] // Infinity, 1 year
        ],
//        isString = true,
//        date = isString ?
//                    new Date(date)/*new Date(('' + date).replace(/-/g,"/").replace(/[TZ]/g," "))*/ :
//                    date,
        date = new Date(date),
        compareTo = compareTo || new Date,
        seconds = (compareTo - date) / 1000,
        token;

    if(seconds < 0) {
        seconds = Math.abs(seconds);
        token = lang.from;
    } else {
        token = lang.ago;
    }

    /*
     * 0 seconds && < 60 seconds        Now
     * 60 seconds                       1 Minute
     * > 60 seconds && < 60 minutes     X Minutes
     * 60 minutes                       1 Hour
     * > 60 minutes && < 24 hours       X Hours
     * 24 hours                         1 Day
     * > 24 hours && < 7 days           X Days
     * 7 days                           1 Week
     * > 7 days && < ~ 1 Month          X Weeks
     * ~ 1 Month                        1 Month
     * > ~ 1 Month && < 1 Year          X Months
     * 1 Year                           1 Year
     * > 1 Year                         X Years
     *
     * Single units are +10%. 1 Year shows first at 1 Year + 10%
     */

    function normalize(val, single)
    {
        var margin = 0.1;
        if(val >= single && val <= single * (1+margin)) {
            return single;
        }
        return val;
    }

    for(var i = 0, format = formats[0]; formats[i]; format = formats[++i]) {
        if(seconds < format[0]) {
            if(i === 0) {
                // Now
                return format[1];
            }

            var val = Math.ceil(normalize(seconds, format[3]) / (format[3]));
            return qsTr('%1 %2 %3', 'e.g. %1 is number value such as 2, %2 is mins, %3 is ago').arg(val).arg(val != 1 ? format[2] : format[1]).arg(token)
//            return val +
//                    ' ' +
//                    (val != 1 ? format[2] : format[1]) +
//                    (i > 0 ? token : '');
        }
    }
}

function isUrl(s) {
        var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
        return regexp.test(s);
}
