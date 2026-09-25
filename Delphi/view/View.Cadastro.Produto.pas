unit View.Cadastro.Produto;

interface

uses
  Data.DB,
  Datasnap.DBClient,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Variants,
  Vcl.Controls,
  Vcl.DBCtrls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.StdCtrls,
  View.Base.Cadastro,
  ProdutoController,
  Financeiro.DTOs,
  Winapi.Messages,
  Winapi.Windows;

type
  TfrmCadProduto = class(TfrmBaseCadastro)
    procedure FormShow(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
  private
    FController: TProdutoController;
    procedure InicializarCDS;
    procedure LocalizarProduto;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Excluir(const AId: Integer);
  end;

var
  frmCadProduto: TfrmCadProduto;

implementation

{$R *.dfm}

{ TfrmCadastroProduto }

procedure TfrmCadProduto.btnConfirmarClick(Sender: TObject);
var
  LJson: string;
  LProduto: TFinanceiroProdutoDTO;
begin
  inherited;
  try
    if Trim(DBLabeledEdit1.Text).IsEmpty then
      raise Exception.Create('Informe o nome do produto.');

    if Trim(DBLabeledEdit2.Text).IsEmpty then
      raise Exception.Create('Informe o preço unitário do produto.');

    if Trim(DBLabeledEdit3.Text).IsEmpty then
      raise Exception.Create('Informe o total em estoque do produto.');

    LJson := TFinanceiroProdutoDTO.GetJson(Trim(DBLabeledEdit1.Text),
                                           Trim(DBLabeledEdit2.Text),
                                           Trim(DBLabeledEdit3.Text),
                                           Tag.ToString);
    if Tag = 0 then
      LProduto := FController.Criar(LJson)
    else
      LProduto := FController.Atualizar(LJson);

    try
      if Assigned(LProduto) then
      begin
        ShowMessage(Format('Produto %s com sucesso!', [IfThen(Tag = 0, 'cadastrado', 'alterado')]));
        ModalResult := mrOk;
        Close;
      end;
    finally
      LProduto.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao cadastrar produto: ' + E.Message);
  end;
end;

constructor TfrmCadProduto.Create(AOwner: TComponent);
begin
  inherited;
  FController := TProdutoController.Create;
  InicializarCDS;
end;

destructor TfrmCadProduto.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TfrmCadProduto.Excluir(const AId: Integer);
begin
  if FController.Excluir(AId) then
    ShowMessage('Cliente excluido com sucesso!');
end;

procedure TfrmCadProduto.FormShow(Sender: TObject);
begin
  inherited;
  if Tag > 0 then
    LocalizarProduto;
end;

procedure TfrmCadProduto.InicializarCDS;
begin
  cdsCadastro.Close;
  cdsCadastro.FieldDefs.Clear;

  cdsCadastro.FieldDefs.Add('id', ftInteger);
  cdsCadastro.FieldDefs.Add('nome', ftString, 200);
  cdsCadastro.FieldDefs.Add('preco', ftString, 20);
  cdsCadastro.FieldDefs.Add('quantidadeEstoque', ftInteger);
  DBLabeledEdit1.DataField := 'nome';
  DBLabeledEdit2.DataField := 'preco';
  DBLabeledEdit3.DataField := 'quantidadeEstoque';
  DBLabeledEdit4.Visible := False;
  cdsCadastro.CreateDataSet;
  cdsCadastro.EmptyDataSet;
  cdsCadastro.Edit;
end;

procedure TfrmCadProduto.LocalizarProduto;
var
  LProduto: TFinanceiroProdutoDTO;
begin
  LProduto := FController.ObterPorId(Tag);
  DBLabeledEdit1.Text := LProduto.Nome;
  DBLabeledEdit2.Text := LProduto.Preco.ToString;
  DBLabeledEdit3.Text := LProduto.QuantidadeEstoque.ToString;
end;

end.
