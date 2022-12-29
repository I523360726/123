//============================================================
//Module   : hv_spi_owt_acc_arb
//Function : spi & owt acc arbiter
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_spi_owt_acc_arb #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                    i_spi_wr_req        ,
    input  logic                    i_spi_rd_req        ,
    input  logic [REG_AW-1:     0]  i_spi_addr          ,
    input  logic [REG_DW-1:     0]  i_spi_wdata         ,
    input  logic [REG_CRC_W-1:  0]  i_spi_wcrc          ,

    output logic                    o_spi_wack          ,
    output logic                    o_spi_rack          ,
    output logic [REG_DW-1:     0]  o_spi_data          ,
    output logic [REG_AW-1:     0]  o_spi_addr          ,

    input  logic                    i_d2d1rx_dpu_vld    ,
    input  logic [7:    0]          i_d2d1rx_dpu_addr   ,
    input  logic [7:    0]          i_d2d1rx_dpu_data   ,
    output logic                    o_dpu_d2d1rx_rdy    ,

    output logic                    o_rac_wr_req        ,//rac == reg_access_ctrl
    output logic                    o_rac_rd_req        ,
    output logic [REG_AW-1:     0]  o_rac_addr          ,
    output logic [REG_DW-1:     0]  o_rac_wdata         ,
    output logic [REG_CRC_W-1:  0]  o_rac_wcrc          ,

    input  logic                    i_rac_wack          ,
    input  logic                    i_rac_rack          ,
    input  logic [REG_DW-1:     0]  i_rac_data          ,
    input  logic [REG_AW-1:     0]  i_rac_addr          ,

    input  logic                    i_clk               ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic           cur_acc_flag        ; //0: owt; 1: spi
logic           spi_req_ing         ;
logic           owt_req_ing         ;
logic [15:  0]  crc16to8_data_in    ;
logic [7:   0]  crc16to8_out        ;
//==================================
//main code
//==================================
assign spi_req_ing = (i_spi_wr_req | i_spi_rd_req) & (cur_acc_flag==1) ;
assign owt_req_ing = i_d2d1rx_dpu_vld & ~cur_acc_flag                  ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    cur_acc_flag <= 1'b0;
	end
    else if(i_d2d1rx_dpu_vld & ~spi_req_ing) begin
  	    cur_acc_flag <= 1'b0;
    end
    else if((i_spi_wr_req | i_spi_rd_req) & ~owt_req_ing) begin
  	    cur_acc_flag <= 1'b1;    
    end
    else;
end

assign crc16to8_data_in  = {i_d2d1rx_dpu_addr, i_d2d1rx_dpu_data};

crc16to8_parallel U_CRC16to8(
    .data_in(crc16to8_data_in    ),
    .crc_out(crc16to8_out        )
);


assign o_rac_wr_req = cur_acc_flag ? i_spi_wr_req : i_d2d1rx_dpu_vld        ;
assign o_rac_rd_req = cur_acc_flag ? i_spi_rd_req : 1'b0                    ;
assign o_rac_addr   = cur_acc_flag ? i_spi_addr   : i_d2d1rx_dpu_addr[6: 0] ;
assign o_rac_wdata  = cur_acc_flag ? i_spi_wdata  : i_d2d1rx_dpu_data       ;
assign o_rac_wcrc   = cur_acc_flag ? i_spi_wcrc   : crc16to8_out            ;

assign o_spi_wack   = cur_acc_flag ? i_rac_wack : 1'b0;
assign o_spi_rack   = cur_acc_flag ? i_rac_rack : 1'b0;
assign o_spi_data   = cur_acc_flag ? i_rac_data : 8'b0;
assign o_spi_addr   = cur_acc_flag ? i_rac_addr : 7'b0;

assign o_dpu_d2d1rx_rdy = ~cur_acc_flag & i_rac_wack ;
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

