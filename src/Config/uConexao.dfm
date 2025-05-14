object DMConexao: TDMConexao
  Height = 480
  Width = 640
  object FDConnection: TFDConnection
    Left = 192
    Top = 208
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    OnDriverCreated = FDPhysPgDriverLinkDriverCreated
    Left = 312
    Top = 212
  end
end
