program AvaliacaoCartSys;

uses
  Vcl.Forms,
  View.Principal in 'view\View.Principal.pas' {frmPrincipal},
  View.Base.Listagem in 'view\View.Base.Listagem.pas' {frmBaseListagem},
  View.Listagem.Cliente in 'view\View.Listagem.Cliente.pas' {frmListagemCliente},
  API.Response.Base in 'services\API.Response.Base.pas',
  HttpClient.Indy in 'services\HttpClient\Indy\HttpClient.Indy.pas',
  HttpClient.Response in 'services\HttpClient\Indy\HttpClient.Response.pas',
  HttpClient.Interfaces in 'services\HttpClient\Contracts\HttpClient.Interfaces.pas',
  HttpClient.Types in 'services\HttpClient\Contracts\HttpClient.Types.pas',
  ClienteController in 'controller\ClienteController.pas',
  Financeiro.Interfaces in 'services\API\Contracts\Financeiro.Interfaces.pas',
  Financeiro.DTO.Interfaces in 'services\API\DTOs\Financeiro.DTO.Interfaces.pas',
  Financeiro.DTOs in 'services\API\DTOs\Financeiro.DTOs.pas',
  Financeiro.Exceptions in 'services\API\Exceptions\Financeiro.Exceptions.pas',
  Financeiro.Client in 'services\API\Financeiro.Client.pas',
  View.Listagem.Produto in 'view\View.Listagem.Produto.pas' {frmProdutoListagem},
  ProdutoController in 'controller\ProdutoController.pas',
  View.Base.Cadastro in 'view\View.Base.Cadastro.pas' {frmBaseCadastro},
  View.Cadastro.Cliente in 'view\View.Cadastro.Cliente.pas' {frmCadCliente},
  View.Cadastro.Produto in 'view\View.Cadastro.Produto.pas' {frmCadProduto},
  View.Listagem.Venda in 'view\View.Listagem.Venda.pas' {frmListagemVenda},
  VendaController in 'controller\VendaController.pas',
  View.Cadastro.Venda in 'view\View.Cadastro.Venda.pas' {frmCadVenda};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmCadVenda, frmCadVenda);
  Application.Run;
end.
