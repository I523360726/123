//============================================================
//Module   : dig_hv_top
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module dig_hv_top
(
   input  logic                                        s32_16                           , 
   input  logic                                        sclk                             ,
   input  logic                                        csb                              ,
   input  logic                                        mosi                             ,
   output logic                                        miso                             , 
   input  logic                                        ow_data                          ,

   input  logic                                        d1d2_data                        , 
   output logic                                        d2d1_data                        ,
   output logic                                        pwm_intb                         , 

   input  logic                                        tm                               , 
   output logic                                        vh_pins32                        , 
   input  logic                                        setb                             ,
   input  logic [3:    0]                              off_vbn_read_i                   ,
   input  logic [3:    0]                              on_vbn_read_i                    ,  
   input  logic [5:    0]                              cnt_del_i                        ,

   input  logic                                        scan_mode                        ,

   output logic                                        pwm_en                           , 
   output logic                                        fsiso_en                         , 

   input  logic                                        uv_vcc                           , 
   input  logic                                        ov_vcc                           ,
   input  logic                                        otp                              ,
   input  logic                                        desat_fault                      , 
   input  logic                                        ocp_fault                        ,
   input  logic                                        scp_fault                        ,

   output logic                                        bisthv_ov                        ,
   output logic                                        bisthv_ot                        ,
   output logic                                        bisthv_desat                     ,
   output logic                                        bisthv_oc                        ,
   output logic                                        bisthv_sc                        , 
   output logic                                        bisthv_adc                       ,

   input  logic [9:    0]                              adc_data1                        ,
   input  logic [9:    0]                              adc_data2                        ,
   input  logic                                        adc_ready1                       ,
   input  logic                                        adc_ready2                       ,

   input  logic                                        fsiso_i                          ,
   input  logic                                        vge_vce_i                        ,
   output logic                                        rtmon                            ,

   output logic                                        vh_pins16                        ,
   output logic                                        re_111                           ,
   output logic                                        re_011                           ,
   input  logic [2:     0]                             adc_dvmr                         ,
   output logic                                        dvm_rst                          ,

   output logic                                        adc1_en                          ,
   output logic                                        adc2_en                          ,

   output logic [7:     0]                             iso_bgr_trim                     ,
   output logic [7:     0]                             iso_con_ibias_trim               ,
   output logic [7:     0]                             osc48m                           ,
   output logic [7:     0]                             iso_oscb_freq_trim               ,
   output logic [7:     0]                             iso_reserved_reg                 ,
   output logic [7:     0]                             iso_amp_ibias                    ,
   output logic [7:     0]                             iso_demo_trim                    ,
   output logic [7:     0]                             iso_test_sw                      ,
   output logic [7:     0]                             iso_osc_jit                      ,
   output logic [7:     0]                             ana_reserved_reg2                ,
   output logic [7:     0]                             config1                          ,
   output logic [7:     0]                             config2                          ,
   output logic [7:     0]                             config3                          ,
   output logic [7:     0]                             config4                          ,
   output logic [7:     0]                             config5                          ,
   output logic [7:     0]                             config6                          ,
   output logic [7:     0]                             config7                          ,
   output logic [7:     0]                             config8                          ,
   output logic [7:     0]                             config9                          ,
   output logic [7:     0]                             config10                         ,
   output logic [7:     0]                             config11                         ,
   output logic [7:     0]                             config12                         ,
   output logic [7:     0]                             bgr_code_drv                     ,
   output logic [7:     0]                             cap_trim_code                    ,     
   output logic [7:     0]                             csdel_cmp                        , 
   output logic [7:     0]                             dvdt_value_adj                   , 
   output logic [7:     0]                             adc_adj1                         , 
   output logic [7:     0]                             adc_adj2                         , 
   output logic [7:     0]                             ibias_code_drv                   ,
   output logic [7:     0]                             dvdt_tm                          ,  
   output logic [7:     0]                             dvdt_win_value_en                , 
   output logic [7:     0]                             preset_delay                     , 
   output logic [7:     0]                             driver_delay_set                 ,
   output logic [7:     0]                             cmp_del                          ,
   output logic [7:     0]                             test_mux                         , 
   output logic [7:     0]                             cmp_adj_vreg                     ,
                
   input  logic                                        clk                              ,
   input  logic                                        rst_n
);
//==================================
//local param delcaration
//==================================
    
