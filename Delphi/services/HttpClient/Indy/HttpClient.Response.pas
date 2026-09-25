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
    FJsonValue: TJSONValue;

    procedure ParseJson;
  public
    constructor Create(const AStatusCode: Integer;
                       const AContent: string);
    destructor Destroy; override;

    function StatusCode: Integer;
    function Content: string;
    function JsonValue: TJSONValue;
  end;

implementation

{ THttpResponse }

constructor THttpResponse.Create(const AStatusCode: Integer;
                                 const AContent: string);
begin
  inherited Create;

  FStatusCode := AStatusCode;
  FContent := AContent;
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

function THttpResponse.JsonValue: TJSONValue;
begin
  Result := FJsonValue;
end;

end.
