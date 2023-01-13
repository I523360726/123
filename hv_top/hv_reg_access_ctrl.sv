//============================================================
//Module   : hv_reg_access_ctrl
//Function : reg access arbiter, rsp to spi slv.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_reg_access_ctrl #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_wdg_scan_rac_rd_req   , //rac = reg_access_ctrl
    input  logic [REG_AW-1:             0]  i_wdg_scan_rac_addr     ,
    output logic                            o_rac_wdg_scan_ack      ,
    output logic [REG_DW-1:             0]  o_rac_wdg_scan_data     ,
    output logic [REG_CRC_W-1:          0]  o_rac_wdg_scan_crc      ,

    input  logic                            i_spi_rac_wr_req        ,
    input  logic                            i_spi_rac_rd_req        ,
    input  logic [REG_AW-1:             0]  i_spi_rac_addr          ,
    input  logic [REG_DW-1:             0]  i_spi_rac_wdata         ,
    input  logic [REG_CRC_W-1:          0]  i_spi_rac_wcrc          ,

    output logic                            o_rac_spi_wack          ,
    output logic                            o_rac_spi_rack          ,
    output logic [REG_DW-1:             0]  o_rac_spi_data          ,
    output logic [REG_AW-1:             0]  o_rac_spi_addr          ,

    input  logic                            i_owt_rx_rac_vld        ,
    input  logic [OWT_CMD_BIT_NUM-1:    0]  i_owt_rx_rac_cmd        ,
    input  logic [OWT_DATA_BIT_NUM-1:   0]  i_owt_rx_rac_data       ,
    input  logic [OWT_CRC_BIT_NUM-1:    0]  i_owt_rx_rac_crc        ,
    input  logic                            i_owt_rx_rac_status     ,

    output logic                            o_rac_owt_tx_wr_cmd_vld ,
    output logic                            o_rac_owt_tx_rd_cmd_vld ,
    output logic [REG_AW-1:             0]  o_rac_owt_tx_addr       ,
    output logic [OWT_ADCD_BIT_NUM-1:   0]  o_rac_owt_tx_data       ,

    input  logic [ADC_DW-1:             0]  i_adc1_data             ,
    input  logic [ADC_DW-1:             0]  i_adc2_data             ,

    output logic                            o_rac_reg_ren           ,
    output logic                            o_rac_reg_wen           ,
    output logic [REG_AW-1:             0]  o_rac_reg_addr          ,
    output logic [REG_DW-1:             0]  o_rac_reg_wdata         ,
    output logic [REG_CRC_W-1:          0]  o_rac_reg_wcrc          ,

    input  logic                            i_reg_rac_wack          ,
    input  logic                            i_reg_rac_rack          ,
    input  logic [REG_DW-1:             0]  i_reg_rac_rdata         ,
    input  logic [REG_CRC_W-1:          0]  i_reg_rac_rcrc          ,

    input  logic                            i_clk                   ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                                       owt_rx_reg_wr_req           ;
logic                                       owt_rx_reg_rd_req           ;
logic [REG_AW-1:                0]          owt_rx_reg_addr             ;
logic [REG_DW-1:                0]          owt_rx_reg_wdata            ;
logic [REG_CRC_W-1:             0]          owt_rx_reg_wcrc             ;

logic                                       owt_rx_reg_ren              ;
logic                                       owt_rx_reg_wen              ;

logic                                       spi_reg_wen                 ;
logic                                       spi_reg_ren                 ;

logic                                       owt_grant                   ;
logic                                       wdg_scan_grant              ;
logic                                       spi_grant                   ;

logic                                       owt_wr_ack                  ;
logic                                       owt_rd_ack                  ;
logic [REG_DW-1:                0]          rac_spi_data                ;
logic [REG_AW-1:                0]          rac_spi_addr                ;  
logic                                       lanch_last_owt_tx           ;  

logic                                       tx_cmd_lock                 ;
logic [LANCH_LST_TX_CNT_W-1:    0]          lanch_lst_tx_cnt            ;
logic                                       lanch_lst_tx_flag           ;

