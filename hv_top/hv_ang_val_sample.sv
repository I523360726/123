//============================================================
//Module   : hv_ang_val_sample.sv
//Function : ang val sample, then store into dgt reg.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_ang_val_sample #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)(
    input  logic [3:        0]  i_off_vbn_read       ,
    input  logic [3:        0]  i_on_vbn_read        ,
    input  logic [5:        0]  i_cnt_del_read       ,
    input  logic [7:        0]  i_reg_dvdt_tm        ,

    output logic [7:        0]  o_cap_trim_code_read ,
    output logic [5:        0]  o_cnt_del_read       ,

    input  logic                i_clk                ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam SAMP_CYC_NUM = (2001*CLK_M+999)/1000  ; //after 2us
localparam CNT_W        = $clog2(SAMP_CYC_NUM+1) ;
localparam CNT1_EN      = 8'b1000_0000           ;
localparam CNT2_EN      = 8'b0100_0000           ;
//==================================
//var delcaration
//==================================
logic [CNT_W-1:     0] cnt1;
logic [CNT_W-1:     0] cnt2;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cnt1 <= CNT_W'(0);    
    end
    else if(i_reg_dvdt_tm==CNT1_EN) begin
        cnt1 <= (cnt1==SAMP_CYC_NUM) ? SAMP_CYC_NUM : (cnt1+1'b1);
    end
    else begin
        cnt1 <= CNT_W'(0);        
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cnt2 <= CNT_W'(0);    
    end
    else if(i_reg_dvdt_tm==CNT2_EN) begin
        cnt2 <= (cnt2==SAMP_CYC_NUM) ? SAMP_CYC_NUM : (cnt2+1'b1);
    end
    else begin
        cnt2 <= CNT_W'(0);        
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_cap_trim_code_read <= 8'b0;    
    end
    else if((i_reg_dvdt_tm==CNT1_EN) && (cnt1==(SAMP_CYC_NUM-1))) begin
        o_cap_trim_code_read <= {i_off_vbn_read, i_on_vbn_read};
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_cnt_del_read <= 6'b0;    
    end
    else if((i_reg_dvdt_tm==CNT2_EN) && (cnt2==(SAMP_CYC_NUM-1))) begin
        o_cnt_del_read <= i_cnt_del_read;
    end
    else;
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule


