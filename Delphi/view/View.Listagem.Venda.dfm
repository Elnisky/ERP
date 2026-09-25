inherited frmListagemVenda: TfrmListagemVenda
  Caption = 'frmListagemVenda'
  StyleElements = [seFont, seClient, seBorder]
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  inherited lblTitulo: TLabel
    Caption = 'Listagem de Vendas'
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 138
  end
  inherited lblDetalhes: TLabel
    Caption = 'Produtos da Venda'
    StyleElements = [seFont, seClient, seBorder]
    ExplicitWidth = 131
  end
  inherited cdsLista: TClientDataSet
    AfterScroll = cdsListaAfterScroll
  end
end
