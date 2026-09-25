inherited frmCadCliente: TfrmCadCliente
  BorderStyle = bsSingle
  Caption = 'Cadastro Cliente'
  StyleElements = [seFont, seClient, seBorder]
  OnShow = FormShow
  TextHeight = 15
  inherited Panel1: TPanel
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 237
    inherited btnCancelar: TButton
      ExplicitLeft = 20
      ExplicitTop = 3
      ExplicitHeight = 51
    end
    inherited btnConfirmar: TButton
      OnClick = btnConfirmarClick
      ExplicitLeft = 257
    end
  end
  inherited DBLabeledEdit1: TDBLabeledEdit
    StyleElements = [seFont, seClient, seBorder]
    EditLabel.Width = 33
    EditLabel.Caption = 'Nome'
    EditLabel.ExplicitWidth = 33
    ExplicitLeft = 3
    ExplicitTop = 25
    ExplicitWidth = 346
  end
  inherited DBLabeledEdit2: TDBLabeledEdit
    StyleElements = [seFont, seClient, seBorder]
    EditLabel.Width = 21
    EditLabel.Caption = 'CPF'
    EditLabel.ExplicitWidth = 21
    ExplicitLeft = 3
    ExplicitTop = 76
  end
  inherited DBLabeledEdit3: TDBLabeledEdit
    StyleElements = [seFont, seClient, seBorder]
    EditLabel.Width = 29
    EditLabel.Caption = 'EMail'
    EditLabel.ExplicitWidth = 29
    ExplicitLeft = 3
    ExplicitTop = 127
  end
  inherited DBLabeledEdit4: TDBLabeledEdit
    StyleElements = [seFont, seClient, seBorder]
    EditLabel.Width = 44
    EditLabel.Caption = 'Telefone'
    EditLabel.ExplicitWidth = 44
    ExplicitLeft = 3
    ExplicitTop = 178
  end
end
