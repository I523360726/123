parameter ADC_DW                = 10                                                        ,

parameter REG_DW                = 8                                                         ,
parameter REG_AW                = 7                                                         ,
parameter REG_CRC_W             = 8                                                         ,
parameter REQ_ADC_ADDR          = 7'h1f                                                     ,

parameter OWT_FSM_ST_NUM        = 9                                                         ,
parameter OWT_EXT_CYC_NUM       = 7                                                         ,
parameter OWT_CRC_BIT_NUM       = 8                                                         ,
parameter OWT_CMD_BIT_NUM       = 8                                                         ,
parameter OWT_DATA_BIT_NUM      = 8                                                         ,
parameter OWT_ADCD_BIT_NUM      = 20                                                        ,
parameter OWT_SYNC_BIT_NUM      = 12                                                        ,
parameter OWT_TAIL_BIT_NUM      = 4                                                         ,
parameter OWT_ABORT_BIT_NUM     = 4                                                         ,
parameter OWT_FSM_ST_W          = $clog2(OWT_FSM_ST_NUM)                                    ,
parameter CNT_OWT_EXT_CYC_W     = $clog2(5*OWT_EXT_CYC_NUM+1)                               ,
parameter CNT_OWT_MAX_W         = $clog2(OWT_ADCD_BIT_NUM)                                  ,
parameter OWT_IDLE_ST           = OWT_FSM_ST_W'(0)                                          ,
parameter OWT_SYNC_HEAD_ST      = OWT_FSM_ST_W'(1)                                          ,
parameter OWT_SYNC_TAIL_ST      = OWT_FSM_ST_W'(2)                                          , 
parameter OWT_CMD_ST            = OWT_FSM_ST_W'(3)                                          ,
parameter OWT_NML_DATA_ST       = OWT_FSM_ST_W'(4)                                          ,//normal data
parameter OWT_ADC_DATA_ST       = OWT_FSM_ST_W'(5)                                          ,
parameter OWT_CRC_ST            = OWT_FSM_ST_W'(6)                                          ,
parameter OWT_END_TAIL_ST       = OWT_FSM_ST_W'(7)                                          ,
parameter OWT_ABORT_ST          = OWT_FSM_ST_W'(8)                                          ,

