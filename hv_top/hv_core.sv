//============================================================
//Module   : hv_core
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_core import com_pkg::*; import hv_pkg::*;
#(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                                        i_s32_16                        ,
    input  logic                                        i_spi_sclk                      ,
    input  logic                                        i_spi_csb                       ,
    input  logic                                        i_spi_mosi                      ,
    output logic                                        o_spi_miso                      , 

    input  logic                                        i_d2d1rx_dpu_vld                ,
    input  logic [7:    0]                              i_d2d1rx_dpu_addr               ,
    input  logic [7:    0]                              i_d2d1rx_dpu_data               ,
    output logic                                        o_dpu_d2d1rx_rdy                ,

    output logic                                        o_spi_s16pin_wr_req             ,
    output logic                                        o_spi_s16pin_rd_req             ,
    output logic [REG_AW-1:     0]                      o_spi_s16pin_addr               , 
    output logic [REG_DW-1:     0]                      o_spi_s16pin_wdata              ,
    output logic [REG_CRC_W-1:  0]                      o_spi_s16pin_wcrc               , 
    input  logic                                        i_s16pin_spi_wack               ,
    input  logic                                        i_s16pin_spi_rack               ,
    input  logic [REG_DW-1:     0]                      i_s16pin_spi_data               ,
    input  logic [REG_AW-1:     0]                      i_s16pin_spi_addr               , 

    output logic                                        o_hv_lv_owt_tx                  ,
    input  logic                                        i_lv_hv_owt_rx                  ,

    input  logic                                        i_setb                          ,

    input  logic                                        i_io_test_mode                  ,
    output logic                                        o_fsm_ang_test_en               ,
    input  logic                                        i_hv_vcc_uv                     ,
    input  logic                                        i_hv_vcc_ov                     ,
    input  logic                                        i_hv_ot                         ,
    input  logic                                        i_hv_oc                         ,
    input  logic                                        i_hv_desat_flt                  ,
    input  logic                                        i_hv_scp_flt                    ,

    input  logic                                        i_vge_vce                       ,
    input  logic                                        i_io_fsiso                      ,
    input  logic                                        i_io_pwma                       ,
    input  logic                                        i_io_pwm                        ,
    input  logic                                        i_io_fsstate                    ,
    input  logic                                        i_io_fsenb_n                    ,
    input  logic                                        i_io_intb                       ,
    input  logic                                        i_io_inta                       ,
    output logic                                        o_rtmon                         ,

    output logic                                        o_bist_hv_ov                    ,
    output logic                                        o_bist_hv_ot                    ,
    output logic                                        o_bist_hv_opscod                ,
    output logic                                        o_bist_hv_oc                    ,
    output logic                                        o_bist_hv_sc                    ,
    output logic                                        o_bist_hv_adc                   ,

    input  logic [3:    0]                              i_off_vbn_read                  ,
    input  logic [3:    0]                              i_on_vbn_read                   ,
    input  logic [5:    0]                              i_cnt_del_read                  ,

    input  logic [9:    0]                              i_adc_data1                     ,
    input  logic [9:    0]                              i_adc_data2                     ,
    input  logic                                        i_adc_ready1                    ,
    input  logic                                        i_adc_ready2                    ,

    output logic                                        o_efuse_wmode                   ,
    output logic                                        o_io_efuse_setb                 ,
    output logic                                        o_efuse_wr_p                    ,
    output logic                                        o_efuse_rd_p                    ,
    output logic [6:       0]                           o_efuse_addr                    ,
    output logic [7:       0]                           o_efuse_wdata0                  ,
    output logic [7:       0]                           o_efuse_wdata1                  ,
    output logic [7:       0]                           o_efuse_wdata2                  ,
    output logic [7:       0]                           o_efuse_wdata3                  ,
    output logic [7:       0]                           o_efuse_wdata4                  ,
    output logic [7:       0]                           o_efuse_wdata5                  ,
    output logic [7:       0]                           o_efuse_wdata6                  ,
    output logic [7:       0]                           o_efuse_wdata7                  ,
    output logic [7:       0]                           o_efuse_wdata8                  ,
    output logic [7:       0]                           o_efuse_wdata9                  ,
    output logic [7:       0]                           o_efuse_wdata10                 ,
    output logic [7:       0]                           o_efuse_wdata11                 ,
    output logic [7:       0]                           o_efuse_wdata12                 ,
    output logic [7:       0]                           o_efuse_wdata13                 ,
    output logic [7:       0]                           o_efuse_wdata14                 ,
    output logic [7:       0]                           o_efuse_wdata15                 ,
    input  logic                                        i_efuse_op_finish               ,
    input  logic                                        i_efuse_reg_update              ,
    input  logic [7:       0]                           i_efuse_reg_data0               ,
    input  logic [7:       0]                           i_efuse_reg_data1               ,
    input  logic [7:       0]                           i_efuse_reg_data2               ,
    input  logic [7:       0]                           i_efuse_reg_data3               ,
    input  logic [7:       0]                           i_efuse_reg_data4               ,
    input  logic [7:       0]                           i_efuse_reg_data5               ,
    input  logic [7:       0]                           i_efuse_reg_data6               ,
    input  logic [7:       0]                           i_efuse_reg_data7               ,
    input  logic [7:       0]                           i_efuse_reg_data8               ,
    input  logic [7:       0]                           i_efuse_reg_data9               ,
    input  logic [7:       0]                           i_efuse_reg_data10              ,
    input  logic [7:       0]                           i_efuse_reg_data11              ,
    input  logic [7:       0]                           i_efuse_reg_data12              ,
    input  logic [7:       0]                           i_efuse_reg_data13              ,
    input  logic [7:       0]                           i_efuse_reg_data14              ,
    input  logic [7:       0]                           i_efuse_reg_data15              ,

    output logic                                        o_efuse_load_req                ,
    input  logic                                        i_efuse_load_done               ,

    input  logic                                        i_ang_dgt_pwm_wv                , //analog pwm ctrl to digtial pwm ctrl pwm wave
    input  logic                                        i_ang_dgt_pwm_fs                ,

    output logic                                        o_dgt_ang_pwm_en                ,
    output logic                                        o_dgt_ang_fsiso_en              ,
    output logic                                        o_pwmn_intb                     ,

    output logic                                        o_adc1_en                       ,
    output logic                                        o_adc2_en                       ,
  
    output str_reg_iso_bgr_trim                         o_reg_iso_bgr_trim              ,
    output str_reg_iso_con_ibias_trim                   o_reg_iso_con_ibias_trim        ,
    output str_reg_iso_osc48m_trim                      o_reg_iso_osc48m_trim           ,
    output str_reg_iso_oscb_freq_adj                    o_reg_iso_oscb_freq_adj         ,
    output str_reg_iso_reserved_reg                     o_reg_iso_reserved_reg          ,
    output str_reg_iso_amp_ibias                        o_reg_iso_amp_ibias             ,
    output str_reg_iso_demo_trim                        o_reg_iso_demo_trim             ,
    output str_reg_iso_test_sw                          o_reg_iso_test_sw               ,
    output str_reg_iso_osc_jit                          o_reg_iso_osc_jit               ,
    output logic [REG_DW-1:      0]                     o_reg_ana_reserved_reg2         ,
    output str_reg_config1_dr_src_snk_both              o_reg_config1_dr_src_snk_both   ,
    output str_reg_config2_dr_src_sel                   o_reg_config2_dr_src_sel        ,
    output str_reg_config3_dri_snk_sel                  o_reg_config3_dri_snk_sel       ,
    output str_reg_config4_tltoff_sel1                  o_reg_config4_tltoff_sel1       ,
    output str_reg_config5_tltoff_sel2                  o_reg_config5_tltoff_sel2       ,
    output str_reg_config6_desat_sel1                   o_reg_config6_desat_sel1        ,
    output str_reg_config7_desat_sel2                   o_reg_config7_desat_sel2        ,
    output str_reg_config8_oc_sel                       o_reg_config8_oc_sel            ,
    output str_reg_config9_sc_sel                       o_reg_config9_sc_sel            ,
    output str_reg_config10_dvdt_ref_src                o_reg_config10_dvdt_ref_src     ,
    output str_reg_config11_dvdt_ref_sink               o_reg_config11_dvdt_ref_sink    ,
    output str_reg_config12_adc_en                      o_reg_config12_adc_en           ,
    output str_reg_bgr_code_drv                         o_reg_bgr_code_drv              ,
    output str_reg_cap_trim_code                        o_reg_cap_trim_code             ,     
    output str_reg_csdel_cmp                            o_reg_csdel_cmp                 , 
    output str_reg_dvdt_value_adj                       o_reg_dvdt_value_adj            , 
    output str_reg_adc_adj1                             o_reg_adc_adj1                  , 
    output str_reg_adc_adj2                             o_reg_adc_adj2                  , 
    output str_reg_ibias_code_drv                       o_reg_ibias_code_drv            ,
    output str_reg_dvdt_tm                              o_reg_dvdt_tm                   ,  
    output str_reg_dvdt_win_value_en                    o_reg_dvdt_win_value_en         , 
    output str_reg_preset_delay                         o_reg_preset_delay              , 
    output str_reg_drive_delay_set                      o_reg_drive_delay_set           ,
    output str_reg_cmp_del                              o_reg_cmp_del                   ,
    output str_reg_test_mux                             o_reg_test_mux                  , 
    output str_reg_cmp_adj_vreg                         o_reg_cmp_adj_vreg              ,

    input  logic                                        i_clk                           ,
    input  logic                                        i_rst_n
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                                               fsm_spi_slv_en          ;
logic                                               spi_reg_slv_err         ; 

