package ripple.vaultclient;

import haxe.Http;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Ivan Tivonenko
 */
class RippleTxt {

    private static var urlTemplates = [
        'https://{{domain}}/ripple.txt',
        'https://www.{{domain}}/ripple.txt',
        'https://ripple.{{domain}}/ripple.txt',
        'http://{{domain}}/ripple.txt',
        'http://www.{{domain}}/ripple.txt',
        'http://ripple.{{domain}}/ripple.txt'
    ];

    private static var cache: Map<String, Dynamic> = new Map();
    private static inline var debug = false;


    /**
     * Gets the ripple.txt file for the given domain
     * @param {string}    domain - Domain to retrieve file from
     * @param {function}  fn - Callback function
     */
    public static function get(domain): Promise<Dynamic> {
        if (cache.exists(domain)) {
            return Promise.promise(cache.get(domain));
        }

        var dp1 = new Deferred<Dynamic>();
        var p1 = new Promise<Dynamic>(dp1);

        var redirectCount = 0;
        var times = 0;
        var request = null;
        request = function(i: Int, ?forceUrl: String = null) {
            if (i >= urlTemplates.length) {
                dp1.throwError('ripple.txt not found');
                return;
            }
            var url = urlTemplates[i];
            url = StringTools.replace(url, '{{domain}}', domain);
            if (forceUrl != null) {
                url = forceUrl;
            }
            if (debug) trace('trying $url');
            var h = new Http(url);
            var status = 0;
            h.onStatus = function(s) {
                if (debug) trace('got status $s');
                status = s;
                if (s == 301) {
                    var location = h.responseHeaders.get('location');
                    if (debug) trace('--- got redirect to $location');
                    h.onData = function(d) { };
                    redirectCount += 1;
                    if (redirectCount > 5) {
                        dp1.throwError('ripple.txt not found');
                        return;
                    }
                    request(i, location);
                }
//                if ( s < 200 || s >= 400 ) {
//                    // error happens
//                    h.onData = function(d) { };
//                }
            }
            h.onData = function(d) {
                if (debug) trace('on data status $status');
                if (status != 0 && (status < 200 || status >= 400)) {
                    // should not be here
                    return;
                }
                if (d == null || d.length == 0) {
                    if (debug) trace('some error getting $url');
                    //dp1.throwError('Error in request');
                    request(i + 1, null);
                } else {
                    if (debug) trace('got data:');
                    if (debug) trace(d);
                    var parsed = parse(d);
                    cache.set(domain, parsed);
                    dp1.resolve(parsed);
                }
            }
            h.onError = function(e){
                if (debug) trace('some error getting $url:');
                if (debug) trace(e);
                if (true) trace('some error getting $url:');
                if (true) trace(e);
                var stre: String = cast e;
                if (stre != null && (stre.indexOf('TIMEDOUT') != -1 || stre.indexOf('RESET') != -1)) {
                    times += 1;
                    if (times < 4) {
                        request(i, null);
                    } else {
                        times = 0;
                        request(i + 1, null);
                    }
                } else {
                    times = 0;
                    request(i + 1, null);
                }
//                times = 0;
//                request(i + 1, null);
//                throw e;
            }
            h.request(false);
        }
        request(0, null);
        return p1;
    }

    /**
     * Parse a ripple.txt file
     * @param {string}  txt - Unparsed ripple.txt data
     */
    public static function parse(txt): Dynamic {
        var currentSection = '';
        var sections = { };

        if (debug) trace('parse $txt');

        var r1 = ~/\r?\n/g;
        var txts = r1.replace(txt, '\n').split('\n');

        var i = 0;
        var l = txts.length;
        if (debug) trace(txts);

        while (i < l) {
            var line = txts[i];

            if (line.length == 0 || line.charAt(0) == '#') {
                i++;
                continue;
            }

            if (line.charAt(0) == '[' && line.charAt(line.length - 1) == ']') {
                currentSection = line.substring(1, line.length - 1);
                Reflect.setField(sections, currentSection, []);
            } else {
//          line = line.replace(~/^\s+|\s+$/g, '');
                var r2 = ~/^\s+|\s+$/g;
                line = r2.replace(line, '');
                if (Reflect.hasField(sections, currentSection)) {
                    Reflect.field(sections, currentSection).push(line);
                }
            }
            i++;
        }
        return sections;
    }
}