parameter CLK_M                 =  22 ,
parameter WDG_240US_CYC_NUM     =  240*CLK_M ,
parameter WDG_250US_CYC_NUM     =  250*CLK_M ,
parameter WDG_280US_CYC_NUM     =  280*CLK_M , //one core clk cycle is (1000/48)ns, 280us has (280x1000)ns/(1000/48)ns = 280x48 cycle.
parameter WDG_320US_CYC_NUM     =  320*CLK_M ,
parameter WDG_490US_CYC_NUM     =  490*CLK_M ,
parameter WDG_500US_CYC_NUM     =  500*CLK_M ,
parameter WDG_530US_CYC_NUM     =  530*CLK_M ,
parameter WDG_550US_CYC_NUM     =  550*CLK_M ,
parameter WDG_570US_CYC_NUM     =  570*CLK_M ,
parameter WDG_750US_CYC_NUM     =  750*CLK_M ,
parameter WDG_800US_CYC_NUM     =  800*CLK_M ,
parameter WDG_860US_CYC_NUM     =  860*CLK_M ,
parameter WDG_990US_CYC_NUM     =  990*CLK_M ,
parameter WDG_1000US_CYC_NUM    = 1000*CLK_M ,
parameter WDG_1030US_CYC_NUM    = 1030*CLK_M ,
parameter WDG_1110US_CYC_NUM    = 1110*CLK_M ,
parameter WDG_1070US_CYC_NUM    = 1070*CLK_M ,
parameter WDG_1260US_CYC_NUM    = 1260*CLK_M ,
parameter WDG_1300US_CYC_NUM    = 1300*CLK_M ,
parameter WDG_1500US_CYC_NUM    = 1500*CLK_M ,
parameter WDG_1510US_CYC_NUM    = 1510*CLK_M ,
parameter WDG_1610US_CYC_NUM    = 1610*CLK_M ,
parameter WDG_1990US_CYC_NUM    = 1990*CLK_M ,
parameter WDG_2000US_CYC_NUM    = 2000*CLK_M ,
parameter WDG_2010US_CYC_NUM    = 2010*CLK_M ,
parameter WDG_2030US_CYC_NUM    = 2030*CLK_M ,
parameter WDG_2070US_CYC_NUM    = 2070*CLK_M ,
parameter WDG_2300US_CYC_NUM    = 2300*CLK_M ,
parameter WDG_2500US_CYC_NUM    = 2500*CLK_M ,
parameter WDG_2610US_CYC_NUM    = 2610*CLK_M ,
parameter WDG_3010US_CYC_NUM    = 3010*CLK_M ,
parameter WDG_CNT_W             = $clog2(WDG_3010US_CYC_NUM),
parameter [WDG_CNT_W-1: 0]    WDG_SCANREG_TH[3: 0]  = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM}, //TH = threshold
parameter [WDG_CNT_W-1: 0]    WDG_REFRESH_TH[3: 0]  = {WDG_1990US_CYC_NUM, WDG_990US_CYC_NUM , WDG_490US_CYC_NUM, WDG_240US_CYC_NUM},
parameter [WDG_CNT_W-1: 0] LV_WDG_TIMEOUT_TH[3: 0]  = {WDG_3010US_CYC_NUM, WDG_2010US_CYC_NUM, WDG_1510US_CYC_NUM, WDG_1260US_CYC_NUM},
parameter [WDG_CNT_W-1: 0] HV_WDG_TIMEOUT_TH[3: 0]  = {WDG_2500US_CYC_NUM, WDG_1500US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_750US_CYC_NUM},
parameter [WDG_CNT_W-1: 0]    WDG_INTB_TH   [3: 0]  = {WDG_2030US_CYC_NUM, WDG_1030US_CYC_NUM, WDG_530US_CYC_NUM, WDG_280US_CYC_NUM},
parameter SPI_TMO_CYC_NUM       = 2*WDG_3010US_CYC_NUM,
parameter SPI_TMO_CNT_W         = $clog2(SPI_TMO_CYC_NUM),
parameter OWT_TMO_CYC_NUM       = WDG_3010US_CYC_NUM,
parameter OWT_TMO_CNT_W         = $clog2(OWT_TMO_CYC_NUM),

parameter PWM_INTB_EXT_CYC_NUM  = 8,
parameter HV_DV_ID              = 4'(2),
parameter LV_DV_ID              = 4'(1),

parameter [5: 0] OWT_COM_ERR_SET_NUM[3: 0]  = {32, 16, 8, 4}                   ,
parameter [5: 0] OWT_COM_COR_SUB_NUM[3: 0]  = {8 , 4 , 2, 1}                   ,
parameter OWT_COM_MAX_ERR_NUM               = 512                              ,
parameter OWT_COM_ERR_CNT_W                 = $clog2(OWT_COM_MAX_ERR_NUM+1)    ,
parameter INIT_OWT_COM_ERR_NUM              = OWT_COM_ERR_CNT_W'(32)           ,

parameter CTRL_FSM_ST_NUM           = 9                                                  ,
parameter CTRL_FSM_ST_W             = (CTRL_FSM_ST_NUM==1) ? 1 : $clog2(CTRL_FSM_ST_NUM) ,

parameter PWR_DWN_ST                = CTRL_FSM_ST_W'(0)                                  ,
parameter WAIT_ST                   = CTRL_FSM_ST_W'(1)                                  ,
parameter TEST_ST                   = CTRL_FSM_ST_W'(2)                                  ,
parameter NML_ST                    = CTRL_FSM_ST_W'(3)                                  ,
parameter FAILSAFE_ST               = CTRL_FSM_ST_W'(4)                                  ,
parameter FSISO_ST                  = CTRL_FSM_ST_W'(4)                                  ,
parameter FAULT_ST                  = CTRL_FSM_ST_W'(5)                                  ,
parameter CFG_ST                    = CTRL_FSM_ST_W'(6)                                  ,
parameter RST_ST                    = CTRL_FSM_ST_W'(7)                                  ,
parameter BIST_ST                   = CTRL_FSM_ST_W'(8)                                  ,

