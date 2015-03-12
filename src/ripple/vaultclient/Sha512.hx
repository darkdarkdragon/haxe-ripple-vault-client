package ripple.vaultclient;

import haxe.Int64;
import haxe.Int32;

using ripple.vaultclient.MathTools;

/**
 * ActionScript code from here
 * http://stackoverflow.com/questions/1267873/porting-sha512-javascript-implemention-to-actionscript
 * ported to haxe
 */

/*
 * SHA-512 for ActionScript
 * Ported by: AAA
 * Ported from: See below
 */

/*
 * A JavaScript implementation of the Secure Hash Algorithm, SHA-512, as defined
 * in FIPS 180-2
 * Version 2.2 Copyright Anonymous Contributor, Paul Johnston 2000 - 2009.
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for details.
 */
class Sha512 {
    public static var hexcase = false;
    public static var b64pad  = "";


    public static function hex_sha512(s: String): String {
        return rstr2hex(rstr_sha512(str2rstr_utf8(s)));
    }

    public static function b64_sha512(s: String) {
        return rstr2b64(rstr_sha512(str2rstr_utf8(s)));
    }

    public static function any_sha512(s, e) {
        return rstr2any(rstr_sha512(str2rstr_utf8(s)), e);
    }

    public static function hex_hmac_sha512(k: String, d: String) {
        return rstr2hex(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d)));
    }

    public static function b64_hmac_sha512(k: String, d: String) {
        return rstr2b64(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d)));
    }

    public static function any_hmac_sha512(k: String, d: String, e: String) {
        return rstr2any(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d)), e);
    }

    public static function sha512_vm_test() {
        return hex_sha512("abc").toLowerCase() == "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a"
                                                + "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f" &&
            hex_hmac_sha512('key', 'data').toLowerCase() == '3c5953a18f7303ec653ba170ae334fafa08e3846f2efe317b87efce82376253cb52a8c31ddcde5a3a2eee183c2b34cb91f85e64ddbc325f7692b199473579c58';
    }

    private static function rstr_sha512(s: String): String {
        return binb2rstr(binb_sha512(rstr2binb(s), s.length * 8));
    }

    private static function rstr_hmac_sha512(key: String, data: String): String {
        var bkey = rstr2binb(key);
        if (bkey.length > 32) bkey = binb_sha512(bkey, key.length * 8);

        var ipad = new Array<Int32>();
        var opad = new Array<Int32>();
        for(i in 0...32) {
            ipad.push(bkey[i] ^ 0x36363636);
            opad.push(bkey[i] ^ 0x5C5C5C5C);
        }

        var hash = binb_sha512(ipad.concat(rstr2binb(data)), 1024 + data.length * 8);
        return binb2rstr(binb_sha512(opad.concat(hash), 1024 + 512));
    }

    private static function rstr2hex(input: String): String {
        var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
        var output = "";
        var x;
        for (i in 0...input.length) {
            x = input.charCodeAt(i);
            output += hex_tab.charAt((x >>> 4) & 0x0F) + hex_tab.charAt(x & 0x0F);
        }
        return output;
    }

    private static function rstr2b64(input: String): String {
        var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var output = "";
        var len = input.length;
        var i = 0;
        while (i < len) {
            var triplet = (input.charCodeAt(i) << 16)
            | (i + 1 < len ? input.charCodeAt(i+1) << 8 : 0)
            | (i + 2 < len ? input.charCodeAt(i+2)      : 0);
            for (j in 0...4) {
                if (i * 8 + j * 6 > input.length * 8) output += b64pad;
                else output += tab.charAt((triplet >>> 6*(3-j)) & 0x3F);
            }
            i += 3;
        }
        return output;
    }

    private static function rstr2any(input: String, encoding: String): String {
        var divisor: Int = encoding.length;
        var i, j, x, quotient;
        var q: Int;

//        var dividend = new Array(Math.ceil(input.length / 2));
        var dividend = [];
        var dividendLength = Math.ceil(input.length / 2);
        for(i in 0...dividendLength) {
            dividend.push( (input.charCodeAt(i * 2) << 8) | input.charCodeAt(i * 2 + 1) );
        }

        var full_length = Math.ceil(input.length * 8 / (Math.log(encoding.length) / Math.log(2)));
//        var remainders = new Array(full_length);
        var remainders = new Array();
        for (j in 0...full_length) {
            quotient = [];
            x = 0;
            for(i  in 0...dividend.length) {
                x = (x << 16) + dividend[i];
                q = Math.floor(x / divisor);
                x -= q * divisor;
                if (quotient.length > 0 || q > 0) {
                    quotient[quotient.length] = q;
                }
            }
//            remainders[j] = x;
            remainders.push(x);
            dividend = quotient;
        }

        var output = "";
        var i = remainders.length - 1;
        while (i >= 0) {
            output += encoding.charAt(remainders[i]);
            i -= 1;
        }
        return output;
    }

    private static function str2rstr_utf8(input: String): String {
        var output = "";
        var i = -1;
        var x, y;

        while (++i < input.length) {
            x = input.charCodeAt(i);
            y = i + 1 < input.length ? input.charCodeAt(i + 1) : 0;
            if (0xD800 <= x && x <= 0xDBFF && 0xDC00 <= y && y <= 0xDFFF) {
                x = 0x10000 + ((x & 0x03FF) << 10) + (y & 0x03FF);
                i++;
            }

            if (x <= 0x7F)
                output += String.fromCharCode(x);
            else if (x <= 0x7FF)
                output += String.fromCharCode(0xC0 | ((x >>> 6 ) & 0x1F)) + String.fromCharCode(0x80 | ( x & 0x3F));
            else if (x <= 0xFFFF)
                output += String.fromCharCode(0xE0 | ((x >>> 12) & 0x0F)) +
                                String.fromCharCode(0x80 | ((x >>> 6 ) & 0x3F)) +
                                String.fromCharCode(0x80 | ( x         & 0x3F));
            else if (x <= 0x1FFFFF)
                output += String.fromCharCode(0xF0 | ((x >>> 18) & 0x07)) +
                                String.fromCharCode(0x80 | ((x >>> 12) & 0x3F)) +
                                String.fromCharCode(0x80 | ((x >>> 6 ) & 0x3F)) +
                                String.fromCharCode(0x80 | ( x         & 0x3F));
        }
        return output;
    }

    private static function str2rstr_utf16le(input: String): String {
        var output = "";
        for (i in 0...input.length) {
            output += String.fromCharCode( input.charCodeAt(i)        & 0xFF) +
                      String.fromCharCode((input.charCodeAt(i) >>> 8) & 0xFF);
        }
        return output;
    }

    private static function str2rstr_utf16be(input: String): String {
        var output = "";
        for (i in 0...input.length) {
            output += String.fromCharCode((input.charCodeAt(i) >>> 8) & 0xFF) +
                      String.fromCharCode(input.charCodeAt(i)        & 0xFF);
        }
        return output;
    }

    private static function rstr2binb(input: String): Array<Int32> {
        var output = [];
        var outputLength = input.length >> 2;
        if (outputLength == 0) outputLength = 1;
        for (i in 0...outputLength) {
            output.push(0);
        }
        var i = 0;
        while (i < input.length * 8) {
            output[i >> 5] |= (input.charCodeAt(Std.int(i / 8)) & 0xFF) << (24 - i % 32);
            i += 8;
        }
        return output;
    }

    private static function binb2rstr(input: Array<Int32>): String {
        var output = "";
        var i = 0;
        while (i < input.length * 32) {
            output += String.fromCharCode((input[i >> 5] >>> (24 - i % 32)) & 0xFF);
            i += 8;
        }
        return output;
    }

    static var sha512_k: Array<Int64> = null;

    private static function binb_sha512(x: Array<Int32>, len: Int): Array<Int32> {
        if (sha512_k == null) {
            sha512_k = [
                Int64.make(0x428a2f98, -685199838), Int64.make(0x71374491, 0x23ef65cd),
                Int64.make(-1245643825, -330482897), Int64.make(-373957723, -2121671748),
                Int64.make(0x3956c25b, -213338824), Int64.make(0x59f111f1, -1241133031),
                Int64.make(-1841331548, -1357295717), Int64.make(-1424204075, -630357736),
                Int64.make(-670586216, -1560083902), Int64.make(0x12835b01, 0x45706fbe),
                Int64.make(0x243185be, 0x4ee4b28c), Int64.make(0x550c7dc3, -704662302),
                Int64.make(0x72be5d74, -226784913), Int64.make(-2132889090, 0x3b1696b1),
                Int64.make(-1680079193, 0x25c71235), Int64.make(-1046744716, -815192428),
                Int64.make(-459576895, -1628353838), Int64.make(-272742522, 0x384f25e3),
                Int64.make(0xfc19dc6, -1953704523), Int64.make(0x240ca1cc, 0x77ac9c65),
                Int64.make(0x2de92c6f, 0x592b0275), Int64.make(0x4a7484aa, 0x6ea6e483),
                Int64.make(0x5cb0a9dc, -1119749164), Int64.make(0x76f988da, -2096016459),
                Int64.make(-1740746414, -295247957), Int64.make(-1473132947, 0x2db43210),
                Int64.make(-1341970488, -1728372417), Int64.make(-1084653625, -1091629340),
                Int64.make(-958395405, 0x3da88fc2), Int64.make(-710438585, -1828018395),
                Int64.make(0x6ca6351, -536640913), Int64.make(0x14292967, 0xa0e6e70),
                Int64.make(0x27b70a85, 0x46d22ffc), Int64.make(0x2e1b2138, 0x5c26c926),
                Int64.make(0x4d2c6dfc, 0x5ac42aed), Int64.make(0x53380d13, -1651133473),
                Int64.make(0x650a7354, -1951439906), Int64.make(0x766a0abb, 0x3c77b2a8),
                Int64.make(-2117940946, 0x47edaee6), Int64.make(-1838011259, 0x1482353b),
                Int64.make(-1564481375, 0x4cf10364), Int64.make(-1474664885, -1136513023),
                Int64.make(-1035236496, -789014639), Int64.make(-949202525, 0x654be30),
                Int64.make(-778901479, -688958952), Int64.make(-694614492, 0x5565a910),
                Int64.make(-200395387, 0x5771202a), Int64.make(0x106aa070, 0x32bbd1b8),
                Int64.make(0x19a4c116, -1194143544), Int64.make(0x1e376c08, 0x5141ab53),
                Int64.make(0x2748774c, -544281703), Int64.make(0x34b0bcb5, -509917016),
                Int64.make(0x391c0cb3, -976659869), Int64.make(0x4ed8aa4a, -482243893),
                Int64.make(0x5b9cca4f, 0x7763e373), Int64.make(0x682e6ff3, -692930397),
                Int64.make(0x748f82ee, 0x5defb2fc), Int64.make(0x78a5636f, 0x43172f60),
                Int64.make(-2067236844, -1578062990), Int64.make(-1933114872, 0x1a6439ec),
                Int64.make(-1866530822, 0x23631e28), Int64.make(-1538233109, -561857047),
                Int64.make(-1090935817, -1295615723), Int64.make(-965641998, -479046869),
                Int64.make(-903397682, -366583396), Int64.make(-779700025, 0x21c0c207),
                Int64.make(-354779690, -840897762), Int64.make(-176337025, -294727304),
                Int64.make(0x6f067aa, 0x72176fba), Int64.make(0xa637dc5, -1563912026),
                Int64.make(0x113f9804, -1090974290), Int64.make(0x1b710b35, 0x131c471b),
                Int64.make(0x28db77f5, 0x23047d84), Int64.make(0x32caab7b, 0x40c72493),
                Int64.make(0x3c9ebe0a, 0x15c9bebc), Int64.make(0x431d67c4, -1676669620),
                Int64.make(0x4cc5d4be, -885112138), Int64.make(0x597f299c, -60457430),
                Int64.make(0x5fcb6fab, 0x3ad6faec), Int64.make(0x6c44198c, 0x4a475817)
            ];
        }

        var H = [
            Int64.make(0x6a09e667, -205731576),
            Int64.make(-1150833019, -2067093701),
            Int64.make(0x3c6ef372, -23791573),
            Int64.make(-1521486534, 0x5f1d36f1),
            Int64.make(0x510e527f, -1377402159),
            Int64.make(-1694144372, 0x2b3e6c1f),
            Int64.make(0x1f83d9ab, -79577749),
            Int64.make(0x5be0cd19, 0x137e2179)
            ];

        var T1 = Int64.make(0, 0),
        T2 = Int64.make(0, 0),
        a = Int64.make(0,0),
        b = Int64.make(0,0),
        c = Int64.make(0,0),
        d = Int64.make(0,0),
        e = Int64.make(0,0),
        f = Int64.make(0,0),
        g = Int64.make(0,0),
        h = Int64.make(0,0),

        s0 = Int64.make(0, 0),
        s1 = Int64.make(0, 0),
        Ch = Int64.make(0, 0),
        Maj = Int64.make(0, 0),
        r1 = Int64.make(0, 0),
        r2 = Int64.make(0, 0),
        r3 = Int64.make(0, 0);
        var j, i;
//        var W = new Array(80);
        var W = new Array<Int64>();
        for (i in 0...80) {
            W.push(Int64.make(0, 0));
        }

        var need = ((len + 128 >> 10) << 5) + 31 - x.length;
        for (i in 0...need) x.push(0);

        x[len >> 5] |= 0x80 << (24 - (len & 0x1f));
        x[((len + 128 >> 10)<< 5) + 31] = len;

        var i = 0;
        while (i < x.length) {
            a = H[0].copy();
            b = H[1].copy();
            c = H[2].copy();
            d = H[3].copy();
            e = H[4].copy();
            f = H[5].copy();
            g = H[6].copy();
            h = H[7].copy();

            for (j in 0...16) {
                W[j] = Int64.make(x[i + 2 * j], x[i + 2 * j + 1]);
            }

            for (j in 16...80) {
                r1 = W[j - 2].rrot(19);
                r2 = W[j - 2].revrrot(29);
                r3 = W[j - 2] >>> 6;
                s1 = Int64.make(
                    haxe.Int64.getHigh(r1) ^ haxe.Int64.getHigh(r2) ^ haxe.Int64.getHigh(r3),
                    haxe.Int64.getLow(r1) ^ haxe.Int64.getLow(r2) ^ haxe.Int64.getLow(r3)
                );

                r1 = W[j - 15].rrot(1);
                r2 = W[j - 15].rrot(8);
                r3 = W[j - 15] >>> 7;
                s0 = Int64.make(
                    haxe.Int64.getHigh(r1) ^ haxe.Int64.getHigh(r2) ^ haxe.Int64.getHigh(r3),
                    haxe.Int64.getLow(r1) ^ haxe.Int64.getLow(r2) ^ haxe.Int64.getLow(r3)
                );

                W[j]  = s1 + W[j - 7] + s0 + W[j - 16];
            }


            for (j in 0...80) {
                Ch = Int64.make(
                    (haxe.Int64.getHigh(e) & haxe.Int64.getHigh(f)) ^ (~haxe.Int64.getHigh(e) & haxe.Int64.getHigh(g)),
                    (haxe.Int64.getLow(e) & haxe.Int64.getLow(f)) ^ (~haxe.Int64.getLow(e) & haxe.Int64.getLow(g))
                );


                r1 = e.rrot(14);
                r2 = e.rrot(18);
                r3 = e.revrrot(9);
                s1 = Int64.make(
                    haxe.Int64.getHigh(r1) ^ haxe.Int64.getHigh(r2) ^ haxe.Int64.getHigh(r3),
                    haxe.Int64.getLow(r1) ^ haxe.Int64.getLow(r2) ^ haxe.Int64.getLow(r3)
                );


                r1 = a.rrot(28);
                r2 = a.revrrot(2);
                r3 = a.revrrot(7);
                s0 = Int64.make(
                    haxe.Int64.getHigh(r1) ^ haxe.Int64.getHigh(r2) ^ haxe.Int64.getHigh(r3),
                    haxe.Int64.getLow(r1) ^ haxe.Int64.getLow(r2) ^ haxe.Int64.getLow(r3)
                );

                Maj = Int64.make(
                    (haxe.Int64.getHigh(a) & haxe.Int64.getHigh(b)) ^ (haxe.Int64.getHigh(a) & haxe.Int64.getHigh(c)) ^ (haxe.Int64.getHigh(b) & haxe.Int64.getHigh(c)),
                    (haxe.Int64.getLow(a) & haxe.Int64.getLow(b)) ^ (haxe.Int64.getLow(a) & haxe.Int64.getLow(c)) ^ (haxe.Int64.getLow(b) & haxe.Int64.getLow(c))
                );


                T1 = h + s1 + Ch + sha512_k[j] + W[j];
                T2 = s0 + Maj;

                h = g.copy();
                g = f.copy();
                f = e.copy();
                e = d + T1;
                d = c.copy();
                c = b.copy();
                b = a.copy();
                a = T1 + T2;
            }

            H[0] = H[0] + a;
            H[1] = H[1] + b;
            H[2] = H[2] + c;
            H[3] = H[3] + d;
            H[4] = H[4] + e;
            H[5] = H[5] + f;
            H[6] = H[6] + g;
            H[7] = H[7] + h;
            i += 32;
        }

        var hash: Array<Int32> = [];
        for (i in 0...8) {
            hash.push(haxe.Int64.getHigh(H[i]));
            hash.push(haxe.Int64.getLow(H[i]));
        }

        return hash;
    }

    static function i642hex(v: Int64): String {
        var y = [];
        y.push(Int64.getHigh(v));
        y.push(Int64.getLow(v));
        return binb2hex(y);
    }

    static function arr642str(d: Array<Int64>): String {
        var x = [];
        for (v in d) {
            var y = [];
            y.push(Int64.getHigh(v));
            y.push(Int64.getLow(v));
            x.push(binb2hex(y));
        }
        return x.join(',');
    }

    ////// -----------?
    /*
    private static function hex_hmac_sha512_v2(key, data) {
        key = str2rstr_utf8(key);
        data = str2rstr_utf8(data);
        var bkey = rstr2binb(key);
        if (bkey.length > 32) bkey = binb_sha512(bkey, key.length * 8);

//        var ipad = new Array(32)
//        var opad = new Array(32);
//        for(var i = 0; i < 32; i++) {
//            ipad[i] = bkey[i] ^ 0x36363636;
//            opad[i] = bkey[i] ^ 0x5C5C5C5C;
//        }
        var ipad = [];
        var opad = [];
        for(i in 0...32) {
            ipad.push(bkey[i] ^ 0x36363636);
            opad.push(bkey[i] ^ 0x5C5C5C5C);
        }

        var hash = binb_sha512(ipad.concat(rstr2binb(data)), 1024 + data.length * 8);
        return binb2hex(binb_sha512(opad.concat(hash), 1024 + 512));
    }
    */

    private static function binb2hex(input: Array<Int32>): String {
        var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
        var output = "";
        var i = 0;
        while (i < input.length * 32) {
            var schar = (input[i>>5] >>> (24 - i % 32)) & 0xFF;
            output += hex_tab.charAt((schar >>> 4) & 0x0F) + hex_tab.charAt(schar & 0x0F);
            i += 8;
        }
        return output;
    }

}
