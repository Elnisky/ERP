unit View.Base.Listagem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Datasnap.DBClient;

type
  TfrmBaseListagem = class(TForm)
    lblTitulo: TLabel;
    grdListagem: TDBGrid;
    btnVoltar: TButton;
    cdsLista: TClientDataSet;
    dsListagem: TDataSource;
    lblDetalhes: TLabel;
    grdDetalhes: TDBGrid;
    cdsDetalhes: TClientDataSet;
    dsDetalhes: TDataSource;
    procedure btnVoltarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBaseListagem: TfrmBaseListagem;

implementation

{$R *.dfm}

procedure TfrmBaseListagem.btnVoltarClick(Sender: TObject);
begin
  Close;
end;

end.
