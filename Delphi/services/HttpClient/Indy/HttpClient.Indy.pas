unit HttpClient.Indy;

interface

uses
  System.StrUtils,
  System.SysUtils,
  System.Classes,
  HttpClient.Types,
  HttpClient.Interfaces,
  IdHTTP,
  IdSSLOpenSSL,
  IdHeaderList,
  IdException,
  IdStack;

type
  TIndyHttpClient = class(TInterfacedObject, IHttpClient)
  private
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FBaseUrl,
    FEndpoint: string;
    FHeaders: TStringList;
    FTimeout: Integer;

    function BuildUrl(const AResource: string): string;

    procedure ConfigureRequest;
    procedure ApplyHeaders;
    procedure ClearIndyRequestHeaders;

    function ExecuteRequest(const AMethod: THttpMethod;
                            const AUrl: string;
                            const ABody: string): IHttpResponse;
  public
    constructor Create;
    destructor Destroy; override;

    class function New: IHttpClient; static;

    function BaseUrl(const AValue: string): IHttpClient;
    function Endpoint(const AValue: string): IHttpClient;
    function AddHeader(const AName: string;
                       const AValue: string): IHttpClient;
    function RemoveHeader(const AName: string): IHttpClient;
    function BearerToken(const AToken: string): IHttpClient;
    function Timeout(const AValue: Integer): IHttpClient;
    function ClearHeaders: IHttpClient;
    function Execute(const AMethod: THttpMethod;
                     const AResource: string;
                     const ABody: string = ''): IHttpResponse;

    function Get(const AResource: string): IHttpResponse;
    function Post(const AResource: string;
                  const ABody: string): IHttpResponse;
    function Put(const AResource: string;
                 const ABody: string): IHttpResponse;

    function Patch(const AResource: string;
                   const ABody: string): IHttpResponse;
    function Delete(const AResource: string): IHttpResponse;
  end;

implementation

uses
  HttpClient.Response;

{ TIndyHttpClient }

constructor TIndyHttpClient.Create;
begin
  inherited Create;

  FTimeout := 30000;

  FHeaders := TStringList.Create;
  FHeaders.NameValueSeparator := '=';
  FHeaders.CaseSensitive := False;

  FIdHTTP := TIdHTTP.Create(nil);
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FIdHTTP);

  FIdHTTP.IOHandler := FSSLHandler;
  FIdHTTP.HandleRedirects := True;
  FIdHTTP.HTTPOptions := FIdHTTP.HTTPOptions + [hoKeepOrigProtocol];

  FIdHTTP.ConnectTimeout := FTimeout;
  FIdHTTP.ReadTimeout := FTimeout;

  FSSLHandler.SSLOptions.Mode := sslmClient;
  FSSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];

  AddHeader('Accept', 'application/json');
  AddHeader('Content-Type', 'application/json');
end;

destructor TIndyHttpClient.Destroy;
begin
  FreeAndNil(FHeaders);
  FreeAndNil(FIdHTTP);
  FSSLHandler := nil;
  inherited;
end;

class function TIndyHttpClient.New: IHttpClient;
begin
  Result := TIndyHttpClient.Create;
end;

function TIndyHttpClient.BaseUrl(const AValue: string): IHttpClient;
begin
  FBaseUrl := AValue.Trim;
  Result := Self;
end;

function TIndyHttpClient.AddHeader(const AName: string;
                                   const AValue: string): IHttpClient;
var
  LIndex: Integer;
begin
  if AName.Trim.IsEmpty then
    raise EArgumentException.Create('O nome do header não pode ser vazio');

  LIndex := FHeaders.IndexOfName(AName);

  if LIndex >= 0 then
    FHeaders.ValueFromIndex[LIndex] := AValue
  else
    FHeaders.Add(AName + '=' + AValue);

  Result := Self;
end;

function TIndyHttpClient.BearerToken(const AToken: string): IHttpClient;
begin
  AddHeader('Authorization', IfThen(not AToken.Trim.IsEmpty, 'Bearer ' + AToken.Trim));
  Result := Self;
end;

function TIndyHttpClient.Timeout(const AValue: Integer): IHttpClient;
begin
  if AValue <= 0 then
    raise EArgumentOutOfRangeException.Create('O timeout deve ser maior que zero');

  FTimeout := AValue;

  FIdHTTP.ConnectTimeout := FTimeout;
  FIdHTTP.ReadTimeout := FTimeout;

  Result := Self;
end;

function TIndyHttpClient.ClearHeaders: IHttpClient;
begin
  FHeaders.Clear;
  Result := Self;
end;

function TIndyHttpClient.BuildUrl(const AResource: string): string;
var
  LBaseUrl,
  LResource: string;
