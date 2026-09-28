unit Financeiro.Interfaces;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  Financeiro.DTOs;

type
  IFinanceiroApiClient = interface
    ['{2197B6C1-3E3B-4DF0-A1C2-2016A73D6F45}']
    function ClienteListar: TObjectList<TFinanceiroClienteDTO>;
    function ClienteObterPorId(const AId: Integer): TFinanceiroClienteDTO;
    function ClienteCriar(const AJson: string): TFinanceiroClienteDTO;
    function ClienteAtualizar(const AJson: string): TFinanceiroClienteDTO;
    function ClienteExcluir(const AId: Integer): Boolean;

    function ProdutoListar: TObjectList<TFinanceiroProdutoDTO>;
    function ProdutoObterPorId(const AId: Integer): TFinanceiroProdutoDTO;
    function ProdutoCriar(const AJson: string): TFinanceiroProdutoDTO;
    function ProdutoAtualizar(const AJson: string): TFinanceiroProdutoDTO;
    function ProdutoExcluir(const AId: Integer): Boolean;

    function PagamentoListar: TObjectList<TFinanceiroPagamentoDTO>;
    function PagamentoObterPorId(const AId: Integer): TFinanceiroPagamentoDTO;
    function PagamentoCriar(const AJson: string): TFinanceiroPagamentoDTO;
    function PagamentoAtualizar(const AJson: string): TFinanceiroPagamentoDTO;
    function PagamentoExcluir(const AId: Integer): Boolean;

    function VendaListar: TObjectList<TFinanceiroVendaDTO>;
    function VendaObterPorId(const AId: Integer): TFinanceiroVendaDTO;
    function VendaCriar(const AJson: string): TFinanceiroVendaDTO;
    function VendaAtualizar(const AJson: string): TFinanceiroVendaDTO;
    function VendaExcluir(const AId: Integer): Boolean;
    function VendaConfirmacaoPdf(const AId: Integer): TBytes;
    function VendaItensListar(const AVendaId: Integer): TObjectList<TFinanceiroVendaItemDTO>;
    function VendaItemAdicionar(const AVendaId: Integer; const AJson: string): TFinanceiroVendaItemDTO;
    function VendaItemAtualizar(const AJson: string): TFinanceiroVendaItemDTO;
    function VendaItemExcluir(const AId: Integer): Boolean;
  end;

implementation

end.