logic                                       cur_is_owt_acc              ;
logic                                       cur_is_spi_acc              ;
logic                                       cur_is_wdg_acc              ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_reg_wr_req <= 1'b0;
    end
    else if(cur_is_owt_acc & i_reg_rac_wack) begin
        owt_rx_reg_wr_req <= 1'b0;    
    end
    else if(i_owt_rx_rac_vld & ~i_owt_rx_rac_status & i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1]) begin
        owt_rx_reg_wr_req <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_reg_rd_req <= 1'b0;
    end
    else if(cur_is_owt_acc & i_reg_rac_rack) begin
        owt_rx_reg_rd_req <= 1'b0;    
    end
    else if(i_owt_rx_rac_vld & ~i_owt_rx_rac_status & ~i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1]) begin
        owt_rx_reg_rd_req <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk) begin
    if(i_owt_rx_rac_vld & ~i_owt_rx_rac_status) begin
        owt_rx_reg_addr <= i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-2: 0];
    end
    else;
end

always_ff@(posedge i_clk) begin
    if(i_owt_rx_rac_vld & ~i_owt_rx_rac_status & i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1]) begin
        owt_rx_reg_wdata <= i_owt_rx_rac_data;
    end
    else;
end

always_ff@(posedge i_clk) begin
    if(i_owt_rx_rac_vld & ~i_owt_rx_rac_status & i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1]) begin
        owt_rx_reg_wcrc <= i_owt_rx_rac_crc;
    end
    else;
end

assign owt_grant = (~cur_is_owt_acc & ~cur_is_spi_acc & ~cur_is_wdg_acc) & 
                   (owt_rx_reg_rd_req | owt_rx_reg_wr_req);

assign owt_rx_reg_ren = owt_grant & owt_rx_reg_rd_req ;
assign owt_rx_reg_wen = owt_grant & owt_rx_reg_wr_req ;              

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cur_is_owt_acc <= 1'b0;
    end
    else if(cur_is_owt_acc & (i_reg_rac_rack | i_reg_rac_wack)) begin
        cur_is_owt_acc <= 1'b0;    
    end
    else if(owt_grant) begin
        cur_is_owt_acc <= 1'b1;
    end
    else;
end

assign spi_grant = (i_spi_rac_wr_req | i_spi_rac_rd_req) & 
                  ~(owt_rx_reg_rd_req | owt_rx_reg_wr_req) & 
                   (~cur_is_owt_acc & ~cur_is_spi_acc & ~cur_is_wdg_acc) ;

assign spi_reg_wen = i_spi_rac_wr_req & spi_grant;
assign spi_reg_ren = i_spi_rac_rd_req & spi_grant;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cur_is_spi_acc <= 1'b0;
    end
    else if(cur_is_spi_acc & (i_reg_rac_rack | i_reg_rac_wack)) begin
        cur_is_spi_acc <= 1'b0;    
    end
    else if(spi_grant) begin
        cur_is_spi_acc <= 1'b1;
    end
    else;
end

assign wdg_scan_grant = (~cur_is_owt_acc & ~cur_is_spi_acc & ~cur_is_wdg_acc) &
                         ~(owt_rx_reg_rd_req | owt_rx_reg_wr_req) &
                         ~(i_spi_rac_wr_req | i_spi_rac_rd_req) &
                        i_wdg_scan_rac_rd_req;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cur_is_wdg_acc <= 1'b0;
    end
    else if(cur_is_wdg_acc & (i_reg_rac_rack | i_reg_rac_wack)) begin
        cur_is_wdg_acc <= 1'b0;    
    end
    else if(wdg_scan_grant) begin
        cur_is_wdg_acc <= 1'b1;
    end
    else;
end

