//============================================================
//Module   : lv_abist
//Function : lv analog circuit bist.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_abist #(
    `include "com_param.svh"
    parameter END_OF_LIST          = 1
)(
    input  logic            i_bist_en            , 
    input  logic            i_lv_vsup_ov         ,

    output logic            o_lbist_en           ,
    output logic            o_lv_abist_rult      ,
    output logic            o_bistlv_ov          ,
    input  logic            i_clk                ,
    input  logic            i_rst_n
 );
//==================================
//local param delcaration
//==================================
parameter BIST_70US_CYC_NUM    = 70*CLK_M                     ;
parameter BIST_CNT_W           = $clog2(BIST_70US_CYC_NUM+1)  ;
//==================================
//var delcaration
//==================================
logic [BIST_CNT_W-1: 0]  bist_cnt           ;
logic                    lv_abist_fail      ;
logic                    dgt_ang_start      ;
logic                    dgt_ang_end        ;
logic                    abist_end          ;
logic                    bist_cnt_start     ;
logic                    bist_cnt_stop      ;
logic                    bist_en_ff         ;
logic                    lv_vsup_ov_ff      ;
logic                    bist_sel           ;
//==================================
//main code
//==================================
assign bist_cnt_start = dgt_ang_start;
assign bist_cnt_stop  = dgt_ang_end  ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        bist_en_ff <= 1'b0;
    end
    else begin
        bist_en_ff <= i_bist_en;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_vsup_ov_ff <= 1'b0;
    end
    else begin
        lv_vsup_ov_ff <= i_lv_vsup_ov;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        bist_cnt <= BIST_CNT_W'(0);
    end
    else if(i_bist_en) begin
        if(bist_cnt_start) begin
            bist_cnt <= BIST_CNT_W'(0);
        end
        else if(bist_cnt_stop) begin
            bist_cnt <= bist_cnt;
        end
        else begin
            bist_cnt <= (bist_cnt+1'b1);
        end
    end
    else begin
        bist_cnt <= BIST_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        bist_sel <= 1'b0;
    end
    else if(i_bist_en) begin
        if(abist_end) begin
            bist_sel <= 1'b1; 
        end 
        else;
    end
    else begin
        bist_sel <= 1'b0;    
    end
end

assign dgt_ang_start = i_bist_en & ~bist_en_ff;
assign dgt_ang_end   = (i_lv_vsup_ov & (bist_cnt<BIST_70US_CYC_NUM) & ~bist_sel) || 
                       (~i_lv_vsup_ov & (bist_cnt>=BIST_70US_CYC_NUM) & ~bist_sel);
//assign abist_end     = (~i_lv_vsup_ov & lv_vsup_ov_ff & (bist_cnt<BIST_70US_CYC_NUM) & ~bist_sel) || 
//                       (~i_lv_vsup_ov & (bist_cnt>=BIST_70US_CYC_NUM) & ~bist_sel);
assign abist_end = dgt_ang_end;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_abist_fail <= 1'b0;
    end
    else if(i_bist_en) begin
        if(i_lv_vsup_ov & (bist_cnt<BIST_70US_CYC_NUM) & ~bist_sel) begin
            lv_abist_fail <= 1'b0;
        end
        else if(~i_lv_vsup_ov & (bist_cnt>=BIST_70US_CYC_NUM) & ~bist_sel) begin
            lv_abist_fail <= 1'b1;		
        end
        else;
    end
    else begin
        lv_abist_fail <= 1'b0;        
    end
end

assign o_lv_abist_rult = lv_abist_fail;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_lbist_en <= 1'b0;
    end
    else if(i_bist_en) begin
        if(abist_end) begin
            o_lbist_en <= 1'b1;
        end
        else;
    end
    else begin
        o_lbist_en <= 1'b0;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_bistlv_ov <= 1'b0;
    end
    else if(i_bist_en) begin
        if(dgt_ang_start) begin
            o_bistlv_ov <= 1'b1;
        end
        else if(dgt_ang_end) begin
            o_bistlv_ov <= 1'b0;
        end
        else;
    end
    else begin
        o_bistlv_ov <= 1'b0;  
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule



