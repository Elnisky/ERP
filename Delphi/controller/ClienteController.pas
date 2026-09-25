unit ClienteController;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Financeiro.Client,
  Financeiro.DTOs,
  Financeiro.Interfaces,
  HttpClient.Indy;

type
  TClienteController = class
  private
    FBaseUrl: string;
    FApiClient: IFinanceiroApiClient;
  public
    constructor Create(const ABaseUrl: string = 'https://localhost:7263');

    function Listar: TObjectList<TFinanceiroClienteDTO>;
    function ObterPorId(const AId: Integer): TFinanceiroClienteDTO;
    function Criar(const AJson: string): TFinanceiroClienteDTO;
    function Atualizar(const AJson: string): TFinanceiroClienteDTO;
    function Excluir(const AId: Integer): Boolean;
  end;

implementation

{ TClienteController }

constructor TClienteController.Create(const ABaseUrl: string = 'https://localhost:7263');
begin
  inherited Create;

  FBaseUrl := ABaseUrl.Trim;
  if FBaseUrl.IsEmpty then
    FBaseUrl := 'https://localhost:7263';

  FApiClient := TFinanceiroApiClient.New(TIndyHttpClient.New, FBaseUrl);
end;

function TClienteController.Listar: TObjectList<TFinanceiroClienteDTO>;
begin
  Result := FApiClient.ClienteListar;
end;

function TClienteController.ObterPorId(const AId: Integer): TFinanceiroClienteDTO;
begin
  Result := FApiClient.ClienteObterPorId(AId);
end;

function TClienteController.Criar(const AJson: string): TFinanceiroClienteDTO;
begin
  Result := FApiClient.ClienteCriar(AJson);
end;

function TClienteController.Atualizar(const AJson: string): TFinanceiroClienteDTO;
begin
  Result := FApiClient.ClienteAtualizar(AJson);
end;

function TClienteController.Excluir(const AId: Integer): Boolean;
begin
  Result := FApiClient.ClienteExcluir(AId);
end;

end.
