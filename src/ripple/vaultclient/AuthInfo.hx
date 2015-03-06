package ripple.vaultclient;

import haxe.Http;
import haxe.Json;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Ivan Tivonenko
 */
class AuthInfo {

    private static inline var debug = false;
    /*
      **
     * Get auth info for a given username or ripple address
     *
     * @param domain - Domain which hosts the user's info
     * @param address - Username or ripple address who's info we are retreiving
     */
    public static function get(domain: String, address: String): Promise<AuthInfoType> {
        var d = new Deferred<AuthInfoType>();
        var p = new Promise<AuthInfoType>(d);
        RippleTxt.get(domain)
        .then(function(txt) {
//            if (debug) trace('got:');
//            if (debug) trace(txt);
            if (debug) trace(Reflect.hasField(txt, 'authinfo_url'));
//            if (Reflect.hasField(txt, 'authinfo_url') && Std.is(Reflect.hasField(txt, 'authinfo_url'), Array)) {
            if (Reflect.hasField(txt, 'authinfo_url')) {
                var authinfo_urls: Array<String> = cast Reflect.field(txt, 'authinfo_url');
                if (authinfo_urls != null && authinfo_urls.length > 0) {
                    var url = authinfo_urls[0] + '?domain=' + domain + '&username=' + address;
                    if (debug) trace('trying $url');

                    var times = 0;
                    var request = null;

                    request = function() {
                        var h = new Http(url);
                        var status = 0;
                        h.onStatus = function(s) {
                            status = s;
                            if (debug) trace('status $s');
                            if ( s < 200 || s >= 400 ) {
                                // error happens
                                h.onData = function(d) { };
                            }
                        }
                        h.onData = function(data) {
                            if (debug) trace(data);
                            try {
                                var parsed = Json.parse(data);
                                if (debug) trace(parsed);
                                d.resolve(parsed);
                            } catch (e: Dynamic) {
                                d.throwError(e);
                            }
                        }
                        h.onError = function(e) {
                            if (debug) trace(e);
                            var stre: String = cast e;
                            if (stre != null && (stre.indexOf('TIMEDOUT') != -1 || stre.indexOf('RESET') != -1)) {
                                times += 1;
                                if (times < 4) {
                                    request();
                                } else {
                                    d.throwError(e);
                                }
                            } else {
                                d.throwError(e);
                            }
                        }
                        h.request(false);
                    }
                    request();
                } else {
                    d.throwError('authinfo_url is empty in ripple.txt');
                }
            } else {
                d.throwError('no authinfo_url in ripple.txt');
            }
        })
        .catchError(function(e) {
            d.throwError(e);
        });
        return p;
    }

}

typedef AuthInfoType = {
    version: Int,
    blobvault: String,
    pakdf: Pakdf,
    exists: Bool,
    username: String,
    address: String,
    emailVerified: Bool,
    recoverable: Bool,
    profile_verified: Bool,
    identity_verified: Bool
}

typedef Pakdf = {
    exponent: String,
    modulus: String,
    alpha: String,
    url: String,
    host: String
}
