//============================================================
//Module   : hv_lbist
//Function : hv digital circuit bist.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_lbist #(
    `include "hv_param.svh"
    parameter END_OF_LIST          = 1
)( 
    input  logic           i_bist_en                ,

    input  logic           i_owt_rx_ack             ,
    input  logic           i_owt_rx_status          ,
    output logic           o_hv_owt_bist_rult       ,

    output logic           o_bist_scan_reg_req      ,
    input  logic           i_scan_reg_bist_ack      ,
    input  logic           i_scan_reg_bist_err      ,
    output logic           o_hv_scan_bist_rult      ,

    output logic           o_hv_bist_done           ,

    input  logic           i_clk                    ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam SCAN_CNT_W           = $clog2(HV_SCAN_REG_NUM+1) ;
//==================================
//var delcaration
//==================================
logic [SCAN_CNT_W-1:        0]  scan_cnt            ;
logic                           scan_reg_bist_err   ;
logic [BIST_OWT_RX_CNT_W-1: 0]  owt_rx_ok_cnt       ;
logic [BIST_TMO_CNT_W-1:    0]  bist_tmo_cnt        ;
//==================================
//main code
//==================================
//scan reg
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        scan_cnt <= SCAN_CNT_W'(0);
    end
    else if(i_bist_en) begin
        if(i_scan_reg_bist_ack) begin
            scan_cnt <= (scan_cnt==HV_SCAN_REG_NUM) ? scan_cnt : (scan_cnt+1'b1);
        end
        else;
    end
    else begin
        scan_cnt <= SCAN_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_bist_scan_reg_req <= 1'b0;
    end
    else if(i_scan_reg_bist_ack) begin
        o_bist_scan_reg_req <= 1'b0;    
    end
    else if(i_bist_en & (scan_cnt<HV_SCAN_REG_NUM)) begin
        o_bist_scan_reg_req <= 1'b1;
    end
    else begin
        o_bist_scan_reg_req <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        scan_reg_bist_err <= 1'b0;
    end
    else if(i_bist_en) begin
        if(i_scan_reg_bist_ack & i_scan_reg_bist_err) begin
            scan_reg_bist_err <= 1'b1;
        end
        else;
    end
    else begin
        scan_reg_bist_err <= 1'b0;    
    end
end

assign o_hv_scan_bist_rult = scan_reg_bist_err;

//owt
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_ok_cnt <= BIST_OWT_RX_CNT_W'(0);
    end
    else if(i_bist_en) begin
        if(i_owt_rx_ack & ~i_owt_rx_status & (bist_tmo_cnt<(BIST_TMO_TH-1))) begin
            owt_rx_ok_cnt <= (owt_rx_ok_cnt>=BIST_OWT_TX_NUM) ? owt_rx_ok_cnt : (owt_rx_ok_cnt+1'b1);
        end
        else;
    end
    else begin
        owt_rx_ok_cnt <= BIST_OWT_RX_CNT_W'(0);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        bist_tmo_cnt <= BIST_TMO_CNT_W'(0);
    end
    else if(i_bist_en) begin
        bist_tmo_cnt <= (bist_tmo_cnt>=(BIST_TMO_TH-1)) ? bist_tmo_cnt : (bist_tmo_cnt+1'b1);
    end
    else begin
        bist_tmo_cnt <= BIST_TMO_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_owt_bist_rult <= 1'b0;
    end
    else if(i_bist_en) begin
        if(bist_tmo_cnt>=(BIST_TMO_TH-1)) begin
            if((owt_rx_ok_cnt<BIST_OWT_RX_OK_NUM)) begin
                o_hv_owt_bist_rult <= 1'b1;
            end
            else begin
                o_hv_owt_bist_rult <= 1'b0;            
            end
        end
    end
    else begin
        o_hv_owt_bist_rult <= 1'b0;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_bist_done <= 1'b0;
    end
    else if(i_bist_en & (bist_tmo_cnt>=(BIST_TMO_TH-1))) begin
        o_hv_bist_done <= 1'b1;  
    end
    else begin
        o_hv_bist_done <= 1'b0;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

