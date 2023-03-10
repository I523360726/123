//============================================================
//Module   : lv_lbist
//Function : lv digital circuit bist.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_lbist #(
    `include "lv_param.svh"
    parameter END_OF_LIST          = 1
)( 
    input  logic           i_bist_en                ,

    output logic           o_bist_wdg_owt_tx_req    ,
    input  logic           i_owt_rx_ack             ,
    input  logic           i_owt_rx_status          ,
    output logic           o_owt_bist_rutl          ,

    output logic           o_bist_scan_reg_req      ,
    input  logic           i_scan_reg_bist_ack      ,
    input  logic           i_scan_reg_bist_err      ,
    output logic           o_scan_reg_bist_rult     ,

    input  logic           i_hv_intb0_pulse         ,
    input  logic           i_hv_intb1_pulse         ,
    output logic           o_hv_intb_bist_rult      ,

    output logic           o_lv_bist_done           ,

    input  logic           i_clk                    ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam SCAN_CNT_W           = $clog2(LV_SCAN_REG_NUM+1) ;
//==================================
//var delcaration
//==================================
logic [SCAN_CNT_W-1:        0]  scan_cnt            ;
logic                           scan_reg_bist_err   ;
logic [BIST_OWT_TX_CNT_W-1: 0]  owt_tx_cnt          ;
logic [BIST_OWT_TX_CNT_W-1: 0]  owt_rx_ok_cnt       ;
logic [BIST_TMO_CNT_W-1:    0]  bist_tmo_cnt        ;
logic                           owt_bist_fail       ;
logic                           rx_intb_flag        ;
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
            scan_cnt <= (scan_cnt==LV_SCAN_REG_NUM) ? scan_cnt : (scan_cnt+1'b1);
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
    else if(i_bist_en & (scan_cnt<LV_SCAN_REG_NUM)) begin
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

assign o_scan_reg_bist_rult = scan_reg_bist_err;

//owt tx
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_tx_cnt <= BIST_OWT_TX_CNT_W'(0);
    end
    else if(i_bist_en) begin
        if(i_owt_rx_ack  & (bist_tmo_cnt<(BIST_TMO_TH-1))) begin
            owt_tx_cnt <= (owt_tx_cnt>=BIST_OWT_TX_NUM) ? owt_tx_cnt : (owt_tx_cnt+1'b1);
        end
        else;
    end
    else begin
        owt_tx_cnt <= BIST_OWT_TX_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_bist_wdg_owt_tx_req <= 1'b0;
    end
    else if(i_owt_rx_ack) begin
        o_bist_wdg_owt_tx_req <= 1'b0;    
    end
    else if(i_bist_en & (owt_tx_cnt<BIST_OWT_TX_NUM) & (bist_tmo_cnt<(BIST_TMO_TH-1))) begin
        o_bist_wdg_owt_tx_req <= 1'b1;
    end
    else begin
        o_bist_wdg_owt_tx_req <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_ok_cnt <= BIST_OWT_TX_CNT_W'(0);
    end
    else if(i_bist_en) begin
        if(i_owt_rx_ack & ~i_owt_rx_status  & (bist_tmo_cnt<(BIST_TMO_TH-1))) begin
            owt_rx_ok_cnt <= (owt_rx_ok_cnt>=BIST_OWT_TX_NUM) ? owt_rx_ok_cnt : (owt_rx_ok_cnt+1'b1);
        end
        else;
    end
    else begin
        owt_rx_ok_cnt <= BIST_OWT_TX_CNT_W'(0);
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
        owt_bist_fail <= 1'b0;
    end
    else if(i_bist_en) begin
        if((bist_tmo_cnt>=(BIST_TMO_TH-1))) begin
            if(owt_rx_ok_cnt<BIST_OWT_TX_OK_NUM) begin
                owt_bist_fail <= 1'b1;
            end
            else begin
                owt_bist_fail <= 1'b0;            
            end
        end
    end
    else begin
        owt_bist_fail <= 1'b0;    
    end
end

assign o_owt_bist_rutl = owt_bist_fail;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_intb_flag <= 1'b0;
    end
    else if(i_bist_en) begin 
        if(bist_tmo_cnt<(BIST_TMO_TH-1)) begin
            if(i_hv_intb0_pulse | i_hv_intb1_pulse) begin
                rx_intb_flag <= 1'b1;
            end
            else;
        end
    end
    else begin
        rx_intb_flag <= 1'b0;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_intb_bist_rult <= 1'b0;
    end
    else if(i_bist_en) begin 
        if(bist_tmo_cnt>=(BIST_TMO_TH-1)) begin
            if(rx_intb_flag) begin
                o_hv_intb_bist_rult <= 1'b0;
            end
            else begin
                o_hv_intb_bist_rult <= 1'b1;            
            end
        end
    end
    else begin
        o_hv_intb_bist_rult <= 1'b0;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_lv_bist_done <= 1'b0;
    end
    else if(i_bist_en) begin
        if(bist_tmo_cnt>=(BIST_TMO_TH-1)) begin
            o_lv_bist_done <= 1'b1;
        end
        else;
    end
    else begin
        o_lv_bist_done <= 1'b0;            
    end
end


// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