//==================================
//var delcaration
//==================================
logic rst_n_sync; 
//==================================        
//main code
//==================================
rstn_sync U_RSTN_SYNC(
    .i_clk                           (clk               ),
    .i_asyn_rst_n                    (rst_n             ),
    .o_rst_n                         (rst_n_sync        )
);

hv_core U_HV_CORE(
    .i_s32_16                        (s32_16            ),
    .i_spi_sclk                      (sclk              ),
    .i_spi_csb                       (csb               ),
    .i_spi_mosi                      (mosi              ),
    .o_spi_miso                      (miso              ), 
 
    .i_d2d1rx_dpu_vld                (1'b0              ),
    .i_d2d1rx_dpu_addr               (8'b0              ),
    .i_d2d1rx_dpu_data               (8'b0              ),
    .o_dpu_d2d1rx_rdy                (                  ),

    .o_spi_s16pin_wr_req             (                  ),
    .o_spi_s16pin_rd_req             (                  ),
    .o_spi_s16pin_addr               (                  ), 
    .o_spi_s16pin_wdata              (                  ),
    .o_spi_s16pin_wcrc               (                  ), 
    .i_s16pin_spi_wack               (1'b0              ),
    .i_s16pin_spi_rack               (1'b0              ),
    .i_s16pin_spi_data               (8'b0              ),
    .i_s16pin_spi_addr               (7'b0              ),     

    .o_hv_lv_owt_tx                  (d2d1_data         ),
    .i_lv_hv_owt_rx                  (d1d2_data         ),

    .i_io_test_mode                  (tm                ),
    .o_fsm_ang_test_en               (vh_pins32         ),
    .i_setb                          (setb              ),
    .i_hv_vcc_uv                     (uv_vcc            ),
    .i_hv_vcc_ov                     (ov_vcc            ),
    .i_hv_ot                         (otp               ),
    .i_hv_oc                         (ocp_fault         ),
    .i_hv_desat_flt                  (desat_fault       ),
    .i_hv_scp_flt                    (scp_fault         ),

    .i_vge_vce                       (vge_vce_i         ),
    .i_io_fsiso                      (fsiso_i           ),
    .i_io_pwma                       (1'b0              ),
    .i_io_pwm                        (1'b0              ),
    .i_io_fsstate                    (1'b0              ),
    .i_io_fsenb_n                    (1'b0              ),
    .i_io_intb                       (1'b1              ),
    .i_io_inta                       (1'b1              ),

    .o_bist_hv_ov                    (bisthv_ov         ),
    .o_bist_hv_ot                    (bisthv_ot         ),
    .o_bist_hv_opscod                (bisthv_desat      ),
    .o_bist_hv_oc                    (bisthv_oc         ),
    .o_bist_hv_sc                    (bisthv_sc         ),
    .o_bist_hv_adc                   (bisthv_adc        ),

    .i_cnt_del_read                  (cnt_del_i         ),
    .i_off_vbn_read                  (off_vbn_read_i    ),
    .i_on_vbn_read                   (on_vbn_read_i     ),

    .i_adc_data1                     (adc_data1         ),
    .i_adc_data2                     (adc_data2         ),
    .i_adc_ready1                    (adc_ready1        ),
    .i_adc_ready2                    (adc_ready2        ),

    .i_ang_dgt_pwm_wv                (1'b0              ), //analog pwm ctrl to digtial pwm ctrl pwm wave
    .i_ang_dgt_pwm_fs                (1'b0              ),

    .o_adc1_en                       (adc1_en           ),
    .o_adc2_en                       (adc2_en           ),

    .o_efuse_wmode                   (                  ),
    .o_io_efuse_setb                 (                  ),
    .o_efuse_wr_p                    (                  ),
    .o_efuse_rd_p                    (                  ),
    .o_efuse_addr                    (                  ),
    .o_efuse_wdata0                  (                  ),
    .o_efuse_wdata1                  (                  ),
    .o_efuse_wdata2                  (                  ),
    .o_efuse_wdata3                  (                  ),
    .o_efuse_wdata4                  (                  ),
    .o_efuse_wdata5                  (                  ),
    .o_efuse_wdata6                  (                  ),
    .o_efuse_wdata7                  (                  ),
    .o_efuse_wdata8                  (                  ),
    .o_efuse_wdata9                  (                  ),
    .o_efuse_wdata10                 (                  ),
    .o_efuse_wdata11                 (                  ),
    .o_efuse_wdata12                 (                  ),
    .o_efuse_wdata13                 (                  ),
    .o_efuse_wdata14                 (                  ),
    .o_efuse_wdata15                 (                  ),
    .i_efuse_op_finish               (1'b0              ),
    .i_efuse_reg_update              (1'b0              ),
    .i_efuse_reg_data0               (8'b0              ),
    .i_efuse_reg_data1               (8'b0              ),
    .i_efuse_reg_data2               (8'b0              ),
    .i_efuse_reg_data3               (8'b0              ),
    .i_efuse_reg_data4               (8'b0              ),
    .i_efuse_reg_data5               (8'b0              ),
    .i_efuse_reg_data6               (8'b0              ),
    .i_efuse_reg_data7               (8'b0              ),
    .i_efuse_reg_data8               (8'b0              ),
    .i_efuse_reg_data9               (8'b0              ),
    .i_efuse_reg_data10              (8'b0              ),
    .i_efuse_reg_data11              (8'b0              ),
    .i_efuse_reg_data12              (8'b0              ),
    .i_efuse_reg_data13              (8'b0              ),
    .i_efuse_reg_data14              (8'b0              ),
    .i_efuse_reg_data15              (8'b0              ),

    .o_efuse_load_req                (                  ),
    .i_efuse_load_done               (1'b0              ),

    .o_dgt_ang_pwm_en                (pwm_en            ),
    .o_dgt_ang_fsiso_en              (fsiso_en          ),

    .o_pwmn_intb                     (pwm_intb          ),

    .o_reg_iso_bgr_trim              (iso_bgr_trim      ),
    .o_reg_iso_con_ibias_trim        (iso_con_ibias_trim),
    .o_reg_iso_osc48m_trim           (osc48m            ),
    .o_reg_iso_oscb_freq_adj         (iso_oscb_freq_trim),
    .o_reg_iso_reserved_reg          (iso_reserved_reg  ),
    .o_reg_iso_amp_ibias             (iso_amp_ibias     ),
    .o_reg_iso_demo_trim             (iso_demo_trim     ),
    .o_reg_iso_test_sw               (iso_test_sw       ),
    .o_reg_iso_osc_jit               (iso_osc_jit       ),
    .o_reg_ana_reserved_reg2         (ana_reserved_reg2 ),
    .o_reg_config1_dr_src_snk_both   (config1           ),
    .o_reg_config2_dr_src_sel        (config2           ),
    .o_reg_config3_dri_snk_sel       (config3           ),
    .o_reg_config4_tltoff_sel1       (config4           ),
    .o_reg_config5_tltoff_sel2       (config5           ),
    .o_reg_config6_desat_sel1        (config6           ),
    .o_reg_config7_desat_sel2        (config7           ),
    .o_reg_config8_oc_sel            (config8           ),
    .o_reg_config9_sc_sel            (config9           ),
    .o_reg_config10_dvdt_ref_src     (config10          ),
    .o_reg_config11_dvdt_ref_sink    (config11          ),
    .o_reg_config12_adc_en           (config12          ),
    .o_reg_bgr_code_drv              (bgr_code_drv      ),
    .o_reg_cap_trim_code             (cap_trim_code     ),     
    .o_reg_csdel_cmp                 (csdel_cmp         ), 
    .o_reg_dvdt_value_adj            (dvdt_value_adj    ), 
    .o_reg_adc_adj1                  (adc_adj1          ), 
    .o_reg_adc_adj2                  (adc_adj2          ), 
    .o_reg_ibias_code_drv            (ibias_code_drv    ),
    .o_reg_dvdt_tm                   (dvdt_tm           ),  
    .o_reg_dvdt_win_value_en         (dvdt_win_value_en ), 
    .o_reg_preset_delay              (preset_delay      ), 
    .o_reg_drive_delay_set           (driver_delay_set  ),
    .o_reg_cmp_del                   (cmp_del           ),
    .o_reg_test_mux                  (test_mux          ), 
    .o_reg_cmp_adj_vreg              (cmp_adj_vreg      ),

    .i_clk                           (clk               ),
    .i_rst_n                         (rst_n_sync        )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    

    
    
    
    

    
    
    
    

    
    
    
    

    
    
    
    

    
    
    
    

    
    
    
    

    
    
    
    
