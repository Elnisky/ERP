unit Financeiro.DTO.Interfaces;

interface

type
  IFinanceiroClienteDTO = interface
    ['{1C7D6B80-FBC3-49D7-8E98-B712FA8B1D33}']
    function GetId: Integer;
    function GetNome: string;
    function GetCpf: string;
    function GetEmail: string;
    function GetTelefone: string;
    property Id: Integer read GetId;
    property Nome: string read GetNome;
    property Cpf: string read GetCpf;
    property Email: string read GetEmail;
    property Telefone: string read GetTelefone;
  end;

  IFinanceiroProdutoDTO = interface
    ['{D9E86406-8B90-4E77-9F19-09A6580A165B}']
    function GetId: Integer;
    function GetNome: string;
    function GetPreco: Double;
    function GetQuantidadeEstoque: Integer;
    property Id: Integer read GetId;
    property Nome: string read GetNome;
    property Preco: Double read GetPreco;
    property QuantidadeEstoque: Integer read GetQuantidadeEstoque;
  end;

  IFinanceiroPagamentoDTO = interface
    ['{22B21B4E-98AF-4E17-B65E-4E983D87B0F7}']
    function GetId: Integer;
    function GetVendaId: Integer;
    function GetValor: Double;
    function GetTipo: Integer;
    function GetStatus: Integer;
    function GetCompletedAt: string;
    function GetTransacaoId: string;
    property Id: Integer read GetId;
    property VendaId: Integer read GetVendaId;
    property Valor: Double read GetValor;
    property Tipo: Integer read GetTipo;
    property Status: Integer read GetStatus;
    property CompletedAt: string read GetCompletedAt;
    property TransacaoId: string read GetTransacaoId;
  end;

  IFinanceiroVendaItemDTO = interface
    ['{CA2A5F93-5B2A-41AF-A2E7-2A35C38A888C}']
    function GetId: Integer;
    function GetVendaId: Integer;
    function GetProdutoId: Integer;
    function GetQuantidade: Integer;
    function GetValorUnitario: Double;
    property Id: Integer read GetId;
    property VendaId: Integer read GetVendaId;
    property ProdutoId: Integer read GetProdutoId;
    property Quantidade: Integer read GetQuantidade;
    property ValorUnitario: Double read GetValorUnitario;
  end;

  IFinanceiroVendaDTO = interface
    ['{07343D9D-A83B-4D2A-8CB3-101A024EDB5B}']
    function GetId: Integer;
    function GetClienteId: Integer;
    function GetStatus: Integer;
    function GetPagoEm: string;
    property Id: Integer read GetId;
    property ClienteId: Integer read GetClienteId;
    property Status: Integer read GetStatus;
    property PagoEm: string read GetPagoEm;
  end;

implementation

end.
