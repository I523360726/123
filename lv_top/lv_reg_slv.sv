//============================================================
//Module   : lv_reg_slv
//Function : regsiter instance & access ctrl.
//File Tree: lv_reg_slv
//            |--ro_reg
//            |--rw_reg
//            |--rwc_reg
//            |--wo_reg
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_reg_slv import com_pkg::*; import lv_pkg::*;
#(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)(
    //spi reg access interface 
    input  logic                                        i_spi_reg_ren                   ,
    input  logic                                        i_spi_reg_wen                   ,
    input  logic [REG_AW-1:         0]                  i_spi_reg_addr                  ,
    input  logic [REG_DW-1:         0]                  i_spi_reg_wdata                 ,
    input  logic [REG_CRC_W-1:      0]                  i_spi_reg_wcrc                  ,

    output logic                                        o_reg_spi_wack                  ,
    output logic                                        o_reg_spi_rack                  ,
    output logic [REG_DW-1:         0]                  o_reg_spi_rdata                 ,
    output logic [REG_CRC_W-1:      0]                  o_reg_spi_rcrc                  ,
    
    //inner flop-flip data
    input logic [REG_DW-1:         0]                   i_lv_status1                    ,
    input logic [REG_DW-1:         0]                   i_lv_status2                    ,
    input logic [REG_DW-1:         0]                   i_lv_status3                    ,
    input logic [REG_DW-1:         0]                   i_lv_status4                    ,
    input logic [REG_DW-1:         0]                   i_lv_bist1                      ,
    input logic [REG_DW-1:         0]                   i_lv_bist2                      ,

    input  str_reg_efuse_config                         i_reg_die2_efuse_config         ,
    input  str_reg_efuse_status                         i_reg_die2_efuse_status         ,
   
    input logic [REG_DW-1:         0]                   i_hv_status1                    ,
    input logic [REG_DW-1:         0]                   i_hv_status2                    ,
    input logic [REG_DW-1:         0]                   i_hv_status3                    ,
    input logic [REG_DW-1:         0]                   i_hv_status4                    ,
    input logic [ADC_DW-1:         0]                   i_hv_adc1_data                  ,
    input logic [ADC_DW-1:         0]                   i_hv_adc2_data                  ,
    input logic [REG_DW-1:         0]                   i_hv_bist1                      ,
    input logic [REG_DW-1:         0]                   i_hv_bist2                      ,
  
    output logic                                        o_efuse_wmode                   ,
    output logic                                        o_efuse_wr_p                    ,
    output logic                                        o_efuse_rd_p                    ,
    output logic [5:       0]                           o_efuse_addr                    ,
    output logic [7:       0]                           o_efuse_wdata0                  ,
    output logic [7:       0]                           o_efuse_wdata1                  ,
    output logic [7:       0]                           o_efuse_wdata2                  ,
    output logic [7:       0]                           o_efuse_wdata3                  ,
    output logic [7:       0]                           o_efuse_wdata4                  ,
    output logic [7:       0]                           o_efuse_wdata5                  ,
    output logic [7:       0]                           o_efuse_wdata6                  ,
    output logic [7:       0]                           o_efuse_wdata7                  ,

    input logic                                         i_efuse_op_finish               ,
    input logic                                         i_efuse_reg_update              ,
    input logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]    i_efuse_reg_data                ,

    //output to inner logic
    output str_reg_mode                                 o_reg_mode                      ,
    output str_reg_com_config1                          o_reg_com_config1               ,
    output str_reg_com_config2                          o_reg_com_config2               ,
    output str_reg_status1                              o_reg_status1                   ,
    output str_reg_status2                              o_reg_status2                   ,

    output str_reg_iso_bgr_trim                         o_reg_iso_bgr_trim              ,
    output str_reg_iso_con_ibias_trim                   o_reg_iso_con_ibias_trim        ,
    output str_reg_iso_osc48m_trim                      o_reg_iso_osc48m_trim           ,
    output str_reg_iso_oscb_freq_adj                    o_reg_iso_oscb_freq_adj         ,
    output str_reg_iso_reserved_reg                     o_reg_iso_reserved_reg          ,
    output str_reg_iso_amp_ibias                        o_reg_iso_amp_ibias             ,
    output str_reg_iso_demo_trim                        o_reg_iso_demo_trim             ,
    output str_reg_iso_test_sw                          o_reg_iso_test_sw               ,
    output str_reg_iso_osc_jit                          o_reg_iso_osc_jit               ,
    output logic [7:    0]                              o_reg_ana_reserved_reg          ,
    output str_reg_config0_t_deat_time                  o_reg_config0_t_deat_time       ,
    
    input  logic                                        i_test_st_reg_en                ,
    input  logic                                        i_cfg_st_reg_en                 ,
    input  logic                                        i_spi_ctrl_reg_en               ,
    input  logic                                        i_efuse_ctrl_reg_en             ,
    input  logic                                        i_clk                           ,
    input  logic                                        i_hrst_n                        ,
    output logic                                        o_rst_n                     
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                  rst_n                            ;

