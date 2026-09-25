inherited frmProdutoListagem: TfrmProdutoListagem
  Caption = 'frmProdutoListagem'
  StyleElements = [seFont, seClient, seBorder]
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  inherited lblTitulo: TLabel
    Caption = 'Listagem de Produtos'
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 151
  end
  inherited lblDetalhes: TLabel
    StyleElements = [seFont, seClient, seBorder]
  end
  inherited cdsLista: TClientDataSet
    AfterScroll = cdsListaAfterScroll
  end
end
