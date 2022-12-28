//============================================================
//Module   : tb
//Function : testbench for lv
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
`timescale 1ns/1ps

module tb();

//==================================
//local param delcaration
//==================================
real        CYC_48MHZ           = (1000/48)             ;
real        CYC_10MHZ           = (1000/10)             ;
real        RST_TIME            = 400                   ; 
parameter   SPI_CYC_CNT         = 25                    ;  
parameter   SPI_CYC_CNT_W       = $clog2(SPI_CYC_CNT+1) ;
parameter   [23: 0] FIRST_CMD   = {16'b0, 8'hB8}        ;
//==================================
//var delcaration
//==================================
logic                       lv_rst_n            ;
logic                       lv_clk              ;
logic                       hv_rst_n            ;
logic                       hv_clk              ;
logic                       src_sclk            ;
logic                       sclk                ;
logic                       csb                 ;
logic                       mosi                ;
logic                       miso                ;
logic                       s32_16              ;
logic [SPI_CYC_CNT-1: 0]    spi_cyc_cnt         ;

logic [0:    0]             lv_efuse_op_finish  ;
logic [0:    0]             lv_efuse_reg_update ;
logic [7:    0]             lv_efuse_reg_data0  ;
logic [7:    0]             lv_efuse_reg_data1  ;
logic [7:    0]             lv_efuse_reg_data2  ;
logic [7:    0]             lv_efuse_reg_data3  ;
logic [7:    0]             lv_efuse_reg_data4  ;
logic [7:    0]             lv_efuse_reg_data5  ;
logic [7:    0]             lv_efuse_reg_data6  ;
logic [7:    0]             lv_efuse_reg_data7  ;
logic [63:   0]             lv_efuse_reg_data   ;

logic                       lv_efuse_load_req   ;
logic                       lv_efuse_load_done  ;

logic [0:    0]             hv_efuse_op_finish  ;
logic [0:    0]             hv_efuse_reg_update ;
logic [7:    0]             hv_efuse_reg_data0  ;
logic [7:    0]             hv_efuse_reg_data1  ;
logic [7:    0]             hv_efuse_reg_data2  ;
logic [7:    0]             hv_efuse_reg_data3  ;
logic [7:    0]             hv_efuse_reg_data4  ;
logic [7:    0]             hv_efuse_reg_data5  ;
logic [7:    0]             hv_efuse_reg_data6  ;
logic [7:    0]             hv_efuse_reg_data7  ;
logic [7:    0]             hv_efuse_reg_data8  ;
logic [7:    0]             hv_efuse_reg_data9  ;
logic [7:    0]             hv_efuse_reg_data10 ;
logic [7:    0]             hv_efuse_reg_data11 ;
logic [7:    0]             hv_efuse_reg_data12 ;
logic [7:    0]             hv_efuse_reg_data13 ;
logic [7:    0]             hv_efuse_reg_data14 ;
logic [7:    0]             hv_efuse_reg_data15 ;
logic [127:  0]             hv_efuse_reg_data   ;

logic                       hv_efuse_load_req   ;
logic                       hv_efuse_load_done  ;

logic                       d1d2_data           ;
logic                       d2d1_data           ;
logic                       d21_gate_back       ;
//==================================        
//main code
//==================================
initial begin
    lv_rst_n = 1'b1; #(100);
    lv_rst_n = 1'b0; #(RST_TIME);
    lv_rst_n = 1'b1; #(50000);
    $finish;
end

always begin
    lv_clk = 1'b0; #(CYC_48MHZ/2);
    lv_clk = 1'b1; #(CYC_48MHZ/2);
end

initial begin
    #($random%60);
    hv_rst_n = 1'b1; #(100);
    hv_rst_n = 1'b0; #(RST_TIME-99);
    hv_rst_n = 1'b1; #(50000);
end

always begin
    #($random%60);
    hv_clk = 1'b0; #(CYC_48MHZ/2);
    hv_clk = 1'b1; #(CYC_48MHZ/2);
end

initial begin
    $fsdbDumpfile("tb_lv.fsdb");
    $fsdbDumpvars("+all");
    $fsdbDumpMDA(0, tb);
end

initial begin
    csb = 1'b1; #(1000);
    csb = 1'b0; #(CYC_10MHZ*30);
    csb = 1'b1; #(10);
    csb = 1'b1; #(1000);
    csb = 1'b0; #(CYC_10MHZ*30);
    csb = 1'b1; #(10);
end

always begin
    src_sclk = 1'b0; #(CYC_10MHZ/2);
    src_sclk = 1'b1; #(CYC_10MHZ/2);
end

always_ff@(negedge src_sclk or posedge csb) begin
    if(csb) begin
        spi_cyc_cnt <= SPI_CYC_CNT_W'(0);
    end
    else begin
        spi_cyc_cnt <= (spi_cyc_cnt==SPI_CYC_CNT) ? SPI_CYC_CNT : (spi_cyc_cnt+1'b1);
    end
end

assign sclk = src_sclk & ~csb & (spi_cyc_cnt<SPI_CYC_CNT);

always_ff @(negedge src_sclk or posedge csb) begin
    if(csb) begin
        mosi <= 1'b0;
    end
    else begin
        mosi <= FIRST_CMD[SPI_CYC_CNT-2-spi_cyc_cnt];
    end    
end

dig_lv_top_for_test U_DIG_LV_TOP( 
   .sclk                             (sclk                      ),
   .csb                              (csb                       ),
   .mosi                             (mosi                      ),
   .miso                             (                          ),
   .s32_16                           (1'b0                      ),

   .d1d2_data                        (d1d2_data                 ),
   .d2d1_data                        (d2d1_data                 ),
   .d21_gate_back                    (d21_gate_back             ),

   .tm                               (1'b0                      ), 
   .vl_pins32                        (                          ),
   .setb                             (1'b0                      ), 

   .scan_mode                        (1'b0                      ),

   .intb_o                           (                          ),
   .fsc_en                           (                          ),
   .pwm_en                           (                          ),

   .uv_vsup                          (1'b1                      ), 
   .dt_flag                          (1'b0                      ), 
   .vsup_ov                          (1'b0                      ), 
   .gate_vs_pwm                      (1'b0                      ), 
   .rtmon                            (                          ),

   .bistlv_ov                        (                          ),

   .adc1_o                           (                          ),
   .adc2_o                           (                          ),
   .adc1_en                          (                          ),
   .adc2_en                          (                          ),
   .aout_wait                        (                          ),
   .aout_bist                        (                          ),

   .fsenb_i                          (1'b1                      ),
   .fsstate_i                        (1'b0                      ),
   .intb_i                           (1'b0                      ),
   .inta_i                           (1'b0                      ),
   .pwm_i                            (1'b0                      ),
   .pwmalt_i                         (1'b0                      ),

   .scl                              (1'b0                      ),
   .sda_in                           (1'b0                      ),
   .sda_out                          (                          ),
   .se                               (                          ), 

   .vl_pins16                        (                          ),  

   .set_jdg                          (2'b0                      ),
   .adc_dmvf                         (3'b0                      ),
   .adc_sic                          (3'b0                      ),
   .adc_vth                          (2'b0                      ),
   .adc_soc                          (3'b0                      ), 
   .jdg_disable                      (                          ),

   .fault_b                          (3'b0                      ),
   .fault_data_rst                   (                          ),
   .rdy_oc_rst                       (                          ), 

   .iso_bgr_trim                     (                          ),
   .iso_con_ibias_trim               (                          ),
   .iso_osc48m_trim                  (                          ),
   .iso_oscb_freq_adj                (                          ),
   .iso_reserved_reg                 (                          ),
   .iso_amp_ibias                    (                          ),
   .iso_demo_trim                    (                          ),
   .iso_test_sw                      (                          ),
   .iso_osc_jit                      (                          ),
   .ana_reserved_reg                 (                          ),
   .config0                          (                          ),

    .i_efuse_op_finish               (lv_efuse_op_finish        ),
    .i_efuse_reg_update              (lv_efuse_reg_update       ),
    .i_efuse_reg_data0               (lv_efuse_reg_data0        ),
    .i_efuse_reg_data1               (lv_efuse_reg_data1        ),
    .i_efuse_reg_data2               (lv_efuse_reg_data2        ),
    .i_efuse_reg_data3               (lv_efuse_reg_data3        ),
    .i_efuse_reg_data4               (lv_efuse_reg_data4        ),
    .i_efuse_reg_data5               (lv_efuse_reg_data5        ),
    .i_efuse_reg_data6               (lv_efuse_reg_data6        ),
    .i_efuse_reg_data7               (lv_efuse_reg_data7        ),

    .o_efuse_load_req                (lv_efuse_load_req         ),
    .i_efuse_load_done               (lv_efuse_load_done        ),

    .clk                             (lv_clk                    ),
    .rst_n                           (lv_rst_n                  )
);

assign {lv_efuse_reg_data7, lv_efuse_reg_data6, lv_efuse_reg_data5, lv_efuse_reg_data4, 
        lv_efuse_reg_data3, lv_efuse_reg_data2, lv_efuse_reg_data1, lv_efuse_reg_data0} = lv_efuse_reg_data;

efuse_ip_for_test #(
    .DATA_NUM (8)
)U_LV_EFUSE_ID_FOR_TEST(
    .o_efuse_op_finish               (lv_efuse_op_finish        ),
    .o_efuse_reg_update              (lv_efuse_reg_update       ),
    .o_efuse_reg_data                (lv_efuse_reg_data         ),

    .i_efuse_load_req                (lv_efuse_load_req         ),
    .o_efuse_load_done               (lv_efuse_load_done        ),

    .i_clk                           (lv_clk                    ),
    .i_rst_n                         (lv_rst_n                  )
);

dig_hv_top_for_test U_DIG_HV_TOP_FOR_TEST(
   .s32_16                           (1'b1                      ), 
   .sclk                             (1'b0                      ),
   .csb                              (1'b1                      ),
   .mosi                             (1'b0                      ),
   .miso                             (                          ), 
   .ow_data                          (1'b0                      ),

   .d1d2_data                        (d1d2_data                 ), 
   .d2d1_data                        (d2d1_data                 ),
   .pwm_intb                         (d21_gate_back             ), 

   .tm                               (1'b0                      ), 
   .vh_pins32                        (                          ), 
   .setb                             (1'b0                      ),
   .off_vbn_read_i                   (4'b0                      ),
   .on_vbn_read_i                    (4'b0                      ),  
   .cnt_del_i                        (6'b0                      ),

   .scan_mode                        (1'b0                      ),

   .pwm_en                           (                          ), 
   .fsiso_en                         (                          ), 

   .uv_vcc                           (1'b0                      ), 
   .ov_vcc                           (1'b0                      ),
   .otp                              (1'b0                      ),
   .desat_fault                      (1'b0                      ), 
   .ocp_fault                        (1'b0                      ),
   .scp_fault                        (1'b0                      ),

   .bisthv_ov                        (                          ),
   .bisthv_ot                        (                          ),
   .bisthv_desat                     (                          ),
   .bisthv_oc                        (                          ),
   .bisthv_sc                        (                          ), 
   .bisthv_adc                       (                          ),

   .adc_data1                        (10'd1023                  ),
   .adc_data2                        (10'd1023                  ),
   .adc_ready1                       (1'b1                      ),
   .adc_ready2                       (1'b1                      ),

   .fsiso_i                          (1'b0                      ),
   .vge_vce_i                        (1'b0                      ),
   .rtmon                            (                          ),

   .vh_pins16                        (                          ),
   .re_111                           (                          ),
   .re_011                           (                          ),
   .adc_dvmr                         (3'b0                      ),
   .dvm_rst                          (                          ),

   .adc1_en                          (                          ),
   .adc2_en                          (                          ),

   .iso_bgr_trim                     (                          ),
   .iso_con_ibias_trim               (                          ),
   .osc48m                           (                          ),
   .iso_oscb_freq_trim               (                          ),
   .iso_reserved_reg                 (                          ),
   .iso_amp_ibias                    (                          ),
   .iso_demo_trim                    (                          ),
   .iso_test_sw                      (                          ),
   .iso_osc_jit                      (                          ),
   .ana_reserved_reg2                (                          ),
   .config1                          (                          ),
   .config2                          (                          ),
   .config3                          (                          ),
   .config4                          (                          ),
   .config5                          (                          ),
   .config6                          (                          ),
   .config7                          (                          ),
   .config8                          (                          ),
   .config9                          (                          ),
   .config10                         (                          ),
   .config11                         (                          ),
   .config12                         (                          ),
   .bgr_code_drv                     (                          ),
   .cap_trim_code                    (                          ),     
   .csdel_cmp                        (                          ), 
   .dvdt_value_adj                   (                          ), 
   .adc_adj1                         (                          ), 
   .adc_adj2                         (                          ), 
   .ibias_code_drv                   (                          ),
   .dvdt_tm                          (                          ),  
   .dvdt_win_value_en                (                          ), 
   .preset_delay                     (                          ), 
   .driver_delay_set                 (                          ),
   .cmp_del                          (                          ),
   .test_mux                         (                          ), 
   .cmp_adj_vreg                     (                          ),

   .i_efuse_op_finish                (hv_efuse_op_finish        ),
   .i_efuse_reg_update               (hv_efuse_reg_update       ),
   .i_efuse_reg_data0                (hv_efuse_reg_data0        ),
   .i_efuse_reg_data1                (hv_efuse_reg_data1        ),
   .i_efuse_reg_data2                (hv_efuse_reg_data2        ),
   .i_efuse_reg_data3                (hv_efuse_reg_data3        ),
   .i_efuse_reg_data4                (hv_efuse_reg_data4        ),
   .i_efuse_reg_data5                (hv_efuse_reg_data5        ),
   .i_efuse_reg_data6                (hv_efuse_reg_data6        ),
   .i_efuse_reg_data7                (hv_efuse_reg_data7        ),
   .i_efuse_reg_data8                (hv_efuse_reg_data8        ),
   .i_efuse_reg_data9                (hv_efuse_reg_data9        ),
   .i_efuse_reg_data10               (hv_efuse_reg_data10       ),
   .i_efuse_reg_data11               (hv_efuse_reg_data11       ),
   .i_efuse_reg_data12               (hv_efuse_reg_data12       ),
   .i_efuse_reg_data13               (hv_efuse_reg_data13       ),
   .i_efuse_reg_data14               (hv_efuse_reg_data14       ),
   .i_efuse_reg_data15               (hv_efuse_reg_data15       ),

   .o_efuse_load_req                 (hv_efuse_load_req         ),
   .i_efuse_load_done                (hv_efuse_load_done        ),
                
    .clk                             (hv_clk                    ),
    .rst_n                           (hv_rst_n                  )
);

assign {hv_efuse_reg_data15, hv_efuse_reg_data14, hv_efuse_reg_data13, hv_efuse_reg_data12,
        hv_efuse_reg_data11, hv_efuse_reg_data10, hv_efuse_reg_data9,  hv_efuse_reg_data8,
        hv_efuse_reg_data7,  hv_efuse_reg_data6,  hv_efuse_reg_data5,  hv_efuse_reg_data4, 
        hv_efuse_reg_data3,  hv_efuse_reg_data2,  hv_efuse_reg_data1,  hv_efuse_reg_data0} = hv_efuse_reg_data;

efuse_ip_for_test #(
    .DATA_NUM (16)
)U_HV_EFUSE_ID_FOR_TEST(
    .o_efuse_op_finish               (hv_efuse_op_finish        ),
    .o_efuse_reg_update              (hv_efuse_reg_update       ),
    .o_efuse_reg_data                (hv_efuse_reg_data         ),

    .i_efuse_load_req                (hv_efuse_load_req         ),
    .o_efuse_load_done               (hv_efuse_load_done        ),

    .i_clk                           (hv_clk                    ),
    .i_rst_n                         (hv_rst_n                  )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    

    
    
    
    

    
    
    
    
