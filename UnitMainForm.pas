unit UnitMainForm;

interface

uses
   System.SysUtils, System.Types, System.UITypes, System.Classes,
   System.Variants,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
   FMX.Controls.Presentation, FMX.Edit, FMX.Objects, System.JSON,

   // Units you need to use to enable the encryption and hmac function.
   System.Hash, DECFormat, DECCipherBase, DECFormatBase, DECCipherModes,
   DECUtil, DECCipherFormats;

type
   TForm2 = class(TForm)
      Rectangle1: TRectangle;
      TextCipherSample: TText;
      Rectangle2: TRectangle;
      TextKey: TText;
      Text1: TText;
      EditKey: TEdit;
      Rectangle3: TRectangle;
      TextIV: TText;
      EditIV: TEdit;
      Rectangle4: TRectangle;
      TextPlainText: TText;
      EditPlain: TEdit;
      Rectangle5: TRectangle;
      TextBase64edCipher: TText;
      EditCipher: TEdit;
      btnEncrypt: TButton;
      btnDecrypt: TButton;
      procedure btnEncryptClick(Sender: TObject);
      procedure btnDecryptClick(Sender: TObject);
   private
      { Private declarations }
   protected
      function randomBytes(size: integer): TBytes;
      function genRandomIv(size: integer): TBytes;
      function generateAES256CBCForPHPCipher(base64Key: string;
          plainData: string): string;
   public
      { Public declarations }
   end;

var
   Form2: TForm2;

implementation

{$R *.fmx}
{ TForm2 }

procedure TForm2.btnDecryptClick(Sender: TObject);
var
   base64PHPAESCipher: String;
   FillerByte: Byte;
   FillerChar: Char;
   initVector: TBytes;
   Cipher: TDECCipherModes;
   InputBuffer: TBytes;
   OutputBuffer: TBytes;
   InputBufferSize: integer;
   paddingSize: integer;
   paddingCount: integer;
   base64Cipher, base64IV, hMacSrcString, hMacResult, jsonStr: string;
   sha256: THashSHA2;
   OutputString: String;
   CipherTextBuffer, PlainTextBuffer: TBytes;
   jsonObj: TJSONObject;

   function genAES256CBCCipher: TDECCipherModes;
   var
      buffer: TBytes;
   begin
      Result := TDECCipher.ClassByName('TCipher_AES256')
          .Create as TDECCipherModes;
      Result.Mode := cmCBCx;
   end;

begin
   if (TFormat_Base64.IsValid(EditKey.Text)) then begin
      Cipher := genAES256CBCCipher;
      try
         jsonStr := TFormat_Base64.Decode(EditCipher.Text);
         jsonObj := TJSONObject.ParseJSONValue(jsonStr) as TJSONObject;

         CipherTextBuffer := System.SysUtils.BytesOf
             (TFormat_Base64.Decode(jsonObj.GetValue<String>('value')));

         FillerByte := $0;
         Cipher.Init(System.SysUtils.BytesOf(TFormat_Base64.Decode(self.EditKey.Text)),
            System.SysUtils.BytesOf(TFormat_Base64.Decode(jsonObj.GetValue<String>('iv'))),
            FillerByte
         );

         PlainTextBuffer := (Cipher as TDECFormattedCipher)
             .DecodeBytes(CipherTextBuffer);
         (Cipher as TDECFormattedCipher).Done;
         EditPlain.Text := string(DECUtil.BytesToRawString(PlainTextBuffer));
      finally
         Cipher.Free;
      end;
   end
   else begin
      ShowMessage('The key is not base64 format, please check it');
   end;
end;

procedure TForm2.btnEncryptClick(Sender: TObject);
var
   base64PHPAESCipher: String;

   function genAES256CBCCipher: TDECCipherModes;
   var
      buffer: TBytes;
   begin
      Result := TDECCipher.ClassByName('TCipher_AES256')
          .Create as TDECCipherModes;
      Result.Mode := cmCBCx;
   end;

begin
   base64PHPAESCipher := self.generateAES256CBCForPHPCipher(EditKey.Text,
       EditPlain.Text);
   self.EditCipher.Text := base64PHPAESCipher;
end;

function TForm2.generateAES256CBCForPHPCipher(base64Key,
    plainData: string): string;
var
   FillerByte: Byte;
   FillerChar: Char;
   initVector: TBytes;
   Cipher: TDECCipherModes;
   InputBuffer: TBytes;
   OutputBuffer: TBytes;
   InputBufferSize: integer;
   paddingSize: integer;
   paddingCount: integer;
   base64Cipher, base64IV, hMacSrcString, hMacResult, jsonStr: string;
   sha256: THashSHA2;
   OutputString: String;

   function genAES256CBCCipher: TDECCipherModes;
   var
      buffer: TBytes;
   begin
      Result := TDECCipher.ClassByName('TCipher_AES256')
          .Create as TDECCipherModes;
      Result.Mode := cmCBCx;
   end;

begin
   if (TFormat_Base64.IsValid(base64Key)) then begin
      Cipher := genAES256CBCCipher;
      initVector := self.genRandomIv(Cipher.InitVectorSize);
      self.EditIV.Text := TFormat_Base64.Encode(RawByteString(initVector));

      InputBuffer := System.SysUtils.BytesOf(plainData);
      InputBufferSize := Length(InputBuffer);
      paddingSize := InputBufferSize mod Cipher.InitVectorSize;
      paddingSize := Cipher.InitVectorSize - paddingSize;
      FillerChar := Chr(paddingSize);
      FillerByte := Byte(paddingSize);

      Cipher.Init(System.SysUtils.BytesOf(TFormat_Base64.Decode(base64Key)),
          System.SysUtils.BytesOf(BytesToRawString(initVector)), FillerByte);

      if (paddingSize <> 0) then begin
         for paddingCount := 1 to paddingSize do begin
            InputBuffer := InputBuffer + System.SysUtils.BytesOf(FillerChar);
         end;
      end;

      OutputBuffer := (Cipher as TDECFormattedCipher).EncodeBytes(InputBuffer);
      (Cipher as TDECFormattedCipher).Done;

      base64Cipher := TFormat_Base64.Encode(RawByteString(OutputBuffer));
      base64IV := TFormat_Base64.Encode(RawByteString(initVector));

      hMacSrcString := base64IV + base64Cipher;
      sha256 := THashSHA2.Create();
      hMacResult := sha256.GetHMAC(hMacSrcString,
          TFormat_Base64.Decode(base64Key));

      jsonStr := '{"iv":"' + base64IV + '",' + '"value":"' + base64Cipher +
          '","mac":"' + hMacResult + '","tag":""}';

      Result := TFormat_Base64.Encode(RawByteString(jsonStr));
   end
   else begin
      ShowMessage('The key is not base64 format, please check it');
   end;

   // Dispose created data;
   setLength(initVector, 0);
end;

function TForm2.genRandomIv(size: integer): TBytes;
begin
   Result := self.randomBytes(size);
end;

function TForm2.randomBytes(size: integer): TBytes;
var
   count: integer;
   tmpInt: Int16;
   tmpBytes: TBytes;
begin
   randomize();
   for count := 1 to size do begin
      repeat
         tmpInt := random(127);
      until tmpInt > 0;
      setLength(tmpBytes, 1);
      tmpBytes[0] := Byte(tmpInt);
      Result := Result + tmpBytes;
   end;
end;

end.
