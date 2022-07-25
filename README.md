# delphi-AES-256-CBC-laravel-sample

===================================== English version sample document
This repository contains a delphi sample project to create AES-256-cbc cipher compitable with Laravel decriptscript function.

This sample use MHumm's Delphi Encryption Compendium project, the github url is:
https://github.com/MHumm/DelphiEncryptionCompendium

The package is very powerful and easy to use. Thanks for MHumm contribution.

However, the sample project Cipher_FMX comes with the source code production does not
accepted by Laravel decriptstring function, which invokes the openssl_decrypt from OpenSSL
library.

The openssl_decrypt from OpenSSL and Delphi Encryption Compendium encrypt plaindata with different
initial vector (aka IV). Delphi Encryption Compendium let developers use any IV data, but openssl_decrypt
use IV with the padding byte count.

For example, with AES-256-CBC, the IV size is 16 bytes. Let's see the padding byte with plain data length:
Plain data is 15 bytes (or N x 16 + 15 bytes), 1 byte should be padded in openssl_encrypt, the padding byte will be $1.
Plain data is 14 bytes (or N x 16 + 14 bytes), 2 bytes should be padded in openssl_encrypt, the padding byte will be $2.
Plain data is 13 bytes (or N x 16 + 13 bytes), 3 bytes should be padded in openssl_encrypt, the padding byte will be $3.
Plain data is 12 bytes (or N x 16 + 12 bytes), 4 bytes should be padded in openssl_encrypt, the padding byte will be $4.
Plain data is 11 bytes (or N x 16 + 11 bytes), 5 bytes should be padded in openssl_encrypt, the padding byte will be $5.
Plain data is 10 bytes (or N x 16 + 10 bytes), 6 bytes should be padded in openssl_encrypt, the padding byte will be $6.
Plain data is 9 bytes (or N x 16 + 9 bytes), 7 bytes should be padded in openssl_encrypt, the padding byte will be $7.
Plain data is 8 bytes (or N x 16 + 8 bytes), 8 bytes should be padded in openssl_encrypt, the padding byte will be $8.
Plain data is 7 bytes (or N x 16 + 7 bytes), 9 bytes should be padded in openssl_encrypt, the padding byte will be $9.
Plain data is 6 bytes (or N x 16 + 6 bytes), 10 bytes should be padded in openssl_encrypt, the padding byte will be $A.
Plain data is 5 bytes (or N x 16 + 5 bytes), 11 bytes should be padded in openssl_encrypt, the padding byte will be $B.
Plain data is 4 bytes (or N x 16 + 4 bytes), 12 bytes should be padded in openssl_encrypt, the padding byte will be $C.
Plain data is 3 bytes (or N x 16 + 3 bytes), 13 bytes should be padded in openssl_encrypt, the padding byte will be $D.
Plain data is 2 bytes (or N x 16 + 2 bytes), 14 bytes should be padded in openssl_encrypt, the padding byte will be $E.
Plain data is 1 bytes (or N x 16 + 1 bytes), 15 bytes should be padded in openssl_encrypt, the padding byte will be $F.

In my sample project, you can input string with any length, clicking the "encrypt it" button, the cipher will be shown
as base64 encoded string in the Cipher editor. If you decoded the string with base64, you will see a json payload structure,
including 4 parts: "IV", "value", "mac", and "tag".

You can copy the encoded base64 cipher, and use Crypt::decryptString function in Laravel, the Crypt class comes with
default bundled module, you have to add this line in the use section of the php file:

use Illuminate\Support\Facades\Crypt;

and add the code in any function you can trigger from Console/Web/API:
$plainText = Crypt::decryptString($cipher); // the $cipher is the base64 encoded string created in my sample project.
                                            // and the $plainText is the text you input as source string in Delphi project.
                                            
About the Key, it should be a string length with 32-bytes, and I assumed that it will be inputed as a base64 encoded string,
if you don't know where to get it, you might get one key from the .env file created by your Laravel project:

APP_KEY=base64:MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDE=

In above sample, you should copy the string after ":", and paste it in my project as sample project.
If you wish to test with your Laravel project, please copy the key from your Laravel project.

Since IV will be created randomly, and will be contained in the JSON payload, we should make sure the keys are identifcal,
then the decryption will be done successfully.

I published this project as Apache License 2.0, you can enjoy to use it in any case. Enjoy your delphi + Laravel cowork.
