package ripple.vaultclient;

import thx.promise.Promise;

/**
 * ...
 * @author Ivan Tivonenko
 */
class BlobClient {


    /**
     * Retrive a blob with url, id and key
     * @params {object} options
     * @params {string} options.url
     * @params {string} options.blob_id
     * @params {string} options.key
     * @params {string} options.device_id //optional
     */
    static public function get(url: String, blobId: String, key: String, ?deviceId: String): Promise<BlobObj> {
      var blob = new BlobObj(url, blobId, key, deviceId);
      return blob.init();
    }

}