parameter RD_OP    = 1'b0, //OP==OPERATION
parameter WR_OP    = 1'b1, 

parameter OWT_HEAD_SYNC_CYC_NUM = 2*OWT_SYNC_BIT_NUM *OWT_EXT_CYC_NUM ,
parameter OWT_TAIL_SYNC_CYC_NUM =   OWT_TAIL_BIT_NUM *OWT_EXT_CYC_NUM ,
parameter OWT_CMD_CYC_NUM       = 2*OWT_CMD_BIT_NUM  *OWT_EXT_CYC_NUM ,
parameter OWT_DATA_CYC_NUM      = 2*OWT_DATA_BIT_NUM *OWT_EXT_CYC_NUM ,
parameter OWT_CRC_CYC_NUM       = 2*OWT_CRC_BIT_NUM  *OWT_EXT_CYC_NUM ,
parameter OWT_ADCD_CYC_NUM      = 2*OWT_ADCD_BIT_NUM *OWT_EXT_CYC_NUM ,

parameter MAX_OWT_TX_CYC_NUM = OWT_HEAD_SYNC_CYC_NUM+2*OWT_TAIL_SYNC_CYC_NUM+OWT_CMD_CYC_NUM+OWT_DATA_CYC_NUM+OWT_CRC_CYC_NUM,
parameter LANCH_LST_TX_CNT_W = $clog2(MAX_OWT_TX_CYC_NUM),

parameter HV_MAX_OWT_RX_CYC_NUM = OWT_HEAD_SYNC_CYC_NUM+2*OWT_TAIL_SYNC_CYC_NUM+OWT_CMD_CYC_NUM+OWT_DATA_CYC_NUM+OWT_CRC_CYC_NUM,
parameter HV_DLY_RX_ACK_CNT_W   = $clog2(HV_MAX_OWT_RX_CYC_NUM),
parameter HV_RX_TMO_CNT_W       = $clog2(2*HV_MAX_OWT_RX_CYC_NUM),

parameter MAX_OWT_RX_CYC_NUM = OWT_HEAD_SYNC_CYC_NUM+2*OWT_TAIL_SYNC_CYC_NUM+OWT_CMD_CYC_NUM+OWT_ADCD_CYC_NUM+OWT_CRC_CYC_NUM,
parameter DLY_RX_ACK_CNT_W   = $clog2(MAX_OWT_RX_CYC_NUM),
parameter RX_TMO_CNT_W       = $clog2(2*MAX_OWT_RX_CYC_NUM),


parameter BIST_OWT_TX_NUM      = 5                                          ,
parameter BIST_OWT_TX_CNT_W    = $clog2(BIST_OWT_TX_NUM+1)                  ,
parameter BIST_OWT_RX_CNT_W    = BIST_OWT_TX_CNT_W                          ,
parameter BIST_OWT_TX_OK_NUM   = 3                                          ,
parameter BIST_OWT_RX_OK_NUM   = BIST_OWT_TX_OK_NUM                         ,
parameter BIST_TMO_TH          = (2*WDG_2030US_CYC_NUM>10*(MAX_OWT_TX_CYC_NUM+MAX_OWT_RX_CYC_NUM)) ? 2*WDG_2030US_CYC_NUM : 10*(MAX_OWT_TX_CYC_NUM+MAX_OWT_RX_CYC_NUM),
parameter BIST_TMO_CNT_W       = $clog2(BIST_TMO_TH)                        ,

parameter EFUSE_LOAD_DLY_NUM   = 20,
parameter EFUSE_LOAD_DLY_CNT_W = $clog2(EFUSE_LOAD_DLY_NUM),























































