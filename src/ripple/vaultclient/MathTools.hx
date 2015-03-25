package ripple.vaultclient;

import haxe.Int64;

/**
 * ...
 * @author Ivan Tivonenko
 */
class MathTools {

//    public static function copyFromOver(dst: Int64, src: Int64) {
//        dst.high = src.high;
//        dst.low = src.low;
//    }
    public static function rrot(x: Int64, shift: Int): Int64 {
        return Int64.make(
        #if (haxe_ver >= "3.2")
            (x.high >>> shift) | (x.low  << (32 - shift)),
            (x.low  >>> shift) | (x.high << (32 - shift))
        #else
            (haxe.Int64.getHigh(x) >>> shift) | (haxe.Int64.getLow(x)  << (32-  shift)),
            (haxe.Int64.getLow(x)  >>> shift) | (haxe.Int64.getHigh(x) << (32 - shift))
        #end
        );
    }

    public static function revrrot(x: Int64, shift: Int): Int64 {
        return Int64.make(
        #if (haxe_ver >= "3.2")
            (x.low  >>> shift) | (x.high << (32 - shift)),
            (x.high >>> shift) | (x.low  << (32 - shift))
        #else
            (haxe.Int64.getLow(x)  >>> shift) | (haxe.Int64.getHigh(x) << (32 - shift)),
            (haxe.Int64.getHigh(x) >>> shift) | (haxe.Int64.getLow(x)  << (32 - shift))
        #end
        );
    }

}