begin
  LResource := AResource.Trim;

  if LResource.StartsWith('http://') or LResource.StartsWith('https://') then
  begin
    Result := LResource;
    Exit;
  end;

  LBaseUrl := FBaseUrl.Trim;

  if LBaseUrl = '' then
    raise EInvalidOpException.Create('A BaseUrl do cliente HTTP não foi configurada');

  while (Length(LBaseUrl) > 0) and LBaseUrl.EndsWith('/') do
    System.Delete(LBaseUrl, Length(LBaseUrl), 1);

  while (Length(LResource) > 0) and (LResource[1] = '/') do
    System.Delete(LResource, 1, 1);

  Result := LBaseUrl + IfThen(not LResource.IsEmpty, '/' + LResource);
end;

procedure TIndyHttpClient.ClearIndyRequestHeaders;
begin
  FIdHTTP.Request.CustomHeaders.Clear;

  FIdHTTP.Request.Accept := '';
  FIdHTTP.Request.ContentType := '';
  FIdHTTP.Request.UserAgent := '';
end;

procedure TIndyHttpClient.ApplyHeaders;
var
  I: Integer;
  LName,
  LValue: string;
begin
  ClearIndyRequestHeaders;

  for I := 0 to Pred(FHeaders.Count) do
  begin
    LName := FHeaders.Names[I];
    LValue := FHeaders.ValueFromIndex[I];

    if SameText(LName, 'Accept') then
      FIdHTTP.Request.Accept := LValue
    else if SameText(LName, 'Content-Type') then
      FIdHTTP.Request.ContentType := LValue
    else if SameText(LName, 'User-Agent') then
      FIdHTTP.Request.UserAgent := LValue
    else
      FIdHTTP.Request.CustomHeaders.Values[LName] := LValue;
  end;
end;

procedure TIndyHttpClient.ConfigureRequest;
begin
  FIdHTTP.ConnectTimeout := FTimeout;
  FIdHTTP.ReadTimeout := FTimeout;

  ApplyHeaders;
end;

function TIndyHttpClient.ExecuteRequest(const AMethod: THttpMethod;
                                        const AUrl: string;
                                        const ABody: string): IHttpResponse;
var
  LRequestStream,
  LResponseStream: TStringStream;
  LContent: string;
  LStatusCode: Integer;
begin
  LRequestStream := nil;
  LResponseStream := TStringStream.Create('', TEncoding.UTF8);

  try
    ConfigureRequest;

    if (not (AMethod in [hmGet, hmDelete])) and (not ABody.Trim.IsEmpty) then
      LRequestStream := TStringStream.Create(ABody, TEncoding.UTF8);

    try
      case AMethod of
        hmGet    : FIdHTTP.Get(AUrl, LResponseStream);
        hmPost   : FIdHTTP.Post(AUrl, LRequestStream, LResponseStream);
        hmPut    : FIdHTTP.Put(AUrl, LRequestStream, LResponseStream);
        hmPatch  : FIdHTTP.Patch(AUrl, LRequestStream, LResponseStream);
        hmDelete : FIdHTTP.Delete(AUrl, LResponseStream);
      end;

      LStatusCode := FIdHTTP.ResponseCode;
      LContent := LResponseStream.DataString;
    except
      on E: EIdHTTPProtocolException do
      begin
        LStatusCode := E.ErrorCode;
        LContent := E.ErrorMessage;

        if LContent.IsEmpty then
          LContent := LResponseStream.DataString;
      end;

      on E: EIdException do
        raise Exception.CreateFmt('Erro de comunicação HTTP com "%s": %s', [AUrl, E.Message]);

      on E: Exception do
        raise Exception.CreateFmt('Erro ao executar requisição HTTP para "%s": %s', [AUrl, E.Message]);
    end;

    Result := THttpResponse.Create(LStatusCode, LContent);
  finally
    LRequestStream.Free;
    LResponseStream.Free;
  end;
end;

function TIndyHttpClient.Endpoint(const AValue: string): IHttpClient;
begin
  FEndpoint := AValue;
  Result := Self;
end;

function TIndyHttpClient.Execute(const AMethod: THttpMethod;
                                 const AResource: string;
                                 const ABody: string): IHttpResponse;
begin
  Result := ExecuteRequest(AMethod,
                           BuildUrl(AResource),
                           ABody);
end;

function TIndyHttpClient.Get(const AResource: string): IHttpResponse;
begin
  Result := Execute(hmGet, AResource);
end;

function TIndyHttpClient.Post(const AResource: string;
                              const ABody: string): IHttpResponse;
begin
  Result := Execute(hmPost, AResource, ABody);
end;

function TIndyHttpClient.Put(const AResource: string;
                             const ABody: string): IHttpResponse;
begin
  Result := Execute(hmPut, AResource, ABody);
end;

function TIndyHttpClient.RemoveHeader(const AName: string): IHttpClient;
var
  LIndex: Integer;
begin
  LIndex := FHeaders.IndexOfName(AName);

  if LIndex >= 0 then
    FHeaders.Delete(LIndex);

  Result := Self;
end;

function TIndyHttpClient.Patch(const AResource: string;
                               const ABody: string): IHttpResponse;
begin
  Result := Execute(hmPatch, AResource, ABody);
end;

function TIndyHttpClient.Delete(const AResource: string): IHttpResponse;
begin
  Result := Execute(hmDelete, AResource);
end;

end.