logic                  spi_reg_wen                      ;
logic                  spi_reg_wen_ff                   ;
logic                  spi_reg_ren                      ;
logic                  spi_reg_ren_ff                   ;
logic [REG_AW-1:    0] spi_reg_addr                     ;
logic [REG_DW-1:    0] spi_reg_wdata                    ;
logic [REG_CRC_W-1: 0] spi_reg_wcrc                     ;
logic                  reg_spi_rack                     ;
logic [REG_DW-1:    0] reg_spi_rdata                    ;
logic [REG_CRC_W-1: 0] reg_spi_rcrc                     ;

logic                  com_reg_wack                     ;
logic                  com_reg_rack                     ;
logic [REG_DW-1:    0] com_reg_rdata                    ;
logic [REG_CRC_W-1: 0] com_reg_rcrc                     ;

logic [REG_DW-1:    0] merge_status1                    ;
logic [REG_DW-1:    0] merge_status2                    ;
logic [REG_DW-1:    0] merge_status3                    ;
logic [REG_DW-1:    0] merge_status4                    ;
logic [REG_DW-1:    0] merge_bist1                      ;
logic [REG_DW-1:    0] merge_bist2                      ;
logic [REG_DW-1:    0] reg_status1                      ;
logic [REG_DW-1:    0] reg_mask1                        ;
logic [REG_DW-1:    0] reg_status2                      ;
logic [REG_DW-1:    0] reg_mask2                        ;

logic [REG_DW-1:    0] rdata_die1_efuse_config          ;
logic [REG_DW-1:    0] rdata_die1_efuse_status          ;
logic [REG_DW-1:    0] rdata_die2_efuse_config          ;
logic [REG_DW-1:    0] rdata_die2_efuse_status          ;
logic [REG_DW-1:    0] rdata_status3                    ;
logic [REG_DW-1:    0] rdata_status4                    ;
logic [REG_DW-1:    0] rdata_adc1_data_low              ;
logic [REG_DW-1:    0] rdata_adc1_data_hig              ;
logic [REG_DW-1:    0] rdata_adc2_data_low              ;
logic [REG_DW-1:    0] rdata_adc2_data_hig              ;
logic [REG_DW-1:    0] rdata_bist_rult1                 ;
logic [REG_DW-1:    0] rdata_bist_rult2                 ;
logic [REG_DW-1:    0] rdata_adc_status                 ;
logic [REG_DW-1:    0] rdata_die1_id                    ;
logic [REG_DW-1:    0] rdata_die2_id                    ;
logic [REG_DW-1:    0] rdata_die3_id                    ;
logic [REG_DW-1:    0] rdata_iso_bgr_trim               ;
logic [REG_DW-1:    0] rdata_iso_con_ibias_trim         ;
logic [REG_DW-1:    0] rdata_iso_osc48m_trim            ;
logic [REG_DW-1:    0] rdata_iso_oscb_freq_adj          ;
logic [REG_DW-1:    0] rdata_iso_reserved_reg           ;
logic [REG_DW-1:    0] rdata_die1_id_efuse              ;
logic [REG_DW-1:    0] rdata_die2_id_efuse              ;
logic [REG_DW-1:    0] rdata_die3_id_efuse              ;
logic [REG_DW-1:    0] rdata_iso_bgr_trim_efuse         ;
logic [REG_DW-1:    0] rdata_iso_con_ibias_trim_efuse   ;
logic [REG_DW-1:    0] rdata_iso_osc48m_trim_efuse      ;
logic [REG_DW-1:    0] rdata_iso_oscb_freq_adj_efuse    ;
logic [REG_DW-1:    0] rdata_iso_reserved_reg_efuse     ;
logic [REG_DW-1:    0] rdata_iso_amp_ibias              ;
logic [REG_DW-1:    0] rdata_iso_demo_trim              ;
logic [REG_DW-1:    0] rdata_iso_test_sw                ;
logic [REG_DW-1:    0] rdata_iso_osc_jit                ;
logic [REG_DW-1:    0] rdata_ana_reserved_reg           ;
logic [REG_DW-1:    0] rdata_config0_t_deat_time        ;
logic [REG_CRC_W-1: 0] rcrc_config0_t_deat_time         ;