logic                                               spi_wr_req              ;
logic                                               spi_rd_req              ;
logic [REG_AW-1:            0]                      spi_addr                ; 
logic [REG_DW-1:            0]                      spi_wdata               ;
logic [REG_CRC_W-1:         0]                      spi_wcrc                ;

logic                                               spi_wack                ;
logic                                               spi_rack                ;
logic [REG_DW-1:            0]                      spi_ack_data            ;
logic [REG_AW-1:            0]                      spi_ack_addr            ;

logic                                               spi_s32pin_wr_req       ;
logic                                               spi_s32pin_rd_req       ;
logic [REG_AW-1:            0]                      spi_s32pin_addr         ; 
logic [REG_DW-1:            0]                      spi_s32pin_wdata        ;
logic [REG_CRC_W-1:         0]                      spi_s32pin_wcrc         ; 
logic                                               s32pin_spi_wack         ;
logic                                               s32pin_spi_rack         ;
logic [REG_DW-1:            0]                      s32pin_spi_data         ;
logic [REG_AW-1:            0]                      s32pin_spi_addr         ;

logic                                               rac_wr_req              ;
logic                                               rac_rd_req              ;
logic [REG_AW-1:            0]                      rac_addr                ; 
logic [REG_DW-1:            0]                      rac_wdata               ;
logic [REG_CRC_W-1:         0]                      rac_wcrc                ; 
logic                                               rac_wack                ;
logic                                               rac_rack                ;
logic [REG_DW-1:            0]                      rac_ack_data            ;
logic [REG_AW-1:            0]                      rac_ack_addr            ;
    
logic                                               wdg_scan_rac_rd_req     ;
logic [REG_AW-1:            0]                      wdg_scan_rac_addr       ;
logic                                               rac_wdg_scan_ack        ;
logic [REG_DW-1:            0]                      rac_wdg_scan_data       ;
logic [REG_CRC_W-1:         0]                      rac_wdg_scan_crc        ;
    
logic                                               spi_owt_wr_req          ;
logic                                               spi_owt_rd_req          ;
logic [REG_AW-1:            0]                      spi_owt_addr            ;
logic [REG_DW-1:            0]                      spi_owt_data            ;
logic                                               owt_tx_spi_ack          ;
logic                                               owt_rx_spi_rsp          ;
logic                                               spi_rst_wdg             ;
    
logic                                               rac_reg_ren             ;
logic                                               rac_reg_wen             ;
logic [REG_AW-1:            0]                      rac_reg_addr            ;
logic [REG_DW-1:            0]                      rac_reg_wdata           ;
logic [REG_CRC_W-1:         0]                      rac_reg_wcrc            ;
    
logic                                               reg_rac_wack            ;
logic                                               reg_rac_rack            ;
logic [REG_DW-1:            0]                      reg_rac_rdata           ;
logic [REG_CRC_W-1:         0]                      reg_rac_rcrc            ;
    
logic                                               wdg_owt_adc_req         ;
logic                                               owt_wdg_adc_ack         ;
    
logic [OWT_CMD_BIT_NUM-1:   0]                      owt_tx_cmd_lock         ;
    
logic                                               owt_rx_rst_wdg_owt      ;
logic                                               wdg_owt_rx_tmo          ;  
    
logic                                               owt_rx_reg_slv_owtcomerr;//owt_com_err.
    
logic                                               wdg_scan_en             ;
logic                                               wdg_scan_reg_slv_crcerr ;//cerr = crc_err.
    
logic                                               bist_scan_reg_req       ;
logic                                               scan_reg_bist_ack       ;
logic                                               scan_reg_bist_err       ;
    
logic                                               wdg_owt_en              ;
logic                                               wdg_owt_tx_adc_req      ;
logic                                               owt_tx_wdg_adc_ack      ;
        
logic                                               wdg_owt_reg_slv_tmoerr  ;//timeout_err
    
logic                                               hv_vcc_uverr            ;
logic                                               hv_vcc_overr            ;
logic                                               hv_ot_err               ;
logic                                               hv_oc_err               ;
logic                                               hv_desat_err            ;
logic                                               hv_scp_err              ;

logic [REG_DW-1:             0]                     hv_status1              ;
logic [REG_DW-1:             0]                     hv_status2              ;
logic [REG_DW-1:             0]                     hv_status3              ;
logic [REG_DW-1:             0]                     hv_status4              ;

logic                                               efuse_op_finish         ;            
logic                                               efuse_reg_update        ;
logic [EFUSE_DATA_NUM-1:     0][EFUSE_DW-1: 0]      efuse_reg_data          ;
        
logic                                               test_st_reg_en          ;
logic                                               cfg_st_reg_en           ;
logic                                               spi_ctrl_reg_en         ;
logic                                               efuse_ctrl_reg_en       ;
    
logic [CTRL_FSM_ST_W-1:      0]                     hv_ctrl_cur_st          ;
    
logic                                               bist_en                 ;
    
logic                                               lbist_en                ;
logic                                               hv_bist_fail            ;
    
logic                                               owt_rx_rac_vld          ;
logic [OWT_CMD_BIT_NUM-1:    0]                     owt_rx_rac_cmd          ;
logic [OWT_DATA_BIT_NUM-1:   0]                     owt_rx_rac_data         ;
logic [OWT_CRC_BIT_NUM-1:    0]                     owt_rx_rac_crc          ;
logic                                               owt_rx_rac_status       ;

logic                                               rac_owt_tx_wr_cmd_vld   ;
logic                                               rac_owt_tx_rd_cmd_vld   ;
logic [REG_AW-1:             0]                     rac_owt_tx_addr         ;
logic [OWT_ADCD_BIT_NUM-1:   0]                     rac_owt_tx_data         ;   

str_reg_mode                                        reg_mode                ;
str_reg_com_config1                                 reg_com_config1         ;
str_reg_com_config2                                 reg_com_config2         ;
str_reg_status1                                     reg_status1             ;
str_reg_status2                                     reg_status2             ;
str_reg_efuse_config                                reg_die2_efuse_config   ;
str_reg_efuse_status                                reg_die2_efuse_status   ;

logic [ADC_DW-1:            0]                      adc_data1               ;
logic [ADC_DW-1:            0]                      adc_data2               ;

logic                                               intb_n                  ;
logic                                               vrtmon                  ;

logic [7:                   0]                      cap_trim_code_read      ;
logic [5:                   0]                      cnt_del_read            ;

logic [7:                   0]                      hv_bist1                ;
logic [7:                   0]                      hv_bist2                ;

logic                                               hv_bist_done            ;

logic                                               setb                    ;
logic                                               io_test_mode            ;

