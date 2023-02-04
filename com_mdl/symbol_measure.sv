//============================================================
//Module   : symbol measure
//Function : measure symbol len
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module symbol_measure #(
    `include "com_param.svh"
    parameter END_OF_LIST = 1
)(
    input  logic                            i_owt_edge  ,
    input  logic                            i_cnt_flg   ,

    output logic                            o_vld       ,
    output logic [CNT_OWT_EXT_CYC_W-1: 0]   o_len       ,

    input  logic                            i_clk       ,
    input  logic                            i_rst_n
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic [CNT_OWT_EXT_CYC_W-1: 0] cnt;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cnt <= CNT_OWT_EXT_CYC_W'(1);
    end
    else if(i_cnt_flg) begin
        if(i_owt_edge) begin
            cnt <= CNT_OWT_EXT_CYC_W'(1);
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end
    else begin
        cnt <= CNT_OWT_EXT_CYC_W'(1);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_len <= CNT_OWT_EXT_CYC_W'(1);
    end
    else if(i_cnt_flg) begin
        o_len <= i_owt_edge ? cnt : o_len;
    end 
    else begin
        o_len <= CNT_OWT_EXT_CYC_W'(0);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_vld <= 1'b0;
    end
    else if(i_cnt_flg) begin
        o_vld <= i_owt_edge ? 1'b1 : 1'b0;
    end 
    else begin
        o_vld <= 1'b0;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on
endmodule