logic [REG_DW-1:    0] reg_die1_efuse_config            ;
logic [REG_DW-1:    0] reg_die1_efuse_status            ;
logic [REG_DW-1:    0] die1_efuse_status_wdata          ;
logic [REG_DW-1:    0] reg_die1_id                      ;
logic [REG_DW-1:    0] reg_die2_id                      ;
logic [REG_DW-1:    0] reg_die3_id                      ;
logic [REG_DW-1:    0] reg_iso_bgr_trim                 ;
logic [REG_DW-1:    0] reg_iso_con_ibias_trim           ;
logic [REG_DW-1:    0] reg_iso_osc48m_trim              ;
logic [REG_DW-1:    0] reg_iso_oscb_freq_adj            ;
logic [REG_DW-1:    0] reg_iso_reserved_reg             ;
logic [REG_DW-1:    0] reg_iso_amp_ibias                ;
logic [REG_DW-1:    0] reg_iso_demo_trim                ;
logic [REG_DW-1:    0] reg_iso_test_sw                  ;
logic [REG_DW-1:    0] reg_iso_osc_jit                  ;
logic [REG_DW-1:    0] reg_ana_reserved_reg             ;
logic [REG_DW-1:    0] reg_config0_t_deat_time          ;

localparam integer EFUSE_REG_ADDR[EFUSE_DATA_NUM-1: 0]  = {7'h27,7'h26,7'h25,7'h24,7'h23,7'h22,7'h21,7'h20};
logic   hit_rd_efuse        ;
logic   spi_read_efuse_en   ;
logic   efuse_local_reg_rd  ;
logic   efuse_remote_reg_rd ;

//==================================
//main code
//==================================
assign spi_read_efuse_en = reg_die1_efuse_status[3];

always_comb begin : HIT_RD_EFUSE_BLK
    hit_rd_efuse = 1'b0;
    for(integer i=0; i<EFUSE_DATA_NUM; i=i+1) begin: GEN_HIT_RD_EFUSE
        hit_rd_efuse = hit_rd_efuse | ((spi_reg_addr==EFUSE_REG_ADDR[i]) & spi_read_efuse_en);
    end    
end

assign efuse_local_reg_rd  = spi_reg_ren & ~hit_rd_efuse;
assign efuse_remote_reg_rd = spi_reg_ren &  hit_rd_efuse;

assign merge_status1[7: 2] = i_lv_status1[7: 2] | i_hv_status1[7: 2];
assign merge_status1[1: 0] = i_lv_status1[1: 0] & i_hv_status1[1: 0];
assign merge_status2       = i_lv_status2 | i_hv_status2; 

assign o_reg_status1 = reg_status1 & ~reg_mask1 ;
assign o_reg_status2 = reg_status2 & ~reg_mask2 ;

