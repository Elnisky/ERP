unit View.Cadastro.Cliente;

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
  ClienteController,
  Financeiro.DTOs,
  Winapi.Messages,
  Winapi.Windows;

type
  TfrmCadCliente = class(TfrmBaseCadastro)
    procedure btnConfirmarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FController: TClienteController;
    procedure InicializarCDS;
    procedure LocalizarCliente;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Excluir(const AId: Integer);
  end;

var
  frmCadCliente: TfrmCadCliente;

implementation

{$R *.dfm}

constructor TfrmCadCliente.Create(AOwner: TComponent);
begin
  inherited;
  FController := TClienteController.Create;
  InicializarCDS;
end;

destructor TfrmCadCliente.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TfrmCadCliente.Excluir(const AId: Integer);
begin
  if FController.Excluir(AId) then
    ShowMessage('Cliente excluido com sucesso!');
end;

procedure TfrmCadCliente.FormShow(Sender: TObject);
begin
  inherited;
  if Tag > 0 then
    LocalizarCliente;
end;

procedure TfrmCadCliente.btnConfirmarClick(Sender: TObject);
var
  LJson: string;
  LCliente: TFinanceiroClienteDTO;
begin
  inherited;
  try
    if Trim(DBLabeledEdit1.Text).IsEmpty then
      raise Exception.Create('Informe o nome do cliente.');

    if Trim(DBLabeledEdit2.Text).IsEmpty then
      raise Exception.Create('Informe o CPF do cliente.');

    if Trim(DBLabeledEdit3.Text).IsEmpty then
      raise Exception.Create('Informe o EMail do cliente.');

    if Trim(DBLabeledEdit4.Text).IsEmpty then
      raise Exception.Create('Informe o Telefone do cliente.');

    LJson := TFinanceiroClienteDTO.GetJson(Trim(DBLabeledEdit1.Text),
                                           Trim(DBLabeledEdit2.Text),
                                           Trim(DBLabeledEdit3.Text),
                                           Trim(DBLabeledEdit4.Text),
                                           Tag.ToString);
    if Tag = 0 then
      LCliente := FController.Criar(LJson)
    else
      LCliente := FController.Atualizar(LJson);

    try
      ShowMessage(Format('Cliente %s com sucesso!', [IfThen(Tag = 0, 'cadastrado', 'alterado')]));
      ModalResult := mrOk;
      Close;
    finally
      if Assigned(LCliente) then
        LCliente.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao cadastrar cliente: ' + E.Message);
  end;
end;

procedure TfrmCadCliente.InicializarCDS;
begin
  cdsCadastro.Close;
  cdsCadastro.FieldDefs.Clear;

  cdsCadastro.FieldDefs.Add('id', ftInteger);
  cdsCadastro.FieldDefs.Add('nome', ftString, 200);
  cdsCadastro.FieldDefs.Add('cpf', ftString, 20);
  cdsCadastro.FieldDefs.Add('email', ftString, 200);
  cdsCadastro.FieldDefs.Add('telefone', ftString, 30);
  cdsCadastro.FieldDefs.Add('dataCadastro', ftDateTime);
  DBLabeledEdit1.DataField := 'nome';
  DBLabeledEdit2.DataField := 'cpf';
  DBLabeledEdit3.DataField := 'email';
  DBLabeledEdit4.DataField := 'telefone';
  cdsCadastro.CreateDataSet;
  cdsCadastro.EmptyDataSet;
  cdsCadastro.Edit;
end;

procedure TfrmCadCliente.LocalizarCliente;
var
  LCliente: TFinanceiroClienteDTO;
begin
  LCliente := FController.ObterPorId(Tag);
  DBLabeledEdit1.Text := LCliente.Nome;
  DBLabeledEdit2.Text := LCliente.Cpf;
  DBLabeledEdit3.Text := LCliente.Email;
  DBLabeledEdit4.Text := LCliente.Telefone;
end;

end.
