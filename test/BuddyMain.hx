package ;

import buddy.*;
using buddy.Should;

import ripple.vaultclient.RippleTxt;
import ripple.vaultclient.AuthInfo;

// "implements Buddy" is only required for the Main class.
class BuddyMain extends BuddySuite implements Buddy {

    static var rippleTxtRes = '[authinfo_url]\r\nhttp://54.191.36.127:5993/v1/authinfo\r\n' +
        '[accounts]\r\nraVUps4RghLYkVBcpMaRbVKRTTzhesPXd\r\n' +
        '[currencies]\r\nUSD\r\n';

    public function new() {
        describe("Test RippleTxt", {

            before({
            });

            it("should parse ripple.txt", {
                var txt = RippleTxt.parse(rippleTxtRes);
                Reflect.hasField(txt, 'accounts').should.be(true);
//                trace('txt accounts:');
//                trace(txt);
//                trace(txt.accounts);

                var account: String = txt.accounts[0];
                account.should.be('raVUps4RghLYkVBcpMaRbVKRTTzhesPXd');
            });

        });
    }
}

class AsyncTest extends BuddySuite {
    public function new() {
        this.timeoutMs = 15000;

        describe("Test RippleTxt requests", {

            it("should get ripple.txt from ripple.com", function(done) {
                RippleTxt.get('ripple.com')
                .then(function(txt: Dynamic) {
//                    Reflect.hasField(txt, 'validators').should.be(true);
                    var hasValidators = Reflect.hasField(txt, 'validators');
                    if (!hasValidators) fail('Should contains validators');
                    var validators: Array<String> = txt.validators;
//                    validators.should.contain('n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj');
                    if (!Lambda.has(validators, 'n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj')) {
                        fail('validators should contain n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj');
                    }

                    done();
                })
                .catchError(fail);
            });
        });

        describe("Test AuthInfo requests", {
            it("should get info from https://id.ripple.com", function(done) {
                AuthInfo.get('ripple.com', 'debugtest08')
                .then(function(ai) {
//                    trace(ai);
                    var addressRight = ai.address == 'rNQnDtNbiPKoJg5956B6YfQomTX9DWRiUm';
                    if (!addressRight) fail('wrong address');
                    var exists = ai.exists;
                    if (!exists) fail('shoud exists');
                    done();
                })
                .catchError(fail);
            });
        });

    }
}

