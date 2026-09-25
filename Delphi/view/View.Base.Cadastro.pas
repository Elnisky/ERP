unit View.Base.Cadastro;

interface

uses
  Data.DB,
  Datasnap.DBClient,
  System.Classes,
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
  Winapi.Messages,
  Winapi.Windows;

type
  TfrmBaseCadastro = class(TForm)
    Panel1: TPanel;
    btnCancelar: TButton;
    btnConfirmar: TButton;
    DBLabeledEdit1: TDBLabeledEdit;
    DBLabeledEdit2: TDBLabeledEdit;
    DBLabeledEdit3: TDBLabeledEdit;
    DBLabeledEdit4: TDBLabeledEdit;
    dsCadastro: TDataSource;
    cdsCadastro: TClientDataSet;
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBaseCadastro: TfrmBaseCadastro;

implementation

{$R *.dfm}

procedure TfrmBaseCadastro.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

end.
