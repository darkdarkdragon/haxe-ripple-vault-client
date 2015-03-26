package ripple.vaultclient;

import haxe.Json;
import thx.promise.Promise;
import thx.core.Error;
import thx.core.Tuple;

/**
 * ...
 * @author Ivan Tivonenko
 */
class VaultClient {

    var domain: String;
    var infos: Map<String, AuthInfo.AuthInfoType>;

    public function new(?domain: String) {
        this.domain = domain != null ? domain : 'ripple.com';
        this.infos = new Map();
    }

    /**
     * getAuthInfo
     * gets auth info for a username. returns authinfo
     * even if user does not exists (with exist set to false)
     * @param {string} username
     * @param {function} callback
     */
    public function getAuthInfo(username): Promise<AuthInfo.AuthInfoType> {
        return AuthInfo.get(this.domain, username).mapSuccess(function(authInfo) {
            if (authInfo.version != 3) {
              throw new Error('This wallet is incompatible with this version of the vault-client.');
            }

            if (!Reflect.hasField(authInfo, 'pakdf') || authInfo.pakdf == null) {
              throw new Error('No settings for PAKDF in auth packet.');
            }

            if (authInfo.blobvault == null) {
              throw new Error('No blobvault specified in the authinfo.');
            }

            return authInfo;
        });
    }


    /**
     * Retreive and decrypt blob using a blob url, id and crypt derived previously.
     *
     * @param url - Blob vault url
     * @param id  - Blob id from previously retreived blob
     * @param key - Blob decryption key
     */
    public function relogin(url: String, id: String, key: String, deviceId: String): Promise<BlobObj> {
        // use the url from previously retrieved authInfo, if necessary
//        if (!url && this.infos[id]) {
//            url = this.infos[id].blobvault;
//        }

        if (url == null || url == '') {
            return Promise.error(new Error('Blob vault URL is required'));
        }

        return BlobClient.get(url, id, key, deviceId);
    }

/**
     * Authenticate and retrieve a decrypted blob using a ripple name and password
     *
     * @param username
     * @param password
     */
    public function login(username: String, password: String, device_id: String): Promise<LoginResult> {
        return this.getAuthInfo(username)
            .mapSuccessPromise(function(authInfo) {
                trace('----------- VaultClient:login on authInfo:');
                trace(authInfo);
                if (authInfo != null && !authInfo.exists) {
//                    reject(new Error('User does not exist.'));
                    throw new Error('User does not exist.');
                }
                return this.deriveLoginKeys(authInfo, password);
            })
            .mapSuccessPromise(function(akeys) {
                return Promise.create(function(resolve : LoginResult -> Void, reject : Error -> Void) {
                    trace('----------- VaultClient:login on akeys:');
                    trace(akeys);
                    var authInfo = akeys._0;
                    var keys = akeys._1;
                    // save for relogin
                    this.infos.set(keys.id, authInfo);

                    BlobClient.get(authInfo.blobvault, keys.id, keys.crypt, device_id).either(function(blobObj) {
                        var r = {
                            blob: blobObj,
                            username: username,
                            emailVerified: authInfo.emailVerified,
                            profileVerified: authInfo.profile_verified,
                            identityVerified: authInfo.identity_verified
                        }
                        resolve(r);
                    }, function(e) {
                        reject(e);
                    });
                });
            });
        /*
      var self = this;

      var steps = [
        getAuthInfo,
        self._deriveLoginKeys,
        getBlob
      ];

      async.waterfall(steps, callback);

      function getAuthInfo(callback) {
        self.getAuthInfo(username, function(err, authInfo){

          if (authInfo && !authInfo.exists) {
            return callback(new Error('User does not exist.'));
          }

          return callback (err, authInfo, password);
        });
      }

      function getBlob(authInfo, password, keys, callback) {
        var options = {
          url       : authInfo.blobvault,
          blob_id   : keys.id,
          key       : keys.crypt,
          device_id : device_id
        };

        blobClient.get(options, function(err, blob) {
          if (err) {
            return callback(err);
          }

          //save for relogin
          self.infos[keys.id] = authInfo;

          //migrate missing fields
          if (blob.missing_fields) {
            if (blob.missing_fields.encrypted_blobdecrypt_key) {
              console.log('migration: saving encrypted blob decrypt key');
              authInfo.blob = blob;
              //get the key to unlock the secret, then update the blob keys
              self._deriveUnlockKey(authInfo, password, keys, updateKeys);
            }
          }

          callback(null, {
            blob      : blob,
            username  : authInfo.username,
            verified  : authInfo.emailVerified, //DEPRECIATE
            emailVerified    : authInfo.emailVerified,
            profileVerified  : authInfo.profile_verified,
            identityVerified : authInfo.identity_verified
          });
        });
      };

      function updateKeys (err, params, keys) {
        if (err || !keys.unlock) {
          return; //unable to unlock
        }

        var secret;
        try {
          secret = crypt.decrypt(keys.unlock, params.blob.encrypted_secret);
        } catch (error) {
          return console.log('error:', 'decrypt:', error);
        }

        options = {
          username  : params.username,
          blob      : params.blob,
          masterkey : secret,
          keys      : keys
        };

        blobClient.updateKeys(options, function(err, resp){
          if (err) {
            console.log('error:', 'updateKeys:', err);
          }
        });
      }
      */
    }


    /**
     *
     */
    private function deriveLoginKeys(authInfo: AuthInfo.AuthInfoType, password: String): Promise<Tuple2<AuthInfo.AuthInfoType, Crypt.DeriveRes>> {
        var r = ~/-/g;
        var normalizedUsername = r.replace(authInfo.username.toLowerCase(), '');
        return Crypt.derive(authInfo.pakdf, Crypt.DerivePurpose.login, normalizedUsername, password)
            .mapSuccess(function(keys) {
                return new Tuple2(authInfo, keys);
            });
        /*

        //derive login keys
        crypt.derive(authInfo.pakdf, Crypt.DerivePurpose.login, normalizedUsername, password).either(function(keys) {
//            if (err) {
//                callback(err);
//            } else {
//                callback(null, authInfo, password, keys);
//            }
        }, function(err) {

        });
        */
        return null;
    }

}

typedef LoginResult = {
    blob: BlobObj,
    username: String,
    emailVerified: Bool,
    profileVerified: Bool,
    identityVerified: Bool
}

