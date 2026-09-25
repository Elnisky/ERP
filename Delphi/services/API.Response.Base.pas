unit API.Response.Base;

interface

uses
  System.JSON,
  System.StrUtils,
  System.SysUtils;

type
  TApiResponseBase = class(TInterfacedObject)
  protected
    class function GetJson(const AJsonObject: TJSONObject;
                           const AName: string;
                           const ADefault: string = ''): string; overload; static;

    class function GetJson(const AJsonObject: TJSONObject;
                           const AName: string;
                           const ADefault: Boolean = False): Boolean; overload; static;

    procedure LoadFromJsonObject(const AJsonObject: TJSONObject); virtual; abstract;
  end;

  TApiResponseFactory = class
  public
    class function FromJson<T: TApiResponseBase, constructor>(const AContent: string): T; static;
  end;

implementation

{ TApiResponseFactory }

class function TApiResponseFactory.FromJson<T>(const AContent: string): T;
var
  LJsonValue: TJSONValue;
begin
  if AContent.Trim.IsEmpty then
    raise EConvertError.Create('A resposta está vazia');

  LJsonValue := TJSONObject.ParseJSONValue(AContent);

  if not Assigned(LJsonValue) then
    raise EConvertError.Create('JSON inválido');

  try
    if not (LJsonValue is TJSONObject) then
      raise EConvertError.Create('A resposta não é um objeto JSON');

    Result := T.Create;

    try
      Result.LoadFromJsonObject(TJSONObject(LJsonValue));
    except
      Result.Free;
      raise;
    end;
  finally
    LJsonValue.Free;
  end;
end;

{ TApiResponseBase }

class function TApiResponseBase.GetJson(const AJsonObject: TJSONObject;
                                        const AName: string;
                                        const ADefault: string): string;
var
  LJsonValue: TJSONValue;
begin
  Result := ADefault;

  if not Assigned(AJsonObject) then
    Exit;

  LJsonValue := AJsonObject.GetValue(AName);

  if not Assigned(LJsonValue) then
    Exit;

  if LJsonValue is TJSONNull then
    Exit;

  Result := LJsonValue.Value;
end;

class function TApiResponseBase.GetJson(const AJsonObject: TJSONObject;
                                        const AName: string;
                                        const ADefault: Boolean): Boolean;
var
  LValue: string;
begin
  Result := ADefault;

  LValue := GetJson(AJsonObject,
                    AName,
                    EmptyStr).Trim.ToLower;

  if LValue.IsEmpty then
    Exit;

  if MatchStr(LValue, ['true', '1', 'sim']) then
    Exit(True);

  if MatchStr(LValue, ['false', '0', 'nao', 'não']) then
    Exit(False);

  raise EConvertError.CreateFmt('O campo JSON "%s" contém um valor booleano inválido: %s', [AName, LValue]);
end;

end.
