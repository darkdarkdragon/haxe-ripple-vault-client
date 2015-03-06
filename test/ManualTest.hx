
import ripple.vaultclient.RippleTxt;
import ripple.vaultclient.AuthInfo;


class ManualTest {

    static var domain = 'rippletrade.com';
    static var domain1 = 'ripple.com';

    static var rippleTxtRes = '[authinfo_url]\r\nhttp://54.191.36.127:5993/v1/authinfo\r\n' +
        '[accounts]\r\nraVUps4RghLYkVBcpMaRbVKRTTzhesPXd\r\n' +
        '[currencies]\r\nUSD\r\n';

    public static function main() {
        trace('start');

        var rt = RippleTxt.get(domain1);
        rt.then(function(txt: Dynamic) {
            trace('for $domain1 got ripple.txt:');
            trace(txt);
            trace('txt.validation_public_key: ${txt.validation_public_key}');
            trace(txt.validation_public_key != null && txt.validation_public_key[0] == 'n9KPnVLn7ewVzHvn218DcEYsnWLzKerTDwhpofhk4Ym1RUq4TeGw');
        });

        var txt = RippleTxt.parse(rippleTxtRes);

        trace(txt.authinfo_url[0] == 'http://54.191.36.127:5993/v1/authinfo');
    }
}
