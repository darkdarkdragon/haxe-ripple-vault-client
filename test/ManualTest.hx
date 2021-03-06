
import ripple.vaultclient.RippleTxt;
import ripple.vaultclient.AuthInfo;
import ripple.vaultclient.BlobClient;
import ripple.vaultclient.VaultClient;


class ManualTest {

    static var domain = 'rippletrade.com';
    static var domain1 = 'ripple.com';

    static var rippleTxtRes = '[authinfo_url]\r\nhttp://54.191.36.127:5993/v1/authinfo\r\n' +
        '[accounts]\r\nraVUps4RghLYkVBcpMaRbVKRTTzhesPXd\r\n' +
        '[currencies]\r\nUSD\r\n';


    static function testRippleTxt() {
        var rt = RippleTxt.get(domain1);
        rt.success(function(txt: Dynamic) {
            trace('for $domain1 got ripple.txt:');
            trace(txt);
            trace('txt.validation_public_key: ${txt.validation_public_key}');
            trace(txt.validation_public_key != null && txt.validation_public_key[0] == 'n9KPnVLn7ewVzHvn218DcEYsnWLzKerTDwhpofhk4Ym1RUq4TeGw');
        });

        var txt = RippleTxt.parse(rippleTxtRes);

        trace(txt.authinfo_url[0] == 'http://54.191.36.127:5993/v1/authinfo');
    }

    static function testAuthInfo() {
        AuthInfo.get('ripple.com', 'debugtest08')
        .success(function(ai) {
            trace(ai);
            var addressRight = ai.address == 'rNQnDtNbiPKoJg5956B6YfQomTX9DWRiUm';
            trace('addressRight: $addressRight');
        })
        .failure(function(e) {
            trace(e);
        });
    }

    static function testBlobClient() {
//        var bobj = BlobClient.get('https://id.ripple.com', );


    }

    static function testVaultClient() {
        var client = new VaultClient();
        client.login('ivegotnobalances', 'password123', '183ceb28-ebd4-4cf4-9d19-8aee244ea4a9').either(function(loginRes) {
            trace('logged in');
            trace(loginRes);
        }, function(e) {
            trace(e);
        });
    }

    public static function main() {
        trace('start');
//        testRippleTxt();
//        testAuthInfo();
//        testVaultClient();
        trace('sha512_vm_test: ${ripple.vaultclient.Sha512.sha512_vm_test()}');
    }
}
