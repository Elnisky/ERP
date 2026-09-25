unit VendaController;

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
  TVendaController = class
  private
    FBaseUrl: string;
    FApiClient: IFinanceiroApiClient;
  public
    constructor Create(const ABaseUrl: string = 'https://localhost:7263');

    function Listar: TObjectList<TFinanceiroVendaDTO>;
    function ObterPorId(const AId: Integer): TFinanceiroVendaDTO;
    function ListarItens(const AVendaId: Integer): TObjectList<TFinanceiroVendaItemDTO>;
    function Criar(const AJson: string): TFinanceiroVendaDTO;
    function Atualizar(const AJson: string): TFinanceiroVendaDTO;
    function Excluir(const AId: Integer): Boolean;
    function ItemAdicionar(const AVendaId: Integer; const AJson: string): TFinanceiroVendaItemDTO;
    function ItemAtualizar(const AJson: string): TFinanceiroVendaItemDTO;
    function ItemExcluir(const AId: Integer): Boolean;
  end;

implementation

{ TVendaController }

constructor TVendaController.Create(const ABaseUrl: string = 'https://localhost:7263');
begin
  inherited Create;

  FBaseUrl := ABaseUrl.Trim;
  if FBaseUrl.IsEmpty then
    FBaseUrl := 'https://localhost:7263';

  FApiClient := TFinanceiroApiClient.New(TIndyHttpClient.New, FBaseUrl);
end;

function TVendaController.Listar: TObjectList<TFinanceiroVendaDTO>;
begin
  Result := FApiClient.VendaListar;
end;

function TVendaController.ObterPorId(const AId: Integer): TFinanceiroVendaDTO;
begin
  Result := FApiClient.VendaObterPorId(AId);
end;

function TVendaController.ListarItens(const AVendaId: Integer): TObjectList<TFinanceiroVendaItemDTO>;
begin
  Result := FApiClient.VendaItensListar(AVendaId);
end;

function TVendaController.Criar(const AJson: string): TFinanceiroVendaDTO;
begin
  Result := FApiClient.VendaCriar(AJson);
end;

function TVendaController.Atualizar(const AJson: string): TFinanceiroVendaDTO;
begin
  Result := FApiClient.VendaAtualizar(AJson);
end;

function TVendaController.Excluir(const AId: Integer): Boolean;
begin
  Result := FApiClient.VendaExcluir(AId);
end;

function TVendaController.ItemAdicionar(const AVendaId: Integer; const AJson: string): TFinanceiroVendaItemDTO;
begin
  Result := FApiClient.VendaItemAdicionar(AVendaId, AJson);
end;

function TVendaController.ItemAtualizar(const AJson: string): TFinanceiroVendaItemDTO;
begin
  Result := FApiClient.VendaItemAtualizar(AJson);
end;

function TVendaController.ItemExcluir(const AId: Integer): Boolean;
begin
  Result := FApiClient.VendaItemExcluir(AId);
end;

end.