assign o_rac_wdg_scan_ack  = i_reg_rac_rack & cur_is_wdg_acc  ;
assign o_rac_wdg_scan_data = i_reg_rac_rdata                  ;
assign o_rac_wdg_scan_crc  = i_reg_rac_rcrc                   ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_ren <= 1'b0;
    end
    else begin
        o_rac_reg_ren <= owt_rx_reg_ren | spi_reg_ren | wdg_scan_grant;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wen <= 1'b0;
    end
    else begin
        o_rac_reg_wen <= owt_rx_reg_wen | spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_addr <= REG_AW'(0);
    end
    else if(owt_rx_reg_wen | owt_rx_reg_ren) begin
        o_rac_reg_addr <= owt_rx_reg_addr;    
    end
    else if(spi_reg_wen | spi_reg_ren) begin
        o_rac_reg_addr <= i_spi_rac_addr;
    end
    else if(wdg_scan_grant) begin
        o_rac_reg_addr <= i_wdg_scan_rac_addr;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wdata <= REG_DW'(0);
    end
    else if(owt_rx_reg_wen) begin
        o_rac_reg_wdata <= owt_rx_reg_wdata;
    end
    else if(spi_reg_wen) begin
        o_rac_reg_wdata <= i_spi_rac_wdata;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wcrc <= REG_CRC_W'(0);
    end
    else if(owt_rx_reg_wen) begin
        o_rac_reg_wcrc <= owt_rx_reg_wcrc;
    end
    else if(i_spi_rac_wr_req) begin
        o_rac_reg_wcrc <= i_spi_rac_wcrc;
    end
    else;
end
                       
assign rac_spi_data   = i_reg_rac_wack ? o_rac_reg_wdata : i_reg_rac_rdata;
assign rac_spi_addr   = o_rac_reg_addr;

assign o_rac_spi_wack = i_reg_rac_wack & cur_is_spi_acc ; 
assign o_rac_spi_rack = i_reg_rac_rack & cur_is_spi_acc ;
assign o_rac_spi_data = rac_spi_data                    ;
assign o_rac_spi_addr = rac_spi_addr                    ;


always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_wr_cmd_vld <= 1'b0;
        o_rac_owt_tx_rd_cmd_vld <= 1'b0;        
    end
    else begin
        o_rac_owt_tx_wr_cmd_vld <= (i_reg_rac_wack & cur_is_owt_acc) | (lanch_last_owt_tx & (tx_cmd_lock==WR_OP)); 
        o_rac_owt_tx_rd_cmd_vld <= (i_reg_rac_rack & cur_is_owt_acc) | (lanch_last_owt_tx & (tx_cmd_lock==RD_OP));           
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        tx_cmd_lock <= WR_OP;
    end
    else if(i_reg_rac_wack & cur_is_owt_acc) begin
        tx_cmd_lock <= WR_OP;    
    end
    else if(i_reg_rac_rack & cur_is_owt_acc) begin
        tx_cmd_lock <= RD_OP;    
    end
    else;
end


always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_addr <= REG_AW'(0);
    end
    else if((i_reg_rac_wack | i_reg_rac_rack) & cur_is_owt_acc) begin
        o_rac_owt_tx_addr <= o_rac_reg_addr;    
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_data <= REG_DW'(0);
    end
    else if(i_reg_rac_wack & cur_is_owt_acc) begin
        o_rac_owt_tx_data <= {{(OWT_ADCD_BIT_NUM-REG_DW){1'b0}}, o_rac_reg_wdata};    
    end
    else if(i_reg_rac_rack & cur_is_owt_acc) begin
        o_rac_owt_tx_data <= (o_rac_reg_addr==REQ_ADC_ADDR) ? {i_adc2_data, i_adc1_data} : {{(OWT_ADCD_BIT_NUM-REG_DW){1'b0}}, i_reg_rac_rdata};    
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lanch_lst_tx_flag <= 1'b0;
    end
    else if(lanch_lst_tx_cnt==(MAX_OWT_TX_CYC_NUM-1)) begin
        lanch_lst_tx_flag <= 1'b0;
    end
    else if(i_owt_rx_rac_vld & i_owt_rx_rac_status) begin
        lanch_lst_tx_flag <= 1'b1;        
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lanch_lst_tx_cnt <= LANCH_LST_TX_CNT_W'(0);
    end
    else if(lanch_lst_tx_flag) begin
        lanch_lst_tx_cnt <= (lanch_lst_tx_cnt==(MAX_OWT_TX_CYC_NUM-1)) ? LANCH_LST_TX_CNT_W'(0) : (lanch_lst_tx_cnt+1'b1);
    end
    else begin
        lanch_lst_tx_cnt <= LANCH_LST_TX_CNT_W'(0);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lanch_last_owt_tx <= 1'b0;
    end
    else begin
        lanch_last_owt_tx <= (lanch_lst_tx_cnt==(MAX_OWT_TX_CYC_NUM-1));
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule






















