unit Financeiro.Exceptions;

interface

uses
  System.SysUtils;

type
  EFinanceiroApiException = class(Exception)
  private
    FStatusCode: Integer;
    FResponseContent: string;
  public
    constructor Create(const AMessage: string;
                       const AStatusCode: Integer;
                       const AResponseContent: string);

    property StatusCode: Integer read FStatusCode;
    property ResponseContent: string read FResponseContent;
  end;

implementation

constructor EFinanceiroApiException.Create(const AMessage: string;
                                          const AStatusCode: Integer;
                                          const AResponseContent: string);
begin
  inherited Create(AMessage);
  FStatusCode := AStatusCode;
  FResponseContent := AResponseContent;
end;

end.
