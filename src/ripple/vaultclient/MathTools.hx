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
            (haxe.Int64.getHigh(x) >>> shift) | (haxe.Int64.getLow(x)  << (32-  shift)),
            (haxe.Int64.getLow(x)  >>> shift) | (haxe.Int64.getHigh(x) << (32 - shift))
        );
    }

    public static function revrrot(x: Int64, shift: Int): Int64 {
        return Int64.make(
            (haxe.Int64.getLow(x)  >>> shift) | (haxe.Int64.getHigh(x) << (32 - shift)),
            (haxe.Int64.getHigh(x) >>> shift) | (haxe.Int64.getLow(x)  << (32 - shift))
        );
    }

}
