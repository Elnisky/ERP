unit HttpClient.Response;

interface

uses
  System.SysUtils,
  System.JSON,
  HttpClient.Interfaces;

type
  THttpResponse = class(TInterfacedObject, IHttpResponse)
  private
    FStatusCode: Integer;
    FContent: string;
    FContentBytes: TBytes;
    FJsonValue: TJSONValue;

    procedure ParseJson;
  public
    constructor Create(const AStatusCode: Integer;
                       const AContent: string;
                       const AContentBytes: TBytes = nil);
    destructor Destroy; override;

    function StatusCode: Integer;
    function Content: string;
    function ContentBytes: TBytes;
    function JsonValue: TJSONValue;
  end;

implementation

{ THttpResponse }

constructor THttpResponse.Create(const AStatusCode: Integer;
                                 const AContent: string;
                                 const AContentBytes: TBytes = nil);
begin
  inherited Create;

  FStatusCode := AStatusCode;
  FContent := AContent;
  FContentBytes := AContentBytes;

  if Length(FContentBytes) = 0 then
    FContentBytes := TEncoding.UTF8.GetBytes(FContent);

  FJsonValue := nil;

  ParseJson;
end;

destructor THttpResponse.Destroy;
begin
  FreeAndNil(FJsonValue);
  inherited;
end;

procedure THttpResponse.ParseJson;
begin
  if Trim(FContent) = '' then
    Exit;

  try
    FJsonValue := TJSONObject.ParseJSONValue(FContent);
  except
    FreeAndNil(FJsonValue);
  end;
end;

function THttpResponse.StatusCode: Integer;
begin
  Result := FStatusCode;
end;

function THttpResponse.Content: string;
begin
  Result := FContent;
end;

function THttpResponse.ContentBytes: TBytes;
begin
  Result := FContentBytes;
end;

function THttpResponse.JsonValue: TJSONValue;
begin
  Result := FJsonValue;
end;

end.