logic                                               vge_vce                 ;
logic                                               io_fsiso                ;
logic                                               io_pwma                 ;
logic                                               io_pwm                  ;
logic                                               io_fsstate              ;
logic                                               io_fsenb_n              ;
logic                                               io_intb                 ;
logic                                               io_inta                 ;
//==================================        
//main code
//==================================
gnrl_sync #(
    .DW(1)
)U_SETB_SYNC(
    .i_data     (i_setb          ),
    .o_data     (setb            ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_TEST_MODE_SYNC(
    .i_data     (i_io_test_mode  ),
    .o_data     (io_test_mode    ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_VGE_VCE_SYNC(
    .i_data     (i_vge_vce       ),
    .o_data     (vge_vce         ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_FSISO_SYNC(
    .i_data     (i_io_fsiso      ),
    .o_data     (io_fsiso        ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_PWMA_SYNC(
    .i_data     (i_io_pwma       ),
    .o_data     (io_pwma         ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_PWM_SYNC(
    .i_data     (i_io_pwm        ),
    .o_data     (io_pwm          ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_FSSTATE_SYNC(
    .i_data     (i_io_fsstate    ),
    .o_data     (io_fsstate      ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_FSENB_N_SYNC(
    .i_data     (i_io_fsenb_n    ),
    .o_data     (io_fsenb_n      ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_INTB_SYNC(
    .i_data     (i_io_intb       ),
    .o_data     (io_intb         ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

gnrl_sync #(
    .DW(1)
)U_IO_INTA_SYNC(
    .i_data     (i_io_inta       ),
    .o_data     (io_inta         ),
    .i_clk      (i_clk           ),
    .i_rst_n    (i_rst_n         )
);

spi_slv U_SPI_SLV(
    .i_spi_sclk                 (i_spi_sclk                         ),
    .i_spi_csb                  (i_spi_csb                          ),
    .i_spi_mosi                 (i_spi_mosi                         ),
    .o_spi_miso                 (o_spi_miso                         ),

    .i_spi_slv_en               (fsm_spi_slv_en                     ),

    .o_spi_rac_wr_req           (spi_wr_req                         ),
    .o_spi_rac_rd_req           (spi_rd_req                         ),
    .o_spi_rac_addr             (spi_addr                           ),
    .o_spi_rac_wdata            (spi_wdata                          ),
    .o_spi_rac_wcrc             (spi_wcrc                           ),

    .i_rac_spi_wack             (spi_wack                           ),
    .i_rac_spi_rack             (spi_rack                           ),
    .i_rac_spi_data             (spi_ack_data                       ),
    .i_rac_spi_addr             (spi_ack_addr                       ),

    .o_spi_err                  (spi_reg_slv_err                    ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

hv_spi_owt_acc_arb U_HV_SPI_OWT_ACC_ARB(
    .i_spi_wr_req               (spi_s32pin_wr_req                  ),
    .i_spi_rd_req               (spi_s32pin_rd_req                  ),
    .i_spi_addr                 (spi_s32pin_addr                    ),
    .i_spi_wdata                (spi_s32pin_wdata                   ),
    .i_spi_wcrc                 (spi_s32pin_wcrc                    ),

    .o_spi_wack                 (s32pin_spi_wack                    ),
    .o_spi_rack                 (s32pin_spi_rack                    ),
    .o_spi_data                 (s32pin_spi_data                    ),
    .o_spi_addr                 (s32pin_spi_addr                    ),

    .i_d2d1rx_dpu_vld           (i_d2d1rx_dpu_vld                   ),
    .i_d2d1rx_dpu_addr          (i_d2d1rx_dpu_addr                  ),
    .i_d2d1rx_dpu_data          (i_d2d1rx_dpu_data                  ),
    .o_dpu_d2d1rx_rdy           (o_dpu_d2d1rx_rdy                   ),

    .o_rac_wr_req               (rac_wr_req                         ),
    .o_rac_rd_req               (rac_rd_req                         ),
    .o_rac_addr                 (rac_addr                           ),
    .o_rac_wdata                (rac_wdata                          ),
    .o_rac_wcrc                 (rac_wcrc                           ),

    .i_rac_wack                 (rac_wack                           ),
    .i_rac_rack                 (rac_rack                           ),
    .i_rac_data                 (rac_ack_data                       ),
    .i_rac_addr                 (rac_ack_addr                       ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

hv_owt_rx_ctrl U_HV_OWT_RX_CTRL(
    .i_lv_hv_owt_rx             (i_lv_hv_owt_rx                     ),
    .o_owt_rx_rac_vld           (owt_rx_rac_vld                     ),
    .o_owt_rx_rac_cmd           (owt_rx_rac_cmd                     ),
    .o_owt_rx_rac_data          (owt_rx_rac_data                    ),
    .o_owt_rx_rac_crc           (owt_rx_rac_crc                     ),
    .o_owt_rx_rac_status        (owt_rx_rac_status                  ),

    .o_owt_rx_rst_wdg_owt       (owt_rx_rst_wdg_owt                 ),
                         
    .i_reg_comerr_mode          (reg_com_config1.comerr_mode        ),
    .i_reg_comerr_config        (reg_com_config1.comerr_config      ),
    .o_owt_com_err              (owt_rx_reg_slv_owtcomerr           ),
       
    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
   
hv_reg_access_ctrl U_HV_REG_ACCESS_CTRL(
    .i_wdg_scan_rac_rd_req      (wdg_scan_rac_rd_req                ),
    .i_wdg_scan_rac_addr        (wdg_scan_rac_addr                  ),
    .o_rac_wdg_scan_ack         (rac_wdg_scan_ack                   ),
    .o_rac_wdg_scan_data        (rac_wdg_scan_data                  ),
    .o_rac_wdg_scan_crc         (rac_wdg_scan_crc                   ),

    .i_spi_rac_wr_req           (rac_wr_req                         ),
    .i_spi_rac_rd_req           (rac_rd_req                         ),
    .i_spi_rac_addr             (rac_addr                           ),
    .i_spi_rac_wdata            (rac_wdata                          ),
    .i_spi_rac_wcrc             (rac_wcrc                           ),

    .o_rac_spi_wack             (rac_wack                           ),
    .o_rac_spi_rack             (rac_rack                           ),
    .o_rac_spi_data             (rac_ack_data                       ),
    .o_rac_spi_addr             (rac_ack_addr                       ),

    .i_owt_rx_rac_vld           (owt_rx_rac_vld                     ),
    .i_owt_rx_rac_cmd           (owt_rx_rac_cmd                     ),
    .i_owt_rx_rac_data          (owt_rx_rac_data                    ),
    .i_owt_rx_rac_crc           (owt_rx_rac_crc                     ),
    .i_owt_rx_rac_status        (owt_rx_rac_status                  ),

    .o_rac_owt_tx_wr_cmd_vld    (rac_owt_tx_wr_cmd_vld              ),
    .o_rac_owt_tx_rd_cmd_vld    (rac_owt_tx_rd_cmd_vld              ),
    .o_rac_owt_tx_addr          (rac_owt_tx_addr                    ),
    .o_rac_owt_tx_data          (rac_owt_tx_data                    ),

    .i_adc1_data                (adc_data1                          ),
    .i_adc2_data                (adc_data2                          ),

    .o_rac_reg_ren              (rac_reg_ren                        ),
    .o_rac_reg_wen              (rac_reg_wen                        ),
    .o_rac_reg_addr             (rac_reg_addr                       ),
    .o_rac_reg_wdata            (rac_reg_wdata                      ),
    .o_rac_reg_wcrc             (rac_reg_wcrc                       ),

    .i_reg_rac_wack             (reg_rac_wack                       ),
    .i_reg_rac_rack             (reg_rac_rack                       ),
    .i_reg_rac_rdata            (reg_rac_rdata                      ),
    .i_reg_rac_rcrc             (reg_rac_rcrc                       ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
    
hv_owt_tx_ctrl U_HV_OWT_TX_CTRL(
    .i_rac_owt_tx_wr_cmd_vld    (rac_owt_tx_wr_cmd_vld              ),
    .i_rac_owt_tx_rd_cmd_vld    (rac_owt_tx_rd_cmd_vld              ),
    .i_rac_owt_tx_addr          (rac_owt_tx_addr                    ),
    .i_rac_owt_tx_data          (rac_owt_tx_data                    ),
    .o_hv_lv_owt_tx             (o_hv_lv_owt_tx                     ),
    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
   
hv_wdg_ctrl U_HV_WDG_CTRL(
    .i_wdg_scan_en              (wdg_scan_en                        ),
    .o_wdg_scan_rac_rd_req      (wdg_scan_rac_rd_req                ), //wdg_scan to rac, rac = reg_access_ctrl
    .o_wdg_scan_rac_addr        (wdg_scan_rac_addr                  ),
    .i_rac_wdg_scan_ack         (rac_wdg_scan_ack                   ),
    .i_rac_wdg_scan_data        (rac_wdg_scan_data                  ),
    .i_rac_wdg_scan_crc         (rac_wdg_scan_crc                   ),
    .o_wdg_scan_crc_err         (wdg_scan_reg_slv_crcerr            ),

    .i_bist_scan_reg_req        (bist_scan_reg_req                  ),
    .o_scan_reg_bist_ack        (scan_reg_bist_ack                  ),
    .o_scan_reg_bist_err        (scan_reg_bist_err                  ),

    .i_wdg_owt_en               (wdg_owt_en                         ),
    .i_owt_rx_rst_wdg_owt       (owt_rx_rst_wdg_owt                 ),

    .o_wdg_timeout_err          (wdg_owt_reg_slv_tmoerr             ),

    .i_wdgtmo_config            (reg_com_config2.hv_wdgtmo_config   ),
    .i_wdgcrc_config            (reg_com_config2.wdgcrc_config      ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
    
hv_analog_int_proc U_HV_ANALOG_INT_PRO(
    .i_hv_vcc_uv                (i_hv_vcc_uv                        ),
    .i_hv_vcc_ov                (i_hv_vcc_ov                        ),
    .i_hv_ot                    (i_hv_ot                            ),
    .i_hv_oc                    (i_hv_oc                            ),
    .i_hv_desat_flt             (i_hv_desat_flt                     ),
    .i_hv_scp_flt               (i_hv_scp_flt                       ),

    .o_hv_vcc_uverr             (hv_vcc_uverr                       ),
    .o_hv_vcc_overr             (hv_vcc_overr                       ),
    .o_hv_ot_err                (hv_ot_err                          ),
    .o_hv_oc_err                (hv_oc_err                          ),
    .o_hv_desat_err             (hv_desat_err                       ),
    .o_hv_scp_err               (hv_scp_err                         ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

assign hv_bist_fail = |(hv_bist1 | hv_bist2);    

assign hv_status1 = {hv_bist_fail, 1'b0, 1'b0, 1'b0,
                     wdg_owt_reg_slv_tmoerr, owt_rx_reg_slv_owtcomerr, wdg_scan_reg_slv_crcerr, spi_reg_slv_err};
    
assign hv_status2 = {hv_scp_err, hv_desat_err, hv_oc_err, hv_ot_err,
                     hv_vcc_overr, hv_vcc_uverr, 1'b0, 1'b0} & {8{hv_ctrl_cur_st!=BIST_ST}};

assign vrtmon  = reg_com_config1.rtmon ? ~vge_vce : vge_vce;
assign o_rtmon = reg_com_config1.rtmon;                 
                     
assign hv_status3 = {vrtmon,     io_fsiso,   io_pwma, io_pwm,
                     io_fsstate, io_fsenb_n, io_intb, io_inta};
    
assign hv_status4 = {hv_ctrl_cur_st, 4'b0};   

hv_ang_val_sample U_HV_ANG_VAL_SAMPLE(
    .i_off_vbn_read                 (i_off_vbn_read                     ),
    .i_on_vbn_read                  (i_on_vbn_read                      ),
    .i_cnt_del_read                 (i_cnt_del_read                     ),
    .i_reg_dvdt_tm                  (o_reg_dvdt_tm                      ),

    .o_cap_trim_code_read           (cap_trim_code_read                 ),
    .o_cnt_del_read                 (cnt_del_read                       ),

    .i_clk                          (i_clk                              ),
    .i_rst_n                        (i_rst_n                            )
);

hv_reg_slv U_HV_REG_SLV(
    .i_spi_reg_ren                  (rac_reg_ren                        ),
    .i_spi_reg_wen                  (rac_reg_wen                        ),
    .i_spi_reg_addr                 (rac_reg_addr                       ),
    .i_spi_reg_wdata                (rac_reg_wdata                      ),
    .i_spi_reg_wcrc                 (rac_reg_wcrc                       ),

    .o_reg_spi_wack                 (reg_rac_wack                       ),
    .o_reg_spi_rack                 (reg_rac_rack                       ),
    .o_reg_spi_rdata                (reg_rac_rdata                      ),
    .o_reg_spi_rcrc                 (reg_rac_rcrc                       ),

    .i_hv_status1                   (hv_status1                         ),
    .i_hv_status2                   (hv_status2                         ),
    .i_hv_status3                   (hv_status3                         ),
    .i_hv_status4                   (hv_status4                         ),
    .i_hv_bist1                     (hv_bist1                           ),
    .i_hv_bist2                     (hv_bist2                           ),

    .i_cap_trim_code_read           (cap_trim_code_read                 ),
    .i_cnt_del_read                 (cnt_del_read                       ),

    .o_efuse_wmode                  (o_efuse_wmode                      ),
    .o_efuse_wr_p                   (o_efuse_wr_p                       ),
    .o_efuse_rd_p                   (o_efuse_rd_p                       ),
    .o_efuse_addr                   (o_efuse_addr                       ),
    .o_efuse_wdata0                 (o_efuse_wdata0                     ),
    .o_efuse_wdata1                 (o_efuse_wdata1                     ),
    .o_efuse_wdata2                 (o_efuse_wdata2                     ),
    .o_efuse_wdata3                 (o_efuse_wdata3                     ),
    .o_efuse_wdata4                 (o_efuse_wdata4                     ),
    .o_efuse_wdata5                 (o_efuse_wdata5                     ),
    .o_efuse_wdata6                 (o_efuse_wdata6                     ),
    .o_efuse_wdata7                 (o_efuse_wdata7                     ),
    .o_efuse_wdata8                 (o_efuse_wdata8                     ),
    .o_efuse_wdata9                 (o_efuse_wdata9                     ),
    .o_efuse_wdata10                (o_efuse_wdata10                    ),
    .o_efuse_wdata11                (o_efuse_wdata11                    ),
    .o_efuse_wdata12                (o_efuse_wdata12                    ),
    .o_efuse_wdata13                (o_efuse_wdata13                    ),
    .o_efuse_wdata14                (o_efuse_wdata14                    ),
    .o_efuse_wdata15                (o_efuse_wdata15                    ),

    .i_efuse_op_finish              (efuse_op_finish                    ),
    .i_efuse_reg_update             (efuse_reg_update                   ),
    .i_efuse_reg_data               (efuse_reg_data                     ),

    .o_reg_mode                     (reg_mode                           ),
    .o_reg_com_config1              (reg_com_config1                    ),
    .o_reg_com_config2              (reg_com_config2                    ),
    .o_reg_status1                  (reg_status1                        ),
    .o_reg_status2                  (reg_status2                        ),
    .o_reg_die2_efuse_config        (reg_die2_efuse_config              ),
    .o_reg_die2_efuse_status        (reg_die2_efuse_status              ),

    .o_reg_iso_bgr_trim             (o_reg_iso_bgr_trim                 ),
    .o_reg_iso_con_ibias_trim       (o_reg_iso_con_ibias_trim           ),
    .o_reg_iso_osc48m_trim          (o_reg_iso_osc48m_trim              ),
    .o_reg_iso_oscb_freq_adj        (o_reg_iso_oscb_freq_adj            ),
    .o_reg_iso_reserved_reg         (o_reg_iso_reserved_reg             ),
    .o_reg_iso_amp_ibias            (o_reg_iso_amp_ibias                ),
    .o_reg_iso_demo_trim            (o_reg_iso_demo_trim                ),
    .o_reg_iso_test_sw              (o_reg_iso_test_sw                  ),
    .o_reg_iso_osc_jit              (o_reg_iso_osc_jit                  ),
    .o_reg_ana_reserved_reg2        (o_reg_ana_reserved_reg2            ),
    .o_reg_config1_dr_src_snk_both  (o_reg_config1_dr_src_snk_both      ),
    .o_reg_config2_dr_src_sel       (o_reg_config2_dr_src_sel           ),
    .o_reg_config3_dri_snk_sel      (o_reg_config3_dri_snk_sel          ),
    .o_reg_config4_tltoff_sel1      (o_reg_config4_tltoff_sel1          ),
    .o_reg_config5_tltoff_sel2      (o_reg_config5_tltoff_sel2          ),
    .o_reg_config6_desat_sel1       (o_reg_config6_desat_sel1           ),
    .o_reg_config7_desat_sel2       (o_reg_config7_desat_sel2           ),
    .o_reg_config8_oc_sel           (o_reg_config8_oc_sel               ),
    .o_reg_config9_sc_sel           (o_reg_config9_sc_sel               ),
    .o_reg_config10_dvdt_ref_src    (o_reg_config10_dvdt_ref_src        ),
    .o_reg_config11_dvdt_ref_sink   (o_reg_config11_dvdt_ref_sink       ),
    .o_reg_config12_adc_en          (o_reg_config12_adc_en              ),
    .o_reg_bgr_code_drv             (o_reg_bgr_code_drv                 ),
    .o_reg_cap_trim_code            (o_reg_cap_trim_code                ),     
    .o_reg_csdel_cmp                (o_reg_csdel_cmp                    ), 
    .o_reg_dvdt_value_adj           (o_reg_dvdt_value_adj               ), 
    .o_reg_adc_adj1                 (o_reg_adc_adj1                     ), 
    .o_reg_adc_adj2                 (o_reg_adc_adj2                     ), 
    .o_reg_ibias_code_drv           (o_reg_ibias_code_drv               ),
    .o_reg_dvdt_tm                  (o_reg_dvdt_tm                      ), 
    .o_reg_dvdt_win_value_en        (o_reg_dvdt_win_value_en            ), 
    .o_reg_preset_delay             (o_reg_preset_delay                 ), 
    .o_reg_drive_delay_set          (o_reg_drive_delay_set              ),
    .o_reg_cmp_del                  (o_reg_cmp_del                      ),
    .o_reg_test_mux                 (o_reg_test_mux                     ), 
    .o_reg_cmp_adj_vreg             (o_reg_cmp_adj_vreg                 ), 
    
    .i_test_st_reg_en               (test_st_reg_en                     ),
    .i_cfg_st_reg_en                (cfg_st_reg_en                      ),
    .i_spi_ctrl_reg_en              (spi_ctrl_reg_en                    ),
    .i_efuse_ctrl_reg_en            (efuse_ctrl_reg_en                  ),

    .i_clk                          (i_clk                              ),
    .i_hrst_n                       (i_rst_n                            ),
    .o_rst_n                        (                                   )
);

assign o_adc1_en = reg_mode.adc1_en;
assign o_adc2_en = reg_mode.adc2_en;
        
hv_ctrl_unit U_HV_CTRL_UNIT(
    .i_pwr_on                   (1'b1                               ),
    .i_io_test_mode             (io_test_mode                       ),
    .i_reg_efuse_vld            (o_reg_ibias_code_drv.d2_efuse_vld  ),
    .i_reg_efuse_done           (reg_mode.efuse_done                ),//soft lanch, make test_st -> wait_st
    .i_io_fsiso                 (io_fsiso                           ),
    .i_fsiso_en                 (reg_mode.fsiso_en                  ),
    .i_reg_spi_err              (reg_status1[0]                     ),
    .i_reg_scan_crc_err         (reg_status1[1]                     ),    
    .i_reg_owt_com_err          (reg_status1[2]                     ),
    .i_reg_wdg_tmo_err          (reg_status1[3]                     ),//tmo = timeout
    .i_reg_bist_fail            (reg_status1[7]                     ),
    .i_reg_hv_vcc_uverr         (reg_status2[2]                     ),
    .i_reg_hv_vcc_overr         (reg_status2[3]                     ),
    .i_reg_hv_ot_err            (reg_status2[4]                     ),
    .i_reg_hv_oc_err            (reg_status2[5]                     ),
    .i_reg_hv_desat_err         (reg_status2[6]                     ),
    .i_reg_hv_scp_err           (reg_status2[7]                     ),

    .i_reg_nml_en               (reg_mode.normal_en                 ),
    .i_reg_cfg_en               (reg_mode.cfg_en                    ),
    .i_reg_bist_en              (reg_mode.bist_en                   ),
    .i_reg_rst_en               (reg_mode.reset_en                  ),

    .o_pwm_en                   (o_dgt_ang_pwm_en                   ),
    .o_fsiso_en                 (o_dgt_ang_fsiso_en                 ),
    .o_wdg_scan_en              (wdg_scan_en                        ),
    .o_spi_en                   (fsm_spi_slv_en                     ),
    .o_owt_com_en               (wdg_owt_en                         ),
    .o_cfg_st_reg_en            (cfg_st_reg_en                      ),//when in cfg_st support reg read & write.
    .o_test_st_reg_en           (test_st_reg_en                     ),//when in test_st support reg read & write.
    .o_spi_ctrl_reg_en          (spi_ctrl_reg_en                    ),//when spi enable support reg read & write.
    .o_efuse_ctrl_reg_en        (efuse_ctrl_reg_en                  ),
    .o_bist_en                  (bist_en                            ),
    .o_fsm_ang_test_en          (o_fsm_ang_test_en                  ),//ctrl analog mdl into test mode.
    .o_aout_wait                (                                   ),
    .o_aout_bist                (                                   ),

    .o_intb_n                   (intb_n                             ),

    .o_efuse_load_req           (o_efuse_load_req                   ),
    .i_efuse_load_done          (i_efuse_load_done                  ), //hardware lanch, indicate efuse have load done.
        
    .o_hv_ctrl_cur_st           (hv_ctrl_cur_st                     ),
    .i_hv_bist_done             (hv_bist_done                       ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

hv_pwm_intb_encode U_HV_PWM_INTB_ENCODE(
    .i_hv_intb_n                (intb_n                             ),
    .i_hv_pwm_gwave             (vge_vce                            ),
    .i_wdgintb_en               (1'b1                               ),
    .i_wdgintb_config           (reg_com_config1.wdgintb_config     ),
    .o_hv_pwm_intb_n            (o_pwmn_intb                        ),
    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
   
hv_abist U_HV_ABIST(
    .i_bist_en                  (bist_en                            ),

    .o_bist_hv_ov               (o_bist_hv_ov                       ),
    .i_hv_vcc_ov                (hv_vcc_overr                       ),

    .o_bist_hv_ot               (o_bist_hv_ot                       ),
    .i_hv_ot                    (hv_ot_err                          ),

    .o_bist_hv_opscod           (o_bist_hv_opscod                   ),
    .i_hv_desat_flt             (hv_desat_err                       ),

    .o_bist_hv_oc               (o_bist_hv_oc                       ),
    .i_hv_oc                    (hv_oc_err                          ),

    .o_bist_hv_sc               (o_bist_hv_sc                       ),
    .i_hv_scp_flt               (hv_scp_err                         ),

    .o_bist_hv_adc              (o_bist_hv_adc                      ),
    .i_hv_adc_rdy1              (i_adc_ready1                       ),
    .i_hv_adc_data1             (i_adc_data1                        ),
    .i_hv_adc_rdy2              (i_adc_ready2                       ),
    .i_hv_adc_data2             (i_adc_data2                        ),

    .o_bist_hv_ov_status        (hv_bist1[1]                        ),
    .o_bist_hv_ot_status        (hv_bist1[2]                        ),
    .o_bist_hv_opscod_status    (hv_bist1[3]                        ),
    .o_bist_hv_oc_status        (hv_bist1[4]                        ),
    .o_bist_hv_sc_status        (hv_bist1[5]                        ),
    .o_bist_hv_adc_status       (hv_bist1[6]                        ),

    .o_lbist_en                 (lbist_en                           ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

assign hv_bist1[0] = 1'b0;
assign hv_bist1[7] = 1'b0;

assign hv_bist2[0] = 1'b0;
assign hv_bist2[1] = 1'b0;
assign hv_bist2[2] = 1'b0;
assign hv_bist2[5] = 1'b0;
assign hv_bist2[6] = 1'b0;
assign hv_bist2[7] = 1'b0;
    
hv_lbist U_HV_LBIST(
    .i_bist_en                      (bist_en                            ),

    .i_owt_rx_ack                   (owt_rx_rac_vld                     ),
    .i_owt_rx_status                (owt_rx_rac_status                  ),
    .o_hv_owt_bist_rult             (hv_bist2[3]                        ),

    .o_bist_scan_reg_req            (bist_scan_reg_req                  ),
    .i_scan_reg_bist_ack            (scan_reg_bist_ack                  ),
    .i_scan_reg_bist_err            (scan_reg_bist_err                  ),
    .o_hv_scan_bist_rult            (hv_bist2[4]                        ),

    .o_hv_bist_done                 (hv_bist_done                       ),

    .i_clk                          (i_clk                              ),
    .i_rst_n                        (i_rst_n                            )
);
    
hv_adc_sample U_HV_ADC_SAMPLE(
    .i_ang_dgt_adc1_rdy             (i_adc_ready1                       ), //analog to digtial
    .i_ang_dgt_adc1_data            (i_adc_data1                        ),
    .o_adc1_equ_data                (adc_data1                          ),

    .i_ang_dgt_adc2_rdy             (i_adc_ready2                       ), 
    .i_ang_dgt_adc2_data            (i_adc_data2                        ),
    .o_adc2_equ_data                (adc_data2                          ),

    .i_clk                          (i_clk                              ),
    .i_rst_n                        (i_rst_n                            )
);


assign o_io_efuse_setb    = setb               ;
assign efuse_op_finish    = i_efuse_op_finish  ;
assign efuse_reg_update   = i_efuse_reg_update ;
assign efuse_reg_data[0]  = i_efuse_reg_data0  ;
assign efuse_reg_data[1]  = i_efuse_reg_data1  ;
assign efuse_reg_data[2]  = i_efuse_reg_data2  ;
assign efuse_reg_data[3]  = i_efuse_reg_data3  ;
assign efuse_reg_data[4]  = i_efuse_reg_data4  ;
assign efuse_reg_data[5]  = i_efuse_reg_data5  ;
assign efuse_reg_data[6]  = i_efuse_reg_data6  ;
assign efuse_reg_data[7]  = i_efuse_reg_data7  ;
assign efuse_reg_data[8]  = i_efuse_reg_data8  ;
assign efuse_reg_data[9]  = i_efuse_reg_data9  ;
assign efuse_reg_data[10] = i_efuse_reg_data10 ;
assign efuse_reg_data[11] = i_efuse_reg_data11 ;
assign efuse_reg_data[12] = i_efuse_reg_data12 ;
assign efuse_reg_data[13] = i_efuse_reg_data13 ;
assign efuse_reg_data[14] = i_efuse_reg_data14 ;
assign efuse_reg_data[15] = i_efuse_reg_data15 ;


assign o_spi_s16pin_wr_req = ~i_s32_16 ? spi_wr_req : 1'b0 ;
assign o_spi_s16pin_rd_req = ~i_s32_16 ? spi_rd_req : 1'b0 ;
assign o_spi_s16pin_addr   = ~i_s32_16 ? spi_addr   : 7'b0 ; 
assign o_spi_s16pin_wdata  = ~i_s32_16 ? spi_wdata  : 8'b0 ;
assign o_spi_s16pin_wcrc   = ~i_s32_16 ? spi_wcrc   : 8'b0 ;

assign spi_s32pin_wr_req   =  i_s32_16 ? spi_wr_req : 1'b0 ;
assign spi_s32pin_rd_req   =  i_s32_16 ? spi_rd_req : 1'b0 ;
assign spi_s32pin_addr     =  i_s32_16 ? spi_addr   : 7'b0 ; 
assign spi_s32pin_wdata    =  i_s32_16 ? spi_wdata  : 8'b0 ;
assign spi_s32pin_wcrc     =  i_s32_16 ? spi_wcrc   : 8'b0 ;

assign spi_wack            = ~i_s32_16 ? i_s16pin_spi_wack : s32pin_spi_wack ;
assign spi_rack            = ~i_s32_16 ? i_s16pin_spi_rack : s32pin_spi_rack ;
assign spi_ack_data        = ~i_s32_16 ? i_s16pin_spi_data : s32pin_spi_data ;
assign spi_ack_addr        = ~i_s32_16 ? i_s16pin_spi_addr : s32pin_spi_addr ;
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    




    




    




    




    




    




    




    



