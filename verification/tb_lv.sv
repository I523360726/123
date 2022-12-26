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

rstn_sync U_RSTN_SYNC(
    .i_clk                           (clk                       ),
    .i_asyn_rst_n                    (rst_n                     ),
    .o_rst_n                         (rst_n_sync                )
);

lv_core U_LV_CORE(
    .i_spi_sclk                      (sclk                      ),
    .i_spi_csb                       (csb                       ),
    .i_spi_mosi                      (mosi                      ),
    .o_spi_miso                      (                          ), 
    .i_s32_sel                       (1'b0                      ),

    .o_lv_hv_owt_tx                  (                          ),
    .i_hv_lv_owt_rx                  (1'b0                      ),
    .i_hv_pwm_intb_n                 (1'b0                      ),

    .i_io_test_mode                  (1'b0                      ), 
    .o_fsm_ang_test_en               (                          ), 
    .i_setb                          (1'b0                      ), 

    .i_scan_mode                     (1'b0                      ),

    .o_intb_n                        (                          ),
    .o_dgt_ang_pwm_en                (                          ),
    .o_dgt_ang_fsc_en                (                          ),

    .i_lv_vsup_uv_n                  (1'b1                      ), 
    .i_lv_pwm_dt                     (1'b0                      ), 
    .i_lv_vsup_ov                    (1'b0                      ), 
    .i_lv_gate_vs_pwm                (1'b0                      ), 
    .o_rtmon                         (                          ),

    .o_efuse_wmode                   (                          ),
    .o_io_efuse_setb                 (                          ),
    .o_efuse_wr_p                    (                          ),
    .o_efuse_rd_p                    (                          ),
    .o_efuse_addr                    (                          ),
    .o_efuse_wdata0                  (                          ),
    .o_efuse_wdata1                  (                          ),
    .o_efuse_wdata2                  (                          ),
    .o_efuse_wdata3                  (                          ),
    .o_efuse_wdata4                  (                          ),
    .o_efuse_wdata5                  (                          ),
    .o_efuse_wdata6                  (                          ),
    .o_efuse_wdata7                  (                          ),
    .i_efuse_op_finish               (1'b0                      ),
    .i_efuse_reg_update              (1'b0                      ),
    .i_efuse_reg_data0               (8'b0                      ),
    .i_efuse_reg_data1               (8'b0                      ),
    .i_efuse_reg_data2               (8'b0                      ),
    .i_efuse_reg_data3               (8'b0                      ),
    .i_efuse_reg_data4               (8'b0                      ),
    .i_efuse_reg_data5               (8'b0                      ),
    .i_efuse_reg_data6               (8'b0                      ),
    .i_efuse_reg_data7               (8'b0                      ),

    .o_efuse_load_req                (                          ),
    .i_efuse_load_done               (1'b0                      ),

    .o_bistlv_ov                     (                          ),

    .o_adc1_data                     (                          ),
    .o_adc2_data                     (                          ),
    .o_adc1_en                       (                          ),
    .o_adc2_en                       (                          ),
    .o_aout_wait                     (                          ),
    .o_aout_bist                     (                          ),

    .i_io_fsenb_n                    (1'b1                      ),
    .i_io_fsstate                    (1'b0                      ),
    .i_io_intb                       (1'b0                      ),
    .i_io_inta                       (1'b0                      ),
    .i_io_pwm                        (1'b0                      ),
    .i_io_pwma                       (1'b0                      ),

    .o_reg_iso_bgr_trim              (                          ),
    .o_reg_iso_con_ibias_trim        (                          ),
    .o_reg_iso_osc48m_trim           (                          ),
    .o_reg_iso_oscb_freq_adj         (                          ),
    .o_reg_iso_reserved_reg          (                          ),
    .o_reg_iso_amp_ibias             (                          ),
    .o_reg_iso_demo_trim             (                          ),
    .o_reg_iso_test_sw               (                          ),
    .o_reg_iso_osc_jit               (                          ),
    .o_reg_ana_reserved_reg          (                          ),
    .o_reg_config0_t_deat_time       (                          ),
 
    .i_clk                           (clk                       ),
    .i_rst_n                         (rst_n_sync                )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    

    
    
    
    

    
    
    
    
