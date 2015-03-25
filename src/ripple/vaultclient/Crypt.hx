package ripple.vaultclient;

import com.fundoware.engine.bigint.FunBigInt_;
import com.fundoware.engine.bigint.FunMutableBigInt;
import com.fundoware.engine.core.FunUtils;
import com.fundoware.engine.crypto.aes.FunAES;
import com.fundoware.engine.random.FunRandom;
import haxe.crypto.Base64;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.Json;
import thx.promise.Promise;
import thx.core.Error;

import haxe.ds.Vector;
import haxe.Http;

import com.fundoware.engine.bigint.FunBigInt;
import com.fundoware.engine.bigint.FunBigIntArithmetic;

/**
 * ...
 * @author Ivan Tivonenko
 */
class Crypt {

    private static inline var debug = false;


    /**
     * Decrypt data
     *
     * @param {string} key
     * @param {string} data
     */
    public static function decrypt(key: String, data: String): String {
        if (debug) trace('Crypt::decrypt($key, $data)');
        if (debug) trace(data);
        var encryptedBytes = Base64.decode(data);
        var initialVector = encryptedBytes.sub(1, 16);
        var ciphertext = encryptedBytes.sub(17, encryptedBytes.length - 17);
        var version = encryptedBytes.get(0);
        if (debug) trace('encryption version: $version');
        if (version != 0) {
            throw new Error('Unsupported encryption version: $version');
        }
        if (debug) trace('iv: ' + Base64.encode(initialVector));
        if (debug) trace('ct: ' + Base64.encode(ciphertext));
        //var decryptedB = Bytes.alloc(encryptedBytes.length);
        //decryptedB.fill(0, decryptedB.length, 0);
        var aes = new FunAES(FunUtils.hexToBytes(key));
        var decryptedB = aes.decryptCCM(ciphertext, initialVector, null);
        if (debug) trace('decrypted:');
        if (debug) trace(decryptedB.toString());
        if (decryptedB != null) {
            return decryptedB.toString();
        }

        // var encryptedBits
        return null;
        /*
      key = sjcl.codec.hex.toBits(key);
      var encryptedBits = sjcl.codec.base64.toBits(data);

      var version = sjcl.bitArray.extract(encryptedBits, 0, 8);

      if (version !== 0) {
        throw new Error('Unsupported encryption version: '+version);
      }

      var encrypted = extend(true, {}, cryptConfig, {
        iv: sjcl.codec.base64.fromBits(sjcl.bitArray.bitSlice(encryptedBits, 8, 8+128)),
        ct: sjcl.codec.base64.fromBits(sjcl.bitArray.bitSlice(encryptedBits, 8+128))
      });

      return sjcl.decrypt(key, JSON.stringify(encrypted));
      */
    };

    /**
     * KEY DERIVATION FUNCTION
     *
     * This service takes care of the key derivation, i.e. converting low-entropy
     * secret into higher entropy secret via either computationally expensive
     * processes or peer-assisted key derivation (PAKDF).
     *
     * @param {object}    opts
     * @param {string}    purpose - Key type/purpose
     * @param {string}    username
     * @param {string}    secret - Also known as passphrase/password
     */
    public static function derive(opts: AuthInfo.Pakdf, purpose: DerivePurpose, username: String, secret: String): Promise<DeriveRes> {
        var tokens: Array<String>;

        if (purpose == DerivePurpose.login) {
            tokens = ['id', 'crypt'];
        } else {
            tokens = ['unlock'];
        }

        var iExponent = FunBigInt.fromHexUnsigned(opts.exponent);
        var iModulus  = FunBigInt.fromHexUnsigned(opts.modulus);
        var iAlpha    = FunBigInt.fromHexUnsigned(opts.alpha);

        var _purpose: String = cast purpose;
        var publicInfo = [ 'PAKDF_1_0_0', Std.string(opts.host.length), opts.host, Std.string(username.length), username, Std.string(_purpose.length), _purpose ].join(':') + ':';
        var publicSize = Math.ceil(Math.min((7 + bitLength(iModulus)) >>> 3, 256) / 8);
        var publicHex = fdh(publicInfo, publicSize);

        var iPublic    = FunBigInt.fromHexUnsigned(publicHex);
        if (iPublic.getBit(0) == 0) {
            iPublic += 1;
        }
        var secretInfo = [ publicInfo, Std.string(secret.length), secret ].join(':') + ':';
        var secretSize = (7 + bitLength(iModulus)) >>> 3;
        var secretHex = fdh(secretInfo, secretSize);
        var iSecret    = FunBigInt.fromHexUnsigned(secretHex) % iModulus;

        if (debug) trace('iSecret: ' + iSecret.toHex());
        if (debug) trace('iSecret jacobi: ' + jacobi(iSecret, iModulus));
        if (jacobi(iSecret, iModulus) != 1) {
            iSecret = (iSecret * iAlpha) % iModulus;
        }


        if (debug) {
            trace('iExponent :' + iExponent.toHex() );
            trace('iModulus :' + iModulus.toHex() );
            trace('iModulus bitLength:' + bitLength(iModulus) );
            trace('iAlpha:' + iAlpha.toHex());
            trace('publicInfo: ' + publicInfo);
            trace('publicSize: ' + publicSize);
            trace('publicHex: ' + publicHex);
            trace('secretHex: ' + secretHex);
            trace('iPublic: ' + iPublic.toHex());
            trace('iSecret: ' + iSecret.toHex());
        }


        var iRandom;

        while (true) {
            iRandom = random(iModulus);
            if (jacobi(iRandom, iModulus) == 1) {
              break;
            }
        }

        if (debug) trace('iRandom: ' + iRandom.toHex());
        //iRandom = FunBigInt.fromHexUnsigned('1738a9fb0e740e07f819dfc6eb33ef067375f53431f52e07901378a2e1fcac1ff22e58a2d056a67ba7ae38be7a8d2ae4249a35a802c70295575170cb96c3e11ec1daf9d1c02133bb1f76a0bc1678815c3d2bcb43676b047c68732447496d84369c3d70a7c1c14b4f7053d29b467d605902aef35205e87f17764a36a248b6a709b7cbf03d212cba239b654810f87f05b04937af580b5e968dff5f487ae32e2f606bf8932ba390e44689cbe0bdedfba31a23fbe6dea1802a4d9a9f99cfeb186efe7cd2af23a670a68aadbdf9ad24806f2676d5cd643fe7407aec5e1c52fe286cfc7b1f883b5f3bb539fa4d03ea65864c1817e8ad015aa439a3ff2dd3bfbff22060');
        //if (debug) trace('iRandom: ' + iRandom.toHex());

        var iBlind   = powermod(iRandom, iPublic * iExponent, iModulus);
        if (debug) trace('iBlind: ' + iBlind.toHex());
        var iSignreq = mulmod(iSecret, iBlind, iModulus);
        if (debug) trace('iSignreq: ' + iSignreq.toHex());
        var signreq  = iSignreq.toHex();

        return Promise.create(function(resolve : DeriveRes -> Void, reject : Error -> Void) {
            var h = new Http(opts.url);
            var status = 0;
            h.onStatus = function(s) {
                trace('status: ' + s);
                status = s;
                if ( s < 200 || s >= 400 ) {
                    // error happens
//                    h.onData = function(d) { };
                }
            }
            h.onData = function(data) {
                if (debug) trace('got data: ' + status);
                if (debug) trace(data);
                if (debug) trace('------- data ends');
                if ( status < 200 || status >= 400 ) {
                    return;
                }
                var parsed = null;
                try {
                    parsed = Json.parse(data);
                    if (debug) trace(parsed);
//                                    d.resolve(parsed);
                } catch (e: Dynamic) {
                    if (debug) trace('------ Crypt:get got error:');
                    if (debug) trace(e);
                    reject(new Error(e));
                    return;
                }
                if (parsed == null || parsed.result != 'success') {
                    if (debug) trace('rejectinh 1');
                    reject(new Error(data));
                    return;
                }
                try {
                    var iSignres = FunBigInt.fromHexUnsigned(parsed.signres);
                    var iRandomInv = inverseMod(iRandom, iModulus);
                    var iSigned    = mulmod(iSignres, iRandomInv, iModulus);
                    var result     = { };

                    if (debug) trace('iRandomInv: ' + iRandomInv.toHex());
                    if (debug) trace('iSigned: ' + iSigned.toHex());
                    if (debug) trace(dumpBits(iSigned));

                    Lambda.iter(tokens, function(token: String) {
                        Reflect.setField(result, token, keyHash(iSigned, token));
                    });
                    if (debug) trace('result: ');
                    if (debug) trace(result);

                    resolve(result);
                } catch (e: Dynamic) {
                    if (debug) trace('error: ' + e);
                }
            }
            h.onError = function(e) {
                if (debug) trace('error: ');
                if (debug) trace(e);
                reject(new Error(e));
            }
            var postData = Json.stringify( { info: publicInfo, signreq: signreq } );
            if (debug) trace('url: ' + opts.url);
            if (debug) trace('postdata:');
            if (debug) trace(postData);
            h.setHeader('Content-Type', 'application/json');
            h.setPostData(postData);
            h.request(true);
        });
        return null;
    }

