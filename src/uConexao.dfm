object DMConexao: TDMConexao
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'User_Name=igor')
    Left = 256
    Top = 176
  end
  object FDPhysPgDriverLink1: TFDPhysPgDriverLink
    Left = 400
    Top = 184
  end
end
