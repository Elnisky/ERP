object frmCadVenda: TfrmCadVenda
  Left = 0
  Top = 0
  Caption = 'Cadastro de Venda'
  ClientHeight = 484
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlDados: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 427
    Align = alClient
    TabOrder = 0
    object lblClienteId: TLabel
      Left = 16
      Top = 20
      Width = 37
      Height = 15
      Caption = 'Cliente'
    end
    object lblStatus: TLabel
      Left = 16
      Top = 69
      Width = 32
      Height = 15
      Caption = 'Status'
    end
    object edtClienteId: TEdit
      Left = 80
      Top = 16
      Width = 121
      Height = 23
      TabOrder = 0
    end
    object cmbStatus: TComboBox
      Left = 80
      Top = 65
      Width = 185
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      Items.Strings = (
        'Orcamento'
        'PagamentoPendente'
        'Pago'
        'Cancelado')
    end
    object btnAdicionarItem: TButton
      Left = 16
      Top = 120
      Width = 121
      Height = 30
      Caption = 'Adicionar item'
      TabOrder = 2
      OnClick = btnAdicionarItemClick
    end
    object btnRemoverItem: TButton
      Left = 153
      Top = 120
      Width = 121
      Height = 30
      Caption = 'Remover item'
      TabOrder = 3
      OnClick = btnRemoverItemClick
    end
    object grdItens: TDBGrid
      Left = 16
      Top = 160
      Width = 720
      Height = 240
      DataSource = dsItens
      TabOrder = 4
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'produtoId'
          Title.Caption = 'Produto ID'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'quantidade'
          Title.Caption = 'Quantidade'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'valorUnitario'
          Title.Caption = 'Valor Unit'#225'rio'
          Width = 160
          Visible = True
        end>
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 427
    Width = 760
    Height = 57
    Align = alBottom
    TabOrder = 1
    object btnCancelar: TButton
      Left = 16
      Top = 12
      Width = 97
      Height = 33
      Caption = 'Cancelar'
      TabOrder = 0
      OnClick = btnCancelarClick
    end
    object btnConfirmar: TButton
      Left = 647
      Top = 12
      Width = 97
      Height = 33
      Caption = 'Confirmar'
      TabOrder = 1
      OnClick = btnConfirmarClick
    end
  end
  object dsItens: TDataSource
    DataSet = cdsItens
    Left = 368
    Top = 24
  end
  object cdsItens: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 464
    Top = 24
  end
end
