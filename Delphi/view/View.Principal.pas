unit View.Principal;

interface

uses
  System.Classes,
  System.ImageList,
  System.SysUtils,
  System.Variants,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.WinXCtrls,
  Winapi.Windows,
  Winapi.Messages;

type
  TfrmPrincipal = class(TForm)
    svMenu: TSplitView;
    cpgMenu: TCategoryPanelGroup;
    pnlMenu: TPanel;
    btnMenu: TButton;
    imlImages: TImageList;
    pnlCadastroCliente: TCategoryPanel;
    btnListarCliente: TButton;
    btnExcluirCliente: TButton;
    btnEditarCliente: TButton;
    btnIncluirCliente: TButton;
    pnlCadastroProduto: TCategoryPanel;
    btnListarProduto: TButton;
    btnExcluirProduto: TButton;
    btnEditarProduto: TButton;
    btnIncluirProduto: TButton;
    pnlCadastroVenda: TCategoryPanel;
    btnListarVenda: TButton;
    btnExcluirVenda: TButton;
    btnEditarVenda: TButton;
    btnIncluirVenda: TButton;
    btnPagarVenda: TButton;
    procedure btnMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnListarClienteClick(Sender: TObject);
    procedure btnIncluirClienteClick(Sender: TObject);
    procedure btnEditarClienteClick(Sender: TObject);
    procedure btnExcluirClienteClick(Sender: TObject);
    procedure btnIncluirVendaClick(Sender: TObject);
  private
    FForm: TForm;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  View.Cadastro.Cliente,
  View.Cadastro.Produto,
  View.Cadastro.Venda,
  View.Listagem.Cliente,
  View.Listagem.Produto,
  View.Listagem.Venda;

{$R *.dfm}

procedure TfrmPrincipal.btnEditarClienteClick(Sender: TObject);
begin
  if Assigned(FForm) then
  begin
    Tag := FForm.Tag;
    FreeAndNil(FForm);
  end
  else
    raise Exception.Create('Realize uma consulta primeiro!');

  if Trim(TButton(Sender).Name).EndsWith('Cliente') then
    FForm := TfrmCadCliente.Create(nil)
  else
    FForm := TfrmCadProduto.Create(nil);

  try
    FForm.Tag := Tag;
    FForm.ShowModal;
  finally
    btnMenu.Click;
  end;
end;

procedure TfrmPrincipal.btnExcluirClienteClick(Sender: TObject);
begin
  if Assigned(FForm) then
  begin
    Tag := FForm.Tag;
    FreeAndNil(FForm);
  end
  else
    raise Exception.Create('Realize uma consulta primeiro!');

  if Trim(TButton(Sender).Name).EndsWith('Cliente') then
    FForm := TfrmCadCliente.Create(nil)
  else
    FForm := TfrmCadProduto.Create(nil);

  try
    TfrmCadCliente(FForm).Excluir(Tag);
  finally
    btnMenu.Click;
  end;
end;

procedure TfrmPrincipal.btnIncluirClienteClick(Sender: TObject);
begin
  if Assigned(FForm) then
    FreeAndNil(FForm);
  if Trim(TButton(Sender).Name).EndsWith('Cliente') then
    FForm := TfrmCadCliente.Create(nil)
  else
    FForm := TfrmCadProduto.Create(nil);

  try
    FForm.ShowModal;
  finally
    btnMenu.Click;
  end;
end;

procedure TfrmPrincipal.btnIncluirVendaClick(Sender: TObject);
begin
  if Assigned(FForm) then
    FreeAndNil(FForm);

  FForm := TfrmCadVenda.Create(nil);
  try
    FForm.ShowModal;
  finally
    btnMenu.Click;
  end;
end;

procedure TfrmPrincipal.btnListarClienteClick(Sender: TObject);
begin
  if Assigned(FForm) then
    FreeAndNil(FForm);

  if Trim(TButton(Sender).Name).EndsWith('Cliente') then
    FForm := TfrmListagemCliente.Create(nil)
  else if Trim(TButton(Sender).Name).EndsWith('Produto') then
    FForm := TfrmProdutoListagem.Create(nil)
  else
    FForm := TfrmListagemVenda.Create(nil);

  try
    FForm.Parent := Self;
    FForm.Align := alClient;
    FForm.Show;
  finally
    btnMenu.Click;
  end;
end;

procedure TfrmPrincipal.btnMenuClick(Sender: TObject);
begin
  svMenu.Opened := not svMenu.Opened;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  svMenu.Opened := False;
end;

end.
