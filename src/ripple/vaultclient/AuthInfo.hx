package ripple.vaultclient;

import haxe.Http;
import haxe.Json;
//import promhx.Deferred;
//import promhx.Promise;
import thx.promise.Promise;
import thx.core.Error;

/**
 * ...
 * @author Ivan Tivonenko
 */
class AuthInfo {

    private static inline var debug = false;
    #if ripple_test_data
    static var templ = '{"version":3,"blobvault":"https://id.ripple.com","pakdf":{"exponent":"010001","modulus":"c7f1bc1dfb1be82d244aef01228c1409c198894eca9e21430f1669b4aa3864c9f37f3d51b2b4ba1ab9e80f59d267fda1521e88b05117993175e004543c6e3611242f24432ce8efa3b81f0ff660b4f91c5d52f2511a6f38181a7bf9abeef72db056508bbb4eeb5f65f161dd2d5b439655d2ae7081fcc62fdcb281520911d96700c85cdaf12e7d1f15b55ade867240722425198d4ce39019550c4c8a921fc231d3e94297688c2d77cd68ee8fdeda38b7f9a274701fef23b4eaa6c1a9c15b2d77f37634930386fc20ec291be95aed9956801e1c76601b09c413ad915ff03bfdc0b6b233686ae59e8caf11750b509ab4e57ee09202239baee3d6e392d1640185e1cd","alpha":"7283d19e784f48a96062271a4fa6e2c3addf14e6edf78a4bb61364856d580f13552008d7b9e3b60ebd9555e9f6c7778ec69f976757d206134e54d61ba9d588a7e37a77cf48060522478352d76db000366ef669a1b1ca93c5e3e05bc344afa1e8ccb15d3343da94180dccf590c2c32408c3f3f176c8885e95d988f1565ee9b80c12f72503ab49917792f907bbb9037487b0afed967fefc9ab090164597fcd391c43fab33029b38e66ff4af96cbf6d90a01b891f856ddd3d94e9c9b307fe01e1353a8c30edd5a94a0ebba5fe7161569000ad3b0d3568872d52b6fbdfce987a687e4b346ea702e8986b03b6b1b85536c813e46052a31ed64ec490d3ba38029544aa","url":"https://auth1.ripple.com/api/sign","host":"auth1.ripple.com"},"exists":true,"username":"ivegotnobalances","address":"rKFpPzn4aMUNwZH4Q8SfgfEQJ1q1t7VHhF","emailVerified":true,"reserved":false,"profile_verified":false,"identity_verified":false}';
    #end
    /*
      **
     * Get auth info for a given username or ripple address
     *
     * @param domain - Domain which hosts the user's info
     * @param address - Username or ripple address who's info we are retreiving
     */
    public static function get(domain: String, address: String): Promise<AuthInfoType> {
        #if ripple_test_data
        return Promise.create(function(resolve : AuthInfoType -> Void, reject : Error -> Void) {
            resolve(Json.parse(templ));
        });
        #end
//        var d = new Deferred<AuthInfoType>();
//        var p = new Promise<AuthInfoType>(d);
        return RippleTxt.get(domain)
        .mapSuccessPromise(function(txt) {
//            if (debug) trace('got:');
//            if (debug) trace(txt);
            return Promise.create(function(resolve : AuthInfoType -> Void, reject : Error -> Void) {
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
                                if (debug) trace('------ AuthInfo:get got data:');
                                if (debug) trace(data);
                                var parsed = null;
                                try {
                                    parsed = Json.parse(data);
                                    if (debug) trace(parsed);
//                                    d.resolve(parsed);
                                } catch (e: Dynamic) {
                                    if (debug) trace('------ AuthInfo:get got error:');
                                    if (debug) trace(e);
//                                    d.throwError(e);
                                    reject(new Error(e));
                                }
                                try {
                                    resolve(parsed);
                                } catch (e: Dynamic) {
                                }
                            }
                            h.onError = function(e) {
                                if (debug) trace(e);
                                var stre: String = cast e;
                                if (stre != null && (stre.toLowerCase().indexOf('time') != -1 || stre.toLowerCase().indexOf('reset') != -1)) {
                                    times += 1;
                                    if (times < 4) {
                                        request();
                                    } else {
//                                        d.throwError(e);
                                        reject(new Error(e));
                                    }
                                } else {
//                                    d.throwError(e);
                                    reject(new Error(e));
                                }
                            }
                            h.request(false);
                        }
                        request();
                    } else {
                        //d.throwError('authinfo_url is empty in ripple.txt');
                        reject(new Error('authinfo_url is empty in ripple.txt'));
                    }
                } else {
//                    d.throwError('no authinfo_url in ripple.txt');
                    reject(new Error('no authinfo_url in ripple.txt'));
                }
            });
        });
//        .catchError(function(e) {
//            d.throwError(e);
//        });
//        return p;
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
