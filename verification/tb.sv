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
real        CYC_43MHZ           = (1000/43)             ;
real        CYC_53MHZ           = (1000/53)             ;
real        CYC_48MHZ           = (1000/48)             ;
real        CYC_10MHZ           = (1000/10)             ;
real        RST_TIME            = 400                   ; 
//==================================
//var delcaration
//==================================
logic                       lv_rst_n            ;
logic                       lv_clk              ;
logic                       hv_rst_n            ;
logic                       hv_clk              ;
logic                       spi_clk             ;
logic                       sclk                ;
logic                       csb                 ;
logic                       mosi                ;
logic                       miso                ;
logic                       s32_16              ;
logic                       spi_start           ;
logic [7:    0]             spi_cmd             ;
logic [7:    0]             spi_data            ;

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

logic                       test_mode           ;
logic [31:  0]              spi_cnt             ;
logic                       bistlv_ov           ;
logic [99:  0]              vsup_ov_ff          ;

realtime                    lv_half_period      ;
realtime                    hv_half_period      ;
real                        lv_clk_var_dly      ;
real                        hv_clk_var_dly      ;
//==================================        
//main code
//==================================
initial begin
    lv_rst_n = 1'b1; #(100);
    lv_rst_n = 1'b0; #(RST_TIME);
    lv_rst_n = 1'b1; #(50000000);
    $finish;
end

initial begin
    #($random%60);
    hv_rst_n = 1'b1; #(100);
    hv_rst_n = 1'b0; #(RST_TIME+($random%10));
    hv_rst_n = 1'b1; #(50000);
end

initial begin
    lv_half_period = 1000.0/(43*2);
    repeat(20000) begin
        lv_clk_var_dly = ($urandom_range(3000, 2000));
        #lv_clk_var_dly;
        lv_half_period = 1000.0/$urandom_range(43*2, 43*2);
    end
end

initial begin
    hv_half_period = 1000.0/(53*2);
    repeat(20000) begin
        hv_clk_var_dly = ($urandom_range(4000, 3000));
        #hv_clk_var_dly;
        hv_half_period = 1000.0/$urandom_range(53*2, 53*2);
    end
end

initial begin
    lv_clk = $urandom%2;
    #($urandom%60);
    forever begin
        #lv_half_period lv_clk = ~lv_clk;
    end
end

initial begin
    hv_clk = $urandom%2;
    #($urandom%57);
    forever begin
        #hv_half_period hv_clk = ~hv_clk;
    end
end

initial begin
    spi_clk = $urandom%2;
    #($urandom%29);
    forever begin
        #(CYC_10MHZ/2) spi_clk = ~spi_clk;
    end
end

initial begin
    $fsdbDumpfile("tb_lv.fsdb");
    $fsdbDumpvars("+all");
    $fsdbDumpMDA(0, tb);
end

//assign crc16to8_data_in = (spi_cmd_cnt==8'h0) ? ({1'b1, 7'h40, 8'h5B}) : 
//                          (spi_cmd_cnt==8'h1) ? ({1'b0, 7'h40, 8'h00}) : 
//                          (spi_cmd_cnt==8'h2) ? ({1'b1, 7'h6E, 8'hA6}) : 
//                                                ({1'b0, 7'h6E, 8'h00}) ;

always_ff@(negedge spi_clk or negedge lv_rst_n) begin
    if(~lv_rst_n) begin
        spi_cnt <= 32'b0;    
    end
    else begin
        spi_cnt <= spi_cnt + 1'b1;
    end    
end

assign test_mode = 1'b0; 
assign spi_start = (spi_cnt==32'd35000) || (spi_cnt==32'd36000) || 
                   (spi_cnt==32'd37000) || (spi_cnt==32'd38000) ||
                   (spi_cnt==32'd39000) || (spi_cnt==32'd40000) || 
                   (spi_cnt==32'd60000) || (spi_cnt==32'd61000) ;
