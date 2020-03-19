unit UMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, uMyMQTTComps,
  uMyMQTT;

type
  TfrmMain = class(TForm)
    tbTop: TToolBar;
    edUrl: TEdit;
    btnDownload: TButton;
    mmoDebug: TMemo;
    icImageControl: TImageControl;
    tbBottom: TToolBar;
    btnDate: TButton;
    edDate: TEdit;
    MyMQTTClient1: TMyMQTTClient;
    procedure btnDownloadClick(Sender: TObject);
    procedure btnDateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure HTTPCheck;
    procedure Log(const s: string);
    procedure httpCheck2;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  blcksock,
  ssl_openssl,
  synautil,
  synsock,
  httpsend,
  sntpsend,
  ftpsend,
  pop3send;

{$R *.fmx}

procedure TfrmMain.btnDownloadClick(Sender: TObject);
begin
httpCheck2
//  HTTPCheck;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
 MyMQTTClient1.Connect;
 if MyMQTTClient1.Connected then
   MyMQTTClient1.Subscribe('/aaa/bbb', qtAT_MOST_ONCE);

end;

procedure TfrmMain.btnDateClick(Sender: TObject);
var
  ntp: TSNtpSend;
begin
  ntp := TSNtpSend.Create;
  try
    ntp.TargetHost := 'pool.ntp.org';
    ntp.getsntp;
    edDate.Text := datetimeToStr(ntp.ntptime);
  finally
    ntp.Free;
  end;

end;

procedure TfrmMain.HTTPCheck;
var
  ls: TStringList;
  stream: TMemoryStream;
  ss: TStringStream;
begin
  ls := TStringList.Create;
  stream := TMemoryStream.Create;
  try
    Log('Synapse from Delphi');
    HttpGetText(edUrl.Text, ls);
    Log(ls.Text);

    Log('Text size (expected 217, maybe crlf different): ' +
      IntToStr(Length(ls.Text)));

//    HttpGetBinary('http://delphi.cz/img/Delphi_Certified_Dev.png', stream);
    HttpPostURL(edurl.Text, '', stream);
    ss:= TStringStream.Create;
    stream.Position := 0;
    ss.CopyFrom(stream, stream.Size);
    mmodebug.Text := ss.DataString;
    exit;
    Log('Stream size (expected 44 791): ' + IntToStr(stream.Size));
    stream.Position := 0;
    icImageControl.Bitmap.CreateFromStream(stream);

  finally
    ls.Free;
    stream.Free;
  end;
end;

procedure TfrmMain.httpCheck2;
var
  HTTP: THTTPSend;
  ss: TStringStream;
begin
  HTTP := THTTPSend.Create;
  ss:= TStringStream.Create;
  try
    WriteStrToStream(HTTP.Document, '');
    HTTP.MimeType := 'application/x-www-form-urlencoded';
    HTTP.Sock.CreateWithSSL(TSSLOpenSSL);
    HTTP.Sock.SSLDoConnect;
    if HTTP.HTTPMethod('POST', edurl.Text) then
    begin
     showmessage('ok');
      ss.CopyFrom(HTTP.Document, 0);
      mmodebug.Text := ss.DataString;
    end else
      showmessage(http.Sock.LastErrorDesc);
  finally
    HTTP.Free;
  end;

end;

procedure TfrmMain.Log(const s: string);
begin
  mmoDebug.Lines.Add(s);
end;

end.
