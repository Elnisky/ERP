inherited frmListagemCliente: TfrmListagemCliente
  Caption = 'frmListagemCliente'
  StyleElements = [seFont, seClient, seBorder]
  OnCreate = FormCreate
  TextHeight = 15
  inherited lblTitulo: TLabel
    Caption = 'Listagem Clientes'
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 122
  end
  inherited lblDetalhes: TLabel
    StyleElements = [seFont, seClient, seBorder]
  end
  inherited cdsLista: TClientDataSet
    AfterScroll = cdsListaAfterScroll
  end
end
