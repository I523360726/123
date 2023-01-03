//============================================================
//Module   : gen_spi_sig
//Function : gen spi sig
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module gen_spi_sig #(
    parameter MODE                 = 0 , //0: no chain; 1: dasiy-chain mode
    parameter END_OF_LIST          = 1
)( 
    input  logic                i_clk       ,
    input  logic                i_rst_n     ,

    output logic                o_sclk      ,
    output logic                o_csb       ,
    output logic                o_mosi      ,
    input  logic                i_miso      
);
//==================================
//local param delcaration
//==================================
parameter   SPI_CYC_CNT         = 24                                        ;  
parameter   SPI_CYC_CNT_W       = $clog2(SPI_CYC_CNT+1)                     ;
parameter   PRE_CYC_NUM         = 3                                         ;
parameter   LOAD_CYC_NUM        = 3                                         ;
parameter   TX_CYC_NUM          = SPI_CYC_CNT                               ;
parameter   WAIT_CYC_NUM        = 10                                        ;
parameter   CLR_CYC_NUM         = 6                                         ;
parameter   END_CYC_NUM         = 500                                       ;
parameter   ST_CNT_W            = $clog2(END_CYC_NUM)                       ;
parameter   DASIY_NUM           = 1                                         ;
parameter   DASIY_CNT_W         = (DASIY_NUM==1) ? 1 : $clog2(DASIY_NUM)    ;

parameter   ST_NUM              = 7                                         ;
parameter   ST_W                = $clog2(ST_NUM)                            ;               
parameter   IDLE_ST             = ST_W'(0)                                  ;
parameter   PRE_ST              = ST_W'(1)                                  ;
parameter   LOAD_ST             = ST_W'(2)                                  ;
parameter   TX_ST               = ST_W'(3)                                  ;
parameter   WAIT_ST             = ST_W'(4)                                  ;
parameter   CLR_ST              = ST_W'(5)                                  ;
parameter   END_ST              = ST_W'(6)                                  ;
//==================================
//var delcaration
//==================================
logic                        clk_en             ;
logic [ST_W-1:          0]   cur_st             ;
logic [ST_W-1:          0]   nxt_st             ;
logic [ST_CNT_W-1:      0]   st_cnt             ;
logic [DASIY_CNT_W-1:   0]   dasiy_cnt          ;
logic                        tx_done            ;
logic [23:              0]   spi_rx_bit         ;
logic [23:              0]   spi_tx_bit         ;
logic [15:              0]   crc16to8_data_in   ;
logic [7:               0]   crc16to8_out       ;
logic [7:               0]   spi_cmd_cnt        ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cur_st <= IDLE_ST;
    end
    else begin
        cur_st <= nxt_st;
    end
end

always_comb begin
    nxt_st = cur_st;
    case(cur_st)
        IDLE_ST : begin
            nxt_st = PRE_ST;
        end
        PRE_ST : begin
            if(st_cnt==(PRE_CYC_NUM-1)) begin
                nxt_st = LOAD_ST;
            end
            else;
        end
        LOAD_ST : begin
            if(st_cnt==(LOAD_CYC_NUM-1)) begin
                nxt_st = TX_ST;
            end
            else;
        end
        TX_ST : begin
            if((st_cnt==(TX_CYC_NUM-1)) & (dasiy_cnt==(DASIY_NUM-1))) begin
                nxt_st = CLR_ST;
            end
            else if((st_cnt==(TX_CYC_NUM-1)) & (dasiy_cnt<(DASIY_NUM-1))) begin
                nxt_st = WAIT_ST;
            end
            else;
        end
        WAIT_ST : begin
            if(st_cnt==(WAIT_CYC_NUM-1)) begin
                nxt_st = TX_ST;
            end
            else;
        end
        CLR_ST : begin
            if(st_cnt==(CLR_CYC_NUM-1)) begin
                nxt_st = END_ST;
            end
            else;
        end
        END_ST : begin
            if(st_cnt==(END_CYC_NUM-1)) begin
                nxt_st = IDLE_ST;
            end
            else;
        end
        default : begin
            nxt_st = IDLE_ST;
        end
    endcase
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        st_cnt <= ST_CNT_W'(0);
    end
    else if(cur_st==PRE_ST) begin
        st_cnt <= (st_cnt==(PRE_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else if(cur_st==LOAD_ST) begin
        st_cnt <= (st_cnt==(LOAD_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else if(cur_st==TX_ST) begin
        st_cnt <= (st_cnt==(TX_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else if(cur_st==WAIT_ST) begin
        st_cnt <= (st_cnt==(WAIT_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else if(cur_st==CLR_ST) begin
        st_cnt <= (st_cnt==(CLR_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else if(cur_st==END_ST) begin
        st_cnt <= (st_cnt==(END_CYC_NUM-1)) ? ST_CNT_W'(0) : (st_cnt+1'b1);
    end
    else begin
        st_cnt <= ST_CNT_W'(0);
    end
end

assign tx_done = (cur_st==TX_ST) & (st_cnt==(TX_CYC_NUM-1));

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        dasiy_cnt <= DASIY_CNT_W'(0);
    end
    else if((cur_st==TX_ST) || (cur_st==WAIT_ST)) begin
        dasiy_cnt <= tx_done ? (dasiy_cnt+1'b1) : dasiy_cnt;
    end
    else begin
        dasiy_cnt <= DASIY_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_cmd_cnt <= 8'b0;
    end
    else if((cur_st==CLR_ST) && (nxt_st==END_ST)) begin
        spi_cmd_cnt <= spi_cmd_cnt+1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_csb <= 1'b1;
    end
    else if(nxt_st==LOAD_ST) begin
        o_csb <= 1'b0;
    end
    else if(nxt_st==END_ST) begin
        o_csb <= 1'b1;
    end
    else;
end

assign clk_en = (cur_st==TX_ST);

gnrl_clkgate U_GNRL_CLKGATE(
    .i_clk          (i_clk       ),
    .i_test_mode    (1'b0        ),
    .i_clk_en       (clk_en      ),
    .o_clk          (o_sclk      )
);

assign crc16to8_data_in = (spi_cmd_cnt==8'h0) ? ({1'b1, 7'h40, 8'h5B}) : 
                          (spi_cmd_cnt==8'h1) ? ({1'b0, 7'h40, 8'h00}) : 
                          (spi_cmd_cnt==8'h2) ? ({1'b1, 7'h6E, 8'hA6}) : 
                                                ({1'b0, 7'h6E, 8'h00}) ;

crc16to8_parallel U_CRC16to8(
    .data_in(crc16to8_data_in    ),
    .crc_out(crc16to8_out        )
);

assign spi_tx_bit = {crc16to8_data_in, crc16to8_out};

always_ff@(negedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_mosi <= spi_tx_bit[SPI_CYC_CNT-1];    
    end
    else if(o_csb) begin
        o_mosi <= spi_tx_bit[SPI_CYC_CNT-1];
    end
    else begin
        o_mosi <= spi_tx_bit[SPI_CYC_CNT-1-st_cnt];
    end    
end

always_ff@(posedge o_sclk) begin
    spi_rx_bit <= {spi_rx_bit[22: 0], i_miso};
end

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule

