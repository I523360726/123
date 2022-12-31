`include "com_param.svh"

parameter LV_SCAN_REG_NUM           = 6                                                         ,

parameter EFUSE_DATA_NUM            = 8                                                         ,
parameter EFUSE_DW                  = REG_DW                                                    ,

parameter HV_ANALOG_REG_START_ADDR  = 7'h40                                                     ,
parameter HV_ANALOG_REG_END_ADDR    = 7'h6E                                                     ,
parameter COM_WR_REG_NUM                                      = 9                                                        ,
parameter COM_RD_REG_NUM                                      = 9                                                        ,
parameter [REG_AW-1: 0] COM_WR_REG_ADDR[COM_WR_REG_NUM-1: 0]  = {7'h0B,7'h0A,7'h09,7'h08,7'h07,7'h06,7'h03,7'h02,7'h01}  ,
parameter [REG_AW-1: 0] COM_RD_REG_ADDR[COM_RD_REG_NUM-1: 0]  = {7'h1F,7'h15,7'h14,7'h0D,7'h0C,7'h0A,7'h08,7'h07,7'h06}  ,