assign spi_cmd   = (spi_cnt<32'd36000) ? {1'b1, 7'h08} : {1'b1, 7'h01};
assign spi_data  = (spi_cnt<32'd36000) ? 8'b1111_1111 : 
                   (spi_cnt<32'd37000) ? 8'b1000_0000 : 
                   (spi_cnt<32'd38000) ? 8'b0000_0010 :
                   (spi_cnt<32'd39000) ? 8'b0000_0100 : 
                   (spi_cnt<32'd40000) ? 8'b0000_1100 : 
                   (spi_cnt<32'd60000) ? 8'b0000_1100 : 
                   (spi_cnt<32'd61000) ? 8'b0000_1100 : 8'b0000_1100;

gen_spi_sig #(
    .MODE(0)
)U_GEN_SPI_SIG(
    .i_clk       (spi_clk   ),
    .i_rst_n     (lv_rst_n  ),
    .i_start     (spi_start ),
    .i_cmd       (spi_cmd   ),
    .i_data      (spi_data  ),

    .o_sclk      (sclk      ),
    .o_csb       (csb       ),
    .o_mosi      (mosi      ),
    .i_miso      (miso      )
);

always_ff@(posedge lv_clk or negedge lv_rst_n) begin
    if(~lv_rst_n) begin
        vsup_ov_ff[99: 0] <= 100'b0;    
    end
    else begin
        vsup_ov_ff[99: 0] <= {vsup_ov_ff[98: 0], bistlv_ov};
    end    
end

dig_lv_top_for_test U_DIG_LV_TOP( 
   .sclk                             (sclk                      ),
   .csb                              (csb                       ),
   .mosi                             (mosi                      ),
   .miso                             (miso                      ),
   .s32_16                           (1'b0                      ),

   .d1d2_data                        (d1d2_data                 ),
   .d2d1_data                        (d2d1_data                 ),
   .d21_gate_back                    (d21_gate_back             ),

   .tm                               (test_mode                 ), 
   .vl_pins32                        (                          ),
   .setb                             (1'b0                      ), 

   .scan_mode                        (1'b0                      ),

   .intb_o                           (                          ),
   .fsc_en                           (                          ),
   .pwm_en                           (                          ),

   .uv_vsup                          (1'b1                      ), 
   .dt_flag                          (1'b0                      ), 
   .vsup_ov                          (vsup_ov_ff[99]            ), 
   .gate_vs_pwm                      (1'b0                      ), 
   .rtmon                            (                          ),

   .bistlv_ov                        (bistlv_ov                 ),

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

   .i_efuse_op_finish                (lv_efuse_op_finish        ),
   .i_efuse_reg_update               (lv_efuse_reg_update       ),
   .i_efuse_reg_data0                (lv_efuse_reg_data0        ),
   .i_efuse_reg_data1                (lv_efuse_reg_data1        ),
   .i_efuse_reg_data2                (lv_efuse_reg_data2        ),
   .i_efuse_reg_data3                (lv_efuse_reg_data3        ),
   .i_efuse_reg_data4                (lv_efuse_reg_data4        ),
   .i_efuse_reg_data5                (lv_efuse_reg_data5        ),
   .i_efuse_reg_data6                (lv_efuse_reg_data6        ),
   .i_efuse_reg_data7                (lv_efuse_reg_data7        ),

   .o_efuse_load_req                 (lv_efuse_load_req         ),
   .i_efuse_load_done                (lv_efuse_load_done        ),

   .clk                              (lv_clk                    ),
   .rst_n                            (lv_rst_n                  )
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

dig_hv_top_for_test U_DIG_HV_TOP(
   .s32_16                           (1'b1                      ), 
   .sclk                             (1'b0                      ),
   .csb                              (1'b1                      ),
   .mosi                             (1'b0                      ),
   .miso                             (                          ), 
   .ow_data                          (1'b0                      ),

   .d1d2_data                        (d1d2_data                 ), 
   .d2d1_data                        (d2d1_data                 ),
   .pwm_intb                         (d21_gate_back             ), 

   .tm                               (test_mode                 ), 
   .vh_pins32                        (                          ), 
   .setb                             (1'b0                      ),
   .off_vbn_read_i                   (4'h6                      ),
   .on_vbn_read_i                    (4'hE                      ),  
   .cnt_del_i                        (6'h2E                     ),

   .scan_mode                        (1'b0                      ),

   .pwm_en                           (                          ), 
   .fsiso_en                         (                          ), 

   .uv_vcc                           (1'b1                      ), 
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
    
    
    
    

    
    
    
    

    
    
    
    

    
    
    

    
    
    
    

    
    
    
    
