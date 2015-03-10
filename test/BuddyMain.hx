package ;

import buddy.*;
using buddy.Should;
import utest.Assert;

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

    #if nodejs
    static var name = 'debugtest08';
    static var address = 'rNQnDtNbiPKoJg5956B6YfQomTX9DWRiUm';
    #elseif neko
    static var name = 'debugtest07';
    static var address = 'rsSFa7N6UsRZJs2TGEtPYB3wQfFrCmaXrj';
    #elseif java
    static var name = 'debugtest05';
    static var address = 'rDggEzL4DmV7T8sCho21esUu54h2MYKMWN';
    #elseif cs
    static var name = 'debugtest04';
    static var address = 'r9RUfajXbdoPwRYMpMihGrf7FxkiMvY7km';
    #else
    static var name = 'debugtest02';
    static var address = 'rJK7UCGQdSsbxseNbE8ptm5tegSkBovNcE';
    #end

    static var exampleData = {
      id: '547ef68397a0c216816ee690ba5bc091fd86b14174a3d5bf08c82b3f16ff4cce',
      crypt: '5d6dd146d0e41c77c731fc46a92746ef7915bcba259688efedb91b923cad9eaf',
      unlock: '30234de31f18fcb13d26d9d77c5c78dcf9ffa3643bb14c281e7ca56e06101d19',
      username: 'exampleUser',
      new_username : 'exampleUser-rename',
      password: 'pass word',
      domain: 'integration.rippletrade.com',
      masterkey : 'ssize4HrSYZShMWBtK6BhALGEk8VH',
      email_token : '77825040-9096-4695-9cbc-76720f6a8649',
      activateLink : 'https://staging.ripple.com/client/#/register/activate/',
      device_id : "ac1b6f6dbca98190eb9687ba06f0e066",
      identity_id : "17fddb71-a5c2-44ce-8b50-4b381339d4f2",
      blob: {
        url: 'http://54.191.36.127:5993',
        id: '547ef68397a0c216816ee690ba5bc091fd86b14174a3d5bf08c82b3f16ff4cce',
        key: '5d6dd146d0e41c77c731fc46a92746ef7915bcba259688efedb91b923cad9eaf',
        data: {
          auth_secret: 'd0aa918e693080a6a8d0ddc7f4dcf4bc0eecc3c3e3235f16a98661ee9c2e7a58',
          account_id: 'raVUps4RghLYkVBcpMaRbVKRTTzhesPXd',
          email: 'example@example.com',
          contacts: [ ],
          created: '2014-05-20T23:39:52.538Z',
          apps: [ ],
          lastSeenTxDate: #if cpp 0 #else 1401925490000 #end,
          identityVault: { },
          revision: 2199,
          encrypted_secret: 'ACIdSmpv1Ikwhao5kdrcXASz3f9kDg/9oNfqKH6dyUvP0ZNW2Xt/mwYnRwKMUdAhrHLCGI49'
        }
      }
    };

    static var rippleTxtRes = '[authinfo_url]\r\nhttp://54.191.36.127:5993/v1/authinfo\r\n' +
        '[accounts]\r\nraVUps4RghLYkVBcpMaRbVKRTTzhesPXd\r\n' +
        '[currencies]\r\nUSD\r\n';

    static var authInfoRes = {
      "body" : {
        "version" : 3,
        "blobvault" : "http://54.191.36.127:5993",
        "pakdf" : {
          "modulus" : "ee419352d1693a785244282c22c5c74cdf2f5d40cb4bf5eee7cd3d37365082300c26bb68b58cfa04983eb95c2a8082a4e3e4eba333c546333e9cea3acd1fd50b24f8ce05d5cc6c896600570b315da4b70353748ed1ec5158ea3806fe208c2bb45f2b8731f89c13f009efd9dd23c9abb589df9ad270c3e7f2a111577b1679372054a3bf6ba9c43dcf49c37af0dc01f4b4f5de33986b7733564e26086d4e11a83ebd7a2a38a5fdca1cf1d39b1da8021c79be713428acdd796963501db8dae43af4159fd8e24575c87cc5a954c77a7fcbea7d8f99907a1d134d2c9577d216d4625363cb0b3a262c8cb9017e93c2b72025402f84499c343d5265ec2fc1a4d1c5cd59",
          "alpha" : "a4600a7e949f4a79cbf43996ea8d6e2523473bd54ad5841493cfdaddf1066e488d613bea61ee7220457b1bac25f659b63fedcd1c6df5e02841e2a1f067f4e4840b9436552d8f1875ec5b345c8cdd2e22a0f79f67ab94ba6a4432e6f0774ef34f2fd49d761695ac1a1fb4627c0f5933ea200d7f66e141ae7e79918f899b993f78e9ac49919a9f8f03dfeea6648b398e55364df1af13d8101650cedecb8473e46c4ad375b41b7142bed022fa85b30253e1221a9bd39a1eedfd06856aa47b6be18fcda735315ad7c06582c862d79c60e0dc4cc33e787d365f2788974c670340ae1941daa9110b327d68949e301fc08aa7639faf4dd558620f5d62bb9cea9ef3f1aa",
          "url" : "https://integration.auth.ripple.com/api/sign",
          "exponent" : "010001",
          "host" : "integration.auth.ripple.com"
        },
        "exists" : true,
        "username" : "exampleUser",
        "address" : "raVUps4RghLYkVBcpMaRbVKRTTzhesPXd",
        "emailVerified" : true,
        "reserved" : false,
        "profile_verified" : false,
        "identity_verified" : false
      }
    }

    static var signRes = {
      "result" : "success",
      "signres" : "302d41d4e314327d8ab7c10b344c28a3f26c223497eac0fad2698dbc3bca3b4acd941f5c06363db5ac35d91c9671aedd33d211b9d37532aac17f3ab795a0ac51e65df9e41306be5b0c92e9efa41d73848195afec7897aa25481f117079f2c13fd1817ea438445cb320f24e435832bde1af60fd47e08bf00d435e88f27f205d856234825cb9cb5af4053a92a54426de1ce6c5e8bdacb9af6482ccf2edb83f44bbd9d1c240ceb23cf9f5413dc13810ed17e8488b4ef192420ccc29e5ac7964b411fd8543c1ec6c5b61adb4ab842c4b1a6bacad7c9433564204f1a15cd6e4ddb512972ad005eec435fcfca3296d74c2c53f3bc1da18f537834d09e16506c91f1a79",
      "modulus" : "ee419352d1693a785244282c22c5c74cdf2f5d40cb4bf5eee7cd3d37365082300c26bb68b58cfa04983eb95c2a8082a4e3e4eba333c546333e9cea3acd1fd50b24f8ce05d5cc6c896600570b315da4b70353748ed1ec5158ea3806fe208c2bb45f2b8731f89c13f009efd9dd23c9abb589df9ad270c3e7f2a111577b1679372054a3bf6ba9c43dcf49c37af0dc01f4b4f5de33986b7733564e26086d4e11a83ebd7a2a38a5fdca1cf1d39b1da8021c79be713428acdd796963501db8dae43af4159fd8e24575c87cc5a954c77a7fcbea7d8f99907a1d134d2c9577d216d4625363cb0b3a262c8cb9017e93c2b72025402f84499c343d5265ec2fc1a4d1c5cd59",
      "alpha" : "a4600a7e949f4a79cbf43996ea8d6e2523473bd54ad5841493cfdaddf1066e488d613bea61ee7220457b1bac25f659b63fedcd1c6df5e02841e2a1f067f4e4840b9436552d8f1875ec5b345c8cdd2e22a0f79f67ab94ba6a4432e6f0774ef34f2fd49d761695ac1a1fb4627c0f5933ea200d7f66e141ae7e79918f899b993f78e9ac49919a9f8f03dfeea6648b398e55364df1af13d8101650cedecb8473e46c4ad375b41b7142bed022fa85b30253e1221a9bd39a1eedfd06856aa47b6be18fcda735315ad7c06582c862d79c60e0dc4cc33e787d365f2788974c670340ae1941daa9110b327d68949e301fc08aa7639faf4dd558620f5d62bb9cea9ef3f1aa",
      "exponent" : "010001"
    };

    static var blobRes = {
      "result":"success",
      "encrypted_secret":"ACIdSmpv1Ikwhao5kdrcXASz3f9kDg/9oNfqKH6dyUvP0ZNW2Xt/mwYnRwKMUdAhrHLCGI49",
      "blob": "AIl1G2VKIuK1yFq/rk5TVuURG9oTwQ6RCDukDX7lENpUJCTDo8dETYY0iAyQlLOxK/NKEI5MEeZnEcJXiB/V7Fdf9Kb+n4SXdKboGO8mbRxHc+JzAcjXqXADeOZcJl7csXDKMaduLPQAKjXoz0oa6+YCqkiznybo7eNUZS1jXLHjv8jr73oAk+xMqm/sDaqYOvgyZO8JbSKuo/RHdzXpEdYpbCoEApr94MpqrU0SnqI5P2gcJweqoI2Hbs7wrI9shYK82rAiUKVxVuOQ1BHW+vLcMPQkV20g5Kq0eYTDhdXOJ/TX4fhqy8ibmD+KoFOTm8ycqWoyua+6ROPKW9DYmsX/4Xnuo8h+muKQg/DCEENM8dOUPJcarHtbQpXc6sLOuvzQnbDkc+B9NNTl/uGm4krCcl4zzv8JRn9Bq70b0Fm4NIMjocLLVltGUWlCdytA9fl4sGabqHFjbNH8QcdYE16YTpI+dcqxW4eE3xcu4DXeXYhJnXflI17DZV4vgAR0geucoyh6co5XF01KcSgPpgrhOSB3JFyIVPXElkYi6fZ7bgvLYJQoc5uqht+cheCj8NgRwauX4gnZTE6pKbWrkjQl2l1ng4WAMd5Bs1foDgHnYsn9olI2uy/Lcc5Hga/4ioHCDzUVOibvKDp79lPwm2jDFc0jC7NL33EBD0uRaQw9lP9ZdTwZ6oWqJCHI2ri48X6VFr5kmVh7Rfd+Z0+Kvklw6Vz3dmUHHM1DuFLvunMQUwQYGeMD/k6AbTS6PXGj+jFZGrEYWbKWkJCo+EoSZdBmyLpLPkcMVs1iNt1iu3aAbpeBrVmrw2EVAlPIOD2eT8onaDsfGnkLiRviOU3XPRclpgyfOZPTiV73qwa5DIGm9BTHVkG0zRPPftDpi8SDRen5JMbKVawjcacvwIMcWkEoje9fv1/lyn1XZBoDv+Bh+BnKDCWl694I3tiqO/I2dE2icCm37O/iev4VY8aOh6Ls5UWF9lqWpaMjBg+wXOx9s0QUDYL6i+b9/CMUxqrSXzrpTFKqmpG/kQGzYMRgSM9TJTWnjR1TS9pRmRNnc/Ks3FXOb8j/tdLqWYUCRqLSoumXnjw1OdThojzGCykAI04z/nYWMgY43qGBjyOeZkMsfb+1/zNGx7XOVx+utg9EtUhbEh1SUFX2lWnGIwLUrn8k+kFZ98/0z+zQLfxpwpTB+krBp1JUmPDEQEXAQvQlkqtx29i2/r4NS3ONOMwyXUjggkY/RXkxVOseWFhetjQz",
      "revision":2579,
      "email":"example@example.com",
      "quota":-2779,
      "patches":[],
      "identity_id":"0f63e623-bbce-4e01-8910-8381d0cc3117",
      "missing_fields":{"country":"missing","region":"missing"}
    };


    public function new() {
        this.timeoutMs = 15000;
#if nodejs
        //must be set for self signed certs
    untyped __js__("process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';");
#end

#if !nodejs
        describe("Test RippleTxt requests", {

            it("should get ripple.txt from ripple.com", function(done) {
                RippleTxt.get('ripple.com')
                .either(function(txt: Dynamic) {
//                    Reflect.hasField(txt, 'validators').should.be(true);
                    var hasValidators = Reflect.hasField(txt, 'validators');
                    if (!hasValidators) fail('Should contains validators');
                    var validators: Array<String> = txt.validators;
//                    validators.should.contain('n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj');
                    if (!Lambda.has(validators, 'n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj')) {
                        fail('validators should contain n9MD5h24qrQqiyBC8aeqqCWvpiBiYQ3jxSr91uiDvmrkyHRdYLUj');
                    }

                    done();
                }, fail);
            });
        });

        describe("Test AuthInfo requests", {
            it("should get info from https://id.ripple.com", function(done) {
                AuthInfo.get('ripple.com', 'debugtest08')
                .either(function(ai) {
//                    trace(ai);
                    var addressRight = ai.address == 'rNQnDtNbiPKoJg5956B6YfQomTX9DWRiUm';
                    if (!addressRight) fail('wrong address');
                    var exists = ai.exists;
                    if (!exists) fail('shoud exists');
                    done();
                }, fail);
            });
        });
#else

        describe('Ripple Txt', {
          it('should get the content of a ripple.txt file from a given domain', function(done) {
            RippleTxt.get(exampleData.domain).either(function(resp) {
              Assert.notNull(resp);
//              Assert.isNull(resp);
//              if (resp == null) fail('is null!');
//              trace(resp);
              done();
            }, fail);
          });

//          it('should get currencies from a ripple.txt file for a given domain', function(done) {
//            RippleTxt.getCurrencies(exampleData.domain, function(err, currencies) {
//              assert.ifError(err);
//              assert(Array.isArray(currencies));
//              done();
//            });
//          });

//          it('should get the domain from a given url', function() {
//            var domain = RippleTxt.extractDomain("http://www.example.com");
//            assert.strictEqual(typeof domain, 'string');
//          });
        });

        describe('AuthInfo', function() {
          it('should get auth info', function(done) {
            AuthInfo.get(exampleData.domain, exampleData.username).either(function(resp) {
//                trace(resp);
                Lambda.iter(Reflect.fields(authInfoRes.body), function(prop) {
                    Assert.isTrue(Reflect.hasField(resp, prop));
                });
//              Object.keys(authInfoRes.body).forEach(function(prop) {
//                assert(resp.hasOwnProperty(prop));
//              });
              done();
            }, fail);
          });
        });

#end
    }
}