    private static function dumpBits(b: FunBigInt): String {
        var r = [];
        var bl = bitLength(b);
        for (i in 0...bl) {
            //r.push(Std.string(b.getBit(i)));
            r.push(Std.string(b.getBit(bl - i - 1)));
        }
        //r.reverse();
        return r.join('');
    }

    private static function fbi2rstr(fbi: FunBigInt): String {
        var bl = bitLength(fbi);
        var byte = 0;
        var bc = 7;
        var res = [];
        for (i in 0...bl) {
            //r.push(Std.string(b.getBit(i)));
            var bit = fbi.getBit(bl - i - 1);
            byte |= bit << bc;
            if (--bc < 0) {
                res.push(String.fromCharCode(byte));
                byte = 0;
                bc = 7;
            }
        }
        return res.join('');
    }

    // This is a function to derive different hashes from the same key. Each hash
    // is derived as HMAC-SHA512HALF(key, token).
    private static function keyHash(key: FunBigInt, token: String): String {
        var rstr = fbi2rstr(key);
        return Sha512.rstr2hex(Sha512.rstr_hmac_sha512(rstr, token)).substr(0, 64);
    }

/** return inverse mod prime p.  p must be odd. Binary extended Euclidean algorithm mod p. */
    static function inverseMod(t: FunBigInt, p: FunBigInt) {
        var a: FunMutableBigInt = 1;
        var b: FunMutableBigInt = 0;
        var x: FunMutableBigInt = t;
        var y: FunMutableBigInt = p;

        var tmp;
        var i;

        if (p & 1 != 1) {
            throw "inverseMod: p must be odd";
        }

        // invariant: y is odd
        var c = 0;
        do {
            if (x & 1 == 1) {
                if (!(x >= y)) {
                    // x < y; swap everything
                    tmp = x; x = y; y = tmp;
                    tmp = a; a = b; b = tmp;
                }
                x -= y;

                if (!(a >= b)) {
                    a += p;
                }
                a -= b;
            }

            // cut everything in half
            x /= 2;
            if (a & 1 == 1) {
                a += p;
            }
            a /= 2;
        } while(!x.isZero());

        if (y != 1) {
            throw "inverseMod: p and x must be relatively prime";
        }

        return b;
    }

    static function toHexShort(v: FunBigInt, ?noZX = false): String {
        var s = v.toHex();
        if (s.length == 0) return s;
        var numZeros = 0;
        while (numZeros < s.length) {
            if (s.charAt(numZeros) != '0') break;
            numZeros += 1;
        }
        var r = noZX ? '' : '0x';
        if (numZeros == s.length) {
            r += '0';
        } else {
            r += s.substring(numZeros);
        }
        return r;
    }

    static inline function mulmod(t, that: FunBigInt, N: FunBigInt) {
        return ((t % N) * (that % N)) % N;
    }

    /** this ^ x mod N */
    static function powermod(t: FunBigInt, x: FunBigInt, N: FunBigInt): FunBigInt {
        var result: FunBigInt = 1;
        var k: FunMutableBigInt = x;
        var a: FunBigInt = t;
        while (true) {
            if (k & 1 == 1) {
                result = mulmod(result, a, N);
            }
            k /= 2;
            if (k == 0) {
                break;
            }
            a = mulmod(a, a, N);
        }
        return result;
    }