com_reg_bank U_LV_COM_REG_BANK(
    .i_spi_reg_ren                 (spi_reg_ren             ),
    .i_spi_reg_wen                 (spi_reg_wen             ),
    .i_spi_reg_addr                (spi_reg_addr            ),
    .i_spi_reg_wdata               (spi_reg_wdata           ),
    .i_spi_reg_wcrc                (spi_reg_wcrc            ),

    .o_reg_spi_wack                (com_reg_wack            ),
    .o_reg_spi_rack                (com_reg_rack            ),
    .o_reg_spi_rdata               (com_reg_rdata           ),
    .o_reg_spi_rcrc                (com_reg_rcrc            ),
        
    .i_int_status1                 (merge_status1           ),
    .i_int_status2                 (merge_status2           ),

    .o_reg_mode                    (o_reg_mode              ),
    .o_reg_com_config1             (o_reg_com_config1       ),
    .o_reg_com_config2             (o_reg_com_config2       ),
    .o_reg_status1                 (reg_status1             ),
    .o_reg_mask1                   (reg_mask1               ),
    .o_reg_status2                 (reg_status2             ),
    .o_reg_mask2                   (reg_mask2               ),

    .i_test_st_reg_en              (i_test_st_reg_en        ),
    .i_cfg_st_reg_en               (i_cfg_st_reg_en         ),
    .i_spi_ctrl_reg_en             (i_spi_ctrl_reg_en       ),
    .i_efuse_ctrl_reg_en           (i_efuse_ctrl_reg_en     ),
    .i_clk                         (i_clk                   ),
    .i_hrst_n                      (i_hrst_n                ),
    .o_rst_n                       (rst_n                   )
);

assign o_rst_n = rst_n;
    
