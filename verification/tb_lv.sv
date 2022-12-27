//============================================================
//Module   : tb_lv
//Function : testbench for lv
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
`timescale 1ns/1ps

module tb_lv();

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
logic                       rst_n_sync  ;
logic                       rst_n       ;
logic                       clk         ;
logic                       src_sclk    ;
logic                       sclk        ;
logic                       csb         ;
logic                       mosi        ;
logic                       miso        ;
logic                       s32_16      ;
logic [SPI_CYC_CNT-1: 0]    spi_cyc_cnt ;
//==================================        
//main code
//==================================
initial begin
    rst_n = 1'b1; #(100);
    rst_n = 1'b0; #(RST_TIME);
    rst_n = 1'b1; #(50000);
    $finish;
end

initial begin
    $fsdbDumpfile("tb_lv.fsdb");
    $fsdbDumpvars("+all");
    $fsdbDumpMDA(0, tb_lv);
end

always begin
    clk = 1'b0; #(CYC_48MHZ/2);
    clk = 1'b1; #(CYC_48MHZ/2);
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

dig_lv_top U_DIG_LV_TOP( 
   .sclk                             (sclk                      ),
   .csb                              (csb                       ),
   .mosi                             (mosi                      ),
   .miso                             (                          ),
   .s32_16                           (1'b0                      ),

   .d1d2_data                        (                          ),
   .d2d1_data                        (1'b0                      ),
   .d21_gate_back                    (1'b0                      ),

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

    .clk                             (clk                       ),
    .rst_n                           (rst_n                     )
);


// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    

    
    
    
    

    
    
    
    
