object frmBaseListagem: TfrmBaseListagem
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 480
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    640
    480)
  TextHeight = 15
  object lblTitulo: TLabel
    Left = 0
    Top = 0
    Width = 640
    Height = 21
    Align = alTop
    Alignment = taCenter
    Caption = 'Lista'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 32
  end
  object lblDetalhes: TLabel
    Left = 0
    Top = 217
    Width = 640
    Height = 21
    Align = alTop
    Alignment = taCenter
    Caption = 'Detalhes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 60
  end
  object grdListagem: TDBGrid
    Left = 0
    Top = 21
    Width = 640
    Height = 196
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsListagem
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object btnVoltar: TButton
    Left = 562
    Top = 452
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '< Voltar'
    TabOrder = 1
    OnClick = btnVoltarClick
  end
  object grdDetalhes: TDBGrid
    Left = 0
    Top = 238
    Width = 640
    Height = 212
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsDetalhes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object cdsLista: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 336
    Top = 56
  end
  object dsListagem: TDataSource
    DataSet = cdsLista
    Left = 272
    Top = 56
  end
  object cdsDetalhes: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 336
    Top = 304
  end
  object dsDetalhes: TDataSource
    DataSet = cdsDetalhes
    Left = 272
    Top = 304
  end
end