//DIE1_EFUSE_CONFIG REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h04      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DIE1_EFUSE_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die1_efuse_config                      ),
    .o_reg_data           (reg_die1_efuse_config                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wmode  = reg_die1_efuse_config[7: 7] ;
assign o_efuse_addr   = reg_die1_efuse_config[5: 0] ;

//DIE1_EFUSE_STATUS REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h05      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE1_EFUSE_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_die1_efuse_status                      ),
    .o_reg_data           (reg_die1_efuse_status                        ),
    .i_lgc_wen            (i_efuse_op_finish                            ),
    .i_lgc_wdata          (die1_efuse_status_wdata                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign  die1_efuse_status_wdata[0]      = 1'b1                          ;
assign  die1_efuse_status_wdata[1]      = 1'b0                          ;
assign  die1_efuse_status_wdata[2]      = 1'b0                          ;
assign  die1_efuse_status_wdata[7: 3]   = reg_die1_efuse_status[7: 3]   ;

assign  o_efuse_wr_p = reg_die1_efuse_status[2]                                             ;
assign  o_efuse_rd_p = (reg_die1_efuse_status[1] & spi_read_efuse_en) | efuse_remote_reg_rd ; 


//DIE2_EFUSE_CONFIG REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h06      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_DIE2_EFUSE_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_reg_die2_efuse_config                      ),
    .o_rdata              (rdata_die2_efuse_config                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE2_EFUSE_STATUS REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h07      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_DIE2_EFUSE_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_reg_die2_efuse_status                      ),
    .o_rdata              (rdata_die2_efuse_status                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//STATUS3 REGISTER
assign merge_status3 = i_lv_status3 | i_hv_status3;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h0C      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_STATUS3(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (merge_status3                                ),
    .o_rdata              (rdata_status3                                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//STATUS4 REGISTER
assign merge_status4 = i_lv_status4 | i_hv_status4;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h0D      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_STATUS4(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (merge_status4                                ),
    .o_rdata              (rdata_status4                                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC1_DATA_LOW REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h10      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC1_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_hv_adc1_data[7:0]                          ),
    .o_rdata              (rdata_adc1_data_low                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC1_DATA_HIG REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h11      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC1_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({6'b0, i_hv_adc1_data[9:8]}                  ),
    .o_rdata              (rdata_adc1_data_hig                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC2_DATA_LOW REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h12      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC2_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_hv_adc2_data[7:0]                          ),
    .o_rdata              (rdata_adc2_data_low                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC2_DATA_HIG REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h13      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC2_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({6'b0, i_hv_adc2_data[9:8]}                  ),
    .o_rdata              (rdata_adc2_data_hig                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//BIST_RESULT1 REGISTER
assign merge_bist1 = i_lv_bist1 | i_hv_bist1;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h14      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_BIST_RESULT1(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (merge_bist1                                  ),
    .o_rdata              (rdata_bist_rult1                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//BIST_RESULT2 REGISTER
assign merge_bist2 = i_lv_bist2 | i_hv_bist2;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h15      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_BIST_RESULT2(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (merge_bist2                                  ),
    .o_rdata              (rdata_bist_rult2                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC_REQ REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC_REQ(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (8'h00                                        ),
    .o_rdata              (rdata_adc_status                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE1_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h20      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE1_ID(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_die1_id                                ),
    .o_reg_data           (reg_die1_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[0]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata0 = reg_die1_id;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h20      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_DIE1_ID_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[0]                          ),
    .o_rdata              (rdata_die1_id_efuse                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE2_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h21      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE2_ID(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_die2_id                                ),
    .o_reg_data           (reg_die2_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[1]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata1 = reg_die2_id;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h21      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_DIE2_ID_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[1]                          ),
    .o_rdata              (rdata_die2_id_efuse                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE3_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h22      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE3_ID(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_die3_id                                ),
    .o_reg_data           (reg_die3_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[2]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata2 = reg_die3_id;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h22      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_DIE3_ID_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[2]                          ),
    .o_rdata              (rdata_die3_id_efuse                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_BGR_TRIM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h23      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_BGR_TRIM(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_iso_bgr_trim                           ),
    .o_reg_data           (reg_iso_bgr_trim                             ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[3]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata3     = reg_iso_bgr_trim;
assign o_reg_iso_bgr_trim = reg_iso_bgr_trim;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h23      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_ISO_BGR_TRIM_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[3]                          ),
    .o_rdata              (rdata_iso_bgr_trim_efuse                     ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_CON_IBIAS_TRM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h24      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_CON_IBIAS_TRM(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_iso_con_ibias_trim                     ),
    .o_reg_data           (reg_iso_con_ibias_trim                       ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[4]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata4           = reg_iso_con_ibias_trim;
assign o_reg_iso_con_ibias_trim = reg_iso_con_ibias_trim;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h24      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_ISO_CON_IBIAS_TRM_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[4]                          ),
    .o_rdata              (rdata_iso_con_ibias_trim_efuse               ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_OSC48M_TRIM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h25      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_OSC48M_TRIM(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_iso_osc48m_trim                        ),
    .o_reg_data           (reg_iso_osc48m_trim                          ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[5]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata5        = reg_iso_osc48m_trim;
assign o_reg_iso_osc48m_trim = reg_iso_osc48m_trim;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h25      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_ISO_OSC48M_TRIM_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[5]                          ),
    .o_rdata              (rdata_iso_osc48m_trim_efuse                  ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_OSCB_FREQ_ADJ REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'hDF      ),
    .REG_ADDR               (7'h26      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_OSCB_FREQ_ADJ(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_iso_oscb_freq_adj                      ),
    .o_reg_data           (reg_iso_oscb_freq_adj                        ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[6]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata6          = reg_iso_oscb_freq_adj;
assign o_reg_iso_oscb_freq_adj = reg_iso_oscb_freq_adj;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h26      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_ISO_OSCB_FREQ_ADJ_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[6]                          ),
    .o_rdata              (rdata_iso_oscb_freq_adj_efuse                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_RESERVED_REG REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h27      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_RESERVED_REG(
    .i_ren                (efuse_local_reg_rd                           ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_iso_reserved_reg                       ),
    .o_reg_data           (reg_iso_reserved_reg                         ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[7]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_efuse_wdata7         = reg_iso_reserved_reg;
assign o_reg_iso_reserved_reg = reg_iso_reserved_reg;

ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h27      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_ISO_RESERVED_REG_EFUSE(
    .i_ren                (efuse_remote_reg_rd                          ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ), 
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_efuse_reg_data[7]                          ),
    .o_rdata              (rdata_iso_reserved_reg_efuse                 ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_AMP_IBIAS REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h24      ),
    .REG_ADDR               (7'h28      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_AMP_IBIAS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_amp_ibias                          ),
    .o_reg_data           (reg_iso_amp_ibias                            ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_amp_ibias = reg_iso_amp_ibias;

//ISO_DEMO_TRIM REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h05      ),
    .REG_ADDR               (7'h29      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_DEMO_TRIM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_demo_trim                          ),
    .o_reg_data           (reg_iso_demo_trim                            ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_demo_trim = reg_iso_demo_trim;

//ISO_TEST_SW REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_TEST_SW(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_test_sw                            ),
    .o_reg_data           (reg_iso_test_sw                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_test_sw = reg_iso_test_sw;

//ISO_OSC_JIT REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_OSC_JIT(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_osc_jit                            ),
    .o_reg_data           (reg_iso_osc_jit                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_osc_jit = reg_iso_osc_jit;

//ANA_RESERVED_REG REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2C      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ANA_RESERVED_REG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_ana_reserved_reg                       ),
    .o_reg_data           (reg_ana_reserved_reg                         ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_ana_reserved_reg = reg_ana_reserved_reg;

//CONFIG0_T_DEAT_TIME REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h5F      ),
    .REG_ADDR               (7'h30      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG0_T_DEAT_TIME(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config0_t_deat_time                    ),
    .o_reg_data           (reg_config0_t_deat_time                      ),
    .o_rcrc               (rcrc_config0_t_deat_time                     ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_reg_config0_t_deat_time = reg_config0_t_deat_time;

assign spi_reg_ren   = i_spi_reg_ren    ;
assign spi_reg_wen   = i_spi_reg_wen    ;
assign spi_reg_addr  = i_spi_reg_addr   ;
assign spi_reg_wdata = i_spi_reg_wdata  ;
assign spi_reg_wcrc  = i_spi_reg_wcrc   ;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_wen_ff <= 1'b0;
    end
    else begin
        spi_reg_wen_ff <= spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_ren_ff <= 1'b0;       
    end
    else begin
        spi_reg_ren_ff <= spi_reg_ren;    
    end
end

assign o_reg_spi_wack= spi_reg_wen & ~spi_reg_wen_ff;

assign reg_spi_rack = hit_rd_efuse ? i_efuse_op_finish : (spi_reg_ren & ~spi_reg_ren_ff);

//rdata proc zone
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rack <= 1'b0;
    end
    else begin
        o_reg_spi_rack <= reg_spi_rack;
    end
end

assign reg_spi_rdata = com_reg_rdata | rdata_die1_efuse_config | rdata_die1_efuse_status | rdata_die2_efuse_config |
                       rdata_die2_efuse_status | rdata_status3 | rdata_status4 | rdata_adc1_data_low | rdata_adc1_data_hig | 
                       rdata_adc2_data_low | rdata_adc2_data_hig |
                       rdata_bist_rult1 | rdata_bist_rult2 | rdata_adc_status |
                       rdata_die1_id | rdata_die2_id | rdata_die3_id | rdata_iso_bgr_trim | rdata_iso_con_ibias_trim |
                       rdata_iso_osc48m_trim | rdata_iso_oscb_freq_adj | rdata_iso_reserved_reg | 
                       rdata_die1_id_efuse | rdata_die2_id_efuse | rdata_die3_id_efuse | rdata_iso_bgr_trim_efuse | rdata_iso_con_ibias_trim_efuse |
                       rdata_iso_osc48m_trim_efuse | rdata_iso_oscb_freq_adj_efuse | rdata_iso_reserved_reg_efuse |
                       rdata_iso_amp_ibias | 
                       rdata_iso_demo_trim | rdata_iso_test_sw | rdata_iso_osc_jit |
                       rdata_ana_reserved_reg | rdata_config0_t_deat_time;

assign reg_spi_rcrc = com_reg_rcrc | rcrc_config0_t_deat_time;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= reg_spi_rdata;
    end
end

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rcrc <= {REG_CRC_W{1'b0}};
    end
    else begin
        o_reg_spi_rcrc <= reg_spi_rcrc;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule



