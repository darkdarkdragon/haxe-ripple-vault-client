package ripple.vaultclient;

import haxe.Http;
import haxe.Json;
import thx.promise.Promise;
import thx.core.Error;

/**
 * ...
 * @author Ivan Tivonenko
 */
class BlobObj {

    public var deviceId: String;
    public var url: String;
    public var id: String;
    public var key: String;
    public var data: Dynamic;
//    this.identity  = new Identity(this);

    public var revision: Int;
    public var encrypted_secret: String;
    public var identity_id: String;
    public var id_token: String;
    public var missing_fields: Array<String>;

    public var rawData: Dynamic;

    private static var debug = true;

    public function new(url: String, blobId: String, key: String, ?deviceId: String) {
        this.url = url;
        this.id = blobId;
        this.key = key;
        this.deviceId = deviceId;
        this.data = { };
    }

    /**
     * Initialize a new blob object
     *
     */
    public function init(): Promise<BlobObj> {

        if (this.url.indexOf('://') == -1) {
            this.url = 'http://' + url;
        }

        var url  = this.url + '/v1/blob/' + this.id;
        if (this.deviceId != null) {
            url += '?device_id=' + this.deviceId;
        }
        var promise = Promise.create(function(resolve : BlobObj -> Void, reject : Error -> Void) {
            if (debug) trace('get from $url');
            var h = new Http(url);
            var status = 0;
            h.onStatus = function(s) {
                status = s;
                if (debug) trace('got status $s');
            }

            h.onError = function(e) {
                reject(new Error(e));
            }

            h.onData = function(d: String) {
                if (d == null || d.length == 0) {
                    reject(new Error('Could not retrieve blob'));
                    return;
                }
                if (debug) trace('result: $d');
                if (status != 0 && (status < 200 || status >= 400)) {
                    // should not be here
                    return;
                }

                var parsed = null;
                try {
                    parsed = Json.parse(d);
                } catch (e: Dynamic) {
                    reject(new Error('Could not retrieve blob - bad data'));
                    return;
                }
                if (parsed.twofactor != null) {
                    parsed.twofactor.blob_id   = this.id;
                    parsed.twofactor.blob_url  = this.url;
                    parsed.twofactor.device_id = this.deviceId;
                    parsed.twofactor.blob_key  = this.key;
//                  resolve(parsed);
                    resolve(this);
                    return;
                }
                if (parsed.result != 'success') {
                    reject(new Error('Incorrect username or password'));
                    return;
                }
                this.revision         = parsed.revision;
                this.encrypted_secret = parsed.encrypted_secret;
                this.identity_id      = parsed.identity_id;
                this.id_token         = parsed.id_token;
                this.missing_fields   = parsed.missing_fields;

                if (this.decrypt(parsed.blob) == false) {
                    reject(new Error('Error while decrypting blob'));
                    return;
                }

                // Apply patches
                if (parsed.patches != null && parsed.patches.length) {
                    var successful = true;
                    parsed.patches.forEach(function(patch) {
                        successful = successful && this.applyEncryptedPatch(patch);
                    });

                    if (successful) {
                        this.consolidate();
                    }
                }

                // return with newly decrypted blob
                resolve(this);
            }
            h.request(false);
        });
        return promise;
    }

    /**
     * Decrypt blob with crypt key
     *
     * @param {string} data - encrypted blob data
     */
    function decrypt(blobData: String): Bool {
        if (debug) trace('blobData: $blobData');
        try {
            this.data = Json.parse(Crypt.decrypt(this.key, blobData));
            if (debug) trace('data:');
            if (debug) trace(data);

//            this.deviceId = rawData.deviceId;
//            this.url = rawData.url;
//            this.id = rawData.id;
//            this.key = rawData.key;
//            this.data = rawData.data;
//            this.revision = rawData.revision;
//            this.encrypted_secret = rawData.encrypted_secret;
//            this.identity_id = rawData.identity_id;
//            this.id_token = rawData.id_token;
//            this.missing_fields = rawData.missing_fields;

            return true;
        } catch (e: Dynamic) {
            trace('client: blob: decryption failed $e');
            //console.log('client: blob: decryption failed', e.toString());
            //console.log(e.stack);
            return false;
        }
        return false;
    }

    function applyEncryptedPatch(patch: String): Bool {
        trace('warning: applyEncryptedPatch not implemented');
        return false;
    }

    function consolidate() {

    }


}

// Blob operations
@:enum
abstract BlobOp(Int) {
  // Special
  var noop = 0;

  // Simple ops
  var set = 16;
  var unset = 17;
  var extend = 18;

  // Meta ops
  var push = 32;
  var pop = 33;
  var shift = 34;
  var unshift = 35;
  var filter = 36;
}
