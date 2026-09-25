unit HttpClient.Interfaces;

interface

uses
  HttpClient.Types,
  System.JSON;

type
  IHttpResponse = interface
    ['{8DB7A821-FC54-4A50-866F-33BA0471068C}']
    function StatusCode: Integer;
    function Content: string;
    function JsonValue: TJSONValue;
  end;

  IHttpClient = interface
    ['{03785872-B9CF-4D52-95AE-678F5539D41C}']
    function BaseUrl(const AValue: string): IHttpClient;
    function Endpoint(const AValue: string): IHttpClient;
    function AddHeader(const AName,
                       AValue: string): IHttpClient;
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

end.