    static function random(modulus: FunBigInt): FunBigInt {
        //l = modulus.limbs.length, m = modulus.limbs[l - 1] + 1, out = new sjcl.bn();
        var l: Int = modulus.toInts(null);
        var words = new Vector<Int>(l);
        modulus.toInts(words);
        var m = words[l - 1] + 1;
        while (true) {
            // get a sequence whose first digits make sense
            do {
                // words = sjcl.random.randomWords(l, paranoia);
                for (i in 0...l) {
                    words[i] = FunRandom.next();
                }
                if (words[l - 1] < 0) {
//                    words[l-1] += 0x100000000;
                    words[l-1] += 1073741824;
                    words[l-1] += 1073741824;
                    words[l-1] += 1073741824;
                    words[l-1] += 1073741824;
                }
            } while (Math.floor(words[l-1] / m) == Math.floor(4294967296 / m));
            words[l-1] %= m;

            // mask off all the limbs
//            for (i=0; i<l-1; i++) {
//              words[i] &= modulus.radixMask;
//            }

            // check the rest of the digitssj
            var out = FunBigInt.fromUnsignedInts(words);
            if (!(out >= modulus)) {
              return out;
            }
        }
    }

    static function jacobi(a: FunBigInt, that: FunBigInt): Int {
        if (that.isNegative()) return 0;

        // 1. If a = 0 then return(0).
        if (a.isZero()) {
            return 0;
        }

        // 2. If a = 1 then return(1).
        if (a == 1) {
            return 1;
        }

        var s = 0;

        // 3. Write a = 2^e * a1, where a1 is odd.
        var e = 0;
        while (!(a.getBit(e) == 1)) e++;
//        var a1 = a.shiftRight(e);
        var a1 = a >> e;

        // 4. If e is even then set s ← 1.
        if ((e & 1) == 0) {
            s = 1;
        } else {
//            var residue = that.modInt(8);
            var residue = that % 8;
            if (residue == 1 || residue == 7) {
                // Otherwise set s ← 1 if n ≡ 1 or 7 (mod 8)
                s = 1;
            } else if (residue == 3 || residue == 5) {
                // Or set s ← −1 if n ≡ 3 or 5 (mod 8).
                s = -1;
            }
        }

        // 5. If n ≡ 3 (mod 4) and a1 ≡ 3 (mod 4) then set s ← −s.
        if (that % 4 == 3 && a1 % 4 == 3) {
            s = -s;
        }

        if (a1 == 1) {
            return s;
        } else {
            return s * jacobi((that % a1), a1);
        }

        return 0;
    }


    static function bitLength(b: FunBigInt): Int {
        return FunBigIntArithmetic.floorLog2(b);
    }

    // Full domain hash based on SHA512
    static function fdh(data: String, bytelen: Int): String {
        var bitlen = bytelen << 3;
        var datab = Sha512.rstr2binb(data);
//        trace(datab);

        // Add hashing rounds until we exceed desired length in bits
        var counter = 0, output: Array<Int32> = [];
        var hashSrcBits = data.length * 8 + 32;
//      while (sjcl.bitArray.bitLength(output) < bitlen) {
        while (output.length * 32 < bitlen) {
            var hashSrc = [counter].concat(datab);
            if (debug) trace('hashSrc: ' + Sha512.rstr2hex(Sha512.binb2rstr(hashSrc)));
//            var hash = sjcl.hash.sha512.hash(sjcl.bitArray.concat([counter], data));
            var hash = Sha512.binb_sha512(hashSrc, hashSrcBits);
            if (debug) trace('hash: ' + Sha512.rstr2hex(Sha512.binb2rstr(hash)));
            output = output.concat(hash);
//            trace('output:' + Std.string(output.length * 32));
//            trace(output);
            counter++;
        }

        // Truncate to desired length
        //output = sjcl.bitArray.clamp(output, bitlen);
        if (output.length * 32 > bitlen) {
            output = output.splice(0, bitlen >> 5);
        }
        if (debug) trace('fdh out: ' + Sha512.rstr2hex(Sha512.binb2rstr(output)));

        return Sha512.rstr2hex(Sha512.binb2rstr(output));
    }

}


typedef DeriveRes = {
    ?id: String,
    ?crypt: String,
    ?unlock: String
}



@:enum
abstract DerivePurpose(String) {
  var login = 'login';
  var unlock = 'unlock';
}
