unit ProdutoController;

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
  TProdutoController = class
  private
    FBaseUrl: string;
    FApiClient: IFinanceiroApiClient;
  public
    constructor Create(const ABaseUrl: string = 'https://localhost:7263');

    function Listar: TObjectList<TFinanceiroProdutoDTO>;
    function ObterPorId(const AId: Integer): TFinanceiroProdutoDTO;
    function Criar(const AJson: string): TFinanceiroProdutoDTO;
    function Atualizar(const AJson: string): TFinanceiroProdutoDTO;
    function Excluir(const AId: Integer): Boolean;
  end;

implementation

{ TProdutoController }

constructor TProdutoController.Create(const ABaseUrl: string = 'https://localhost:7263');
begin
  inherited Create;

  FBaseUrl := ABaseUrl.Trim;
  if FBaseUrl.IsEmpty then
    FBaseUrl := 'https://localhost:7263';

  FApiClient := TFinanceiroApiClient.New(TIndyHttpClient.New, FBaseUrl);
end;

function TProdutoController.Listar: TObjectList<TFinanceiroProdutoDTO>;
begin
  Result := FApiClient.ProdutoListar;
end;

function TProdutoController.ObterPorId(const AId: Integer): TFinanceiroProdutoDTO;
begin
  Result := FApiClient.ProdutoObterPorId(AId);
end;

function TProdutoController.Criar(const AJson: string): TFinanceiroProdutoDTO;
begin
  Result := FApiClient.ProdutoCriar(AJson);
end;

function TProdutoController.Atualizar(const AJson: string): TFinanceiroProdutoDTO;
begin
  Result := FApiClient.ProdutoAtualizar(AJson);
end;

function TProdutoController.Excluir(const AId: Integer): Boolean;
begin
  Result := FApiClient.ProdutoExcluir(AId);
end;

end.
