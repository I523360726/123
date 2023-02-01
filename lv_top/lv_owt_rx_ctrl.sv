//============================================================
//Module   : lv_owt_rx_ctrl
//Function : one wire bus req & ack. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_owt_rx_ctrl #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_hv_lv_owt_rx              ,
    output logic                            o_owt_rx_ack                ,
    output logic [OWT_CMD_BIT_NUM-1:    0]  o_owt_rx_cmd                ,
    output logic [OWT_ADCD_BIT_NUM-1:   0]  o_owt_rx_data               ,
    output logic                            o_owt_rx_status             ,//0: normal; 1: error. 

    output logic                            o_owt_rx_wdg_rsp            ,                        

    input  logic                            i_reg_comerr_mode           ,
    input  logic [3:                    0]  i_reg_comerr_config         ,
    output logic                            o_owt_com_err               ,

    input  logic [OWT_CMD_BIT_NUM-1:    0]  i_owt_tx_cmd_lock           ,        
    
    input  logic                            i_clk                       ,
    input  logic                            i_rst_n
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic [OWT_FSM_ST_W-1:          0]  owt_rx_cur_st       ;
logic [OWT_FSM_ST_W-1:          0]  owt_rx_nxt_st       ;
logic                               rx_vld              ;
logic                               rx_vld_data         ;
logic                               rx_vld_lock         ;
logic                               rx_vld_data_lock    ;
logic                               rx_gen_mcst_code    ;
logic                               rx_mcst_vld_zero    ;//Manchester code
logic                               rx_mcst_vld_one     ;
logic                               rx_mcst_invld       ;
logic [CNT_OWT_MAX_W-1:         0]  rx_cnt_bit          ;
logic                               rx_bit_done         ;
logic [OWT_TAIL_BIT_NUM-1:      0]  rx_sync_tail_bit    ;
logic [OWT_CMD_BIT_NUM-1:       0]  rx_cmd_data         ;
logic [OWT_DATA_BIT_NUM-1:      0]  rx_nml_data         ;
logic [OWT_ADCD_BIT_NUM-1:      0]  rx_adc_data         ;
logic [OWT_CRC_BIT_NUM-1:       0]  rx_crc_data         ;
logic                               rx_cmd_rd           ;
logic                               rx_cmd_wr           ;
logic                               crc8_chk_vld        ;
logic                               crc8_chk_bit        ;
logic                               crc8_chk_start      ;
logic [OWT_CRC_BIT_NUM-1:       0]  crc8_chk_o_crc      ;
logic                               owt_rx_status       ;
logic                               owt_rx_ack          ;
logic [OWT_COM_ERR_CNT_W-1:     0]  owt_com_err_cnt     ;
logic [1:                       0]  owt_com_err_add_sel ;
logic [1:                       0]  owt_com_cor_sub_sel ;
logic                               owt_com_err         ;
logic                               rx_pos              ;
logic                               rx_neg              ;
logic                               hv_lv_owt_rx        ;
logic                               hv_lv_owt_rx_ff     ;
logic [CNT_OWT_EXT_CYC_W-1:     0]  dn_th               ;
logic [CNT_OWT_EXT_CYC_W-1:     0]  up_th               ;
logic [CNT_OWT_EXT_CYC_W-1:     0]  symbol_cyc_cnt      ;
logic [CNT_OWT_EXT_CYC_W-1:     0]  symbol_cyc_cnt_lock ;
logic [DLY_RX_ACK_CNT_W-1:      0]  dly_rx_ack_cnt      ;
logic                               dly_rx_ack_flag     ;
logic                               dly_rx_ack          ;
logic                               measure_symbol_flag ;
//==================================
//main code
//==================================
assign rx_pos =  hv_lv_owt_rx & ~hv_lv_owt_rx_ff;
assign rx_neg = ~hv_lv_owt_rx &  hv_lv_owt_rx_ff;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        measure_symbol_flag <= 1'b0;
    end
    else if(owt_rx_cur_st==OWT_SYNC_HEAD_ST) begin
        if(rx_pos & ~measure_symbol_flag) begin
            measure_symbol_flag <= 1'b1;
        end
        //else if(rx_neg) begin
        //    measure_symbol_flag <= 1'b0;            
        //end
        else;
    end
    else begin
        measure_symbol_flag <= 1'b0;        
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        symbol_cyc_cnt <= CNT_OWT_EXT_CYC_W'(1);
    end
    else if(measure_symbol_flag) begin
        symbol_cyc_cnt <= (rx_neg | rx_pos) ? CNT_OWT_EXT_CYC_W'(1) : (symbol_cyc_cnt+1'b1);
    end
    else begin
        symbol_cyc_cnt <= CNT_OWT_EXT_CYC_W'(1);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        symbol_cyc_cnt_lock <= CNT_OWT_EXT_CYC_W'(0);
    end
    else if(owt_rx_cur_st==OWT_IDLE_ST) begin
        symbol_cyc_cnt_lock <= CNT_OWT_EXT_CYC_W'(0);   
    end
    else if((rx_neg | rx_pos) & (owt_rx_cur_st==OWT_SYNC_HEAD_ST)) begin
        if(symbol_cyc_cnt_lock>=symbol_cyc_cnt) begin
            symbol_cyc_cnt_lock <= symbol_cyc_cnt_lock;        
        end
        else begin
            symbol_cyc_cnt_lock <= symbol_cyc_cnt; 
        end
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_cur_st <= OWT_FSM_ST_W'(0);
    end
    else begin
        owt_rx_cur_st <= owt_rx_nxt_st;
    end
end

always_comb begin
    owt_rx_nxt_st = owt_rx_cur_st;
    case(owt_rx_cur_st)
        OWT_IDLE_ST : begin 
            if(rx_pos) begin
                owt_rx_nxt_st = OWT_SYNC_HEAD_ST;
            end
            else;
        end
        OWT_SYNC_HEAD_ST : begin
            //if(rx_mcst_vld_one | rx_mcst_invld) begin
            //    owt_rx_nxt_st = OWT_IDLE_ST;
            //end
            //else if(rx_bit_done) begin
            //    owt_rx_nxt_st = OWT_SYNC_TAIL_ST;    
            //end
            //else;
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_SYNC_TAIL_ST;    
            end
            else;
        end
        OWT_SYNC_TAIL_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                if(rx_sync_tail_bit==4'b1100) begin
                    owt_rx_nxt_st = OWT_CMD_ST;
                end
                else begin
                    owt_rx_nxt_st = OWT_IDLE_ST;
                end
            end
            else;
        end
        OWT_CMD_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_mcst_invld) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done & rx_cmd_rd & (rx_cmd_data[OWT_CMD_BIT_NUM-2: 0]==7'h1f)) begin
                owt_rx_nxt_st = OWT_ADC_DATA_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_NML_DATA_ST;
            end
            else;
        end
        OWT_ADC_DATA_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_mcst_invld) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_CRC_ST;
            end
            else;
        end
        OWT_NML_DATA_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_mcst_invld) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_CRC_ST;
            end
            else;       
        end
        OWT_CRC_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_mcst_invld) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_END_TAIL_ST;
            end
            else;       
        end
        OWT_END_TAIL_ST : begin
            if(dly_rx_ack) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else if(rx_bit_done) begin
                owt_rx_nxt_st = OWT_IDLE_ST;
            end
            else;
        end
        default : begin
            owt_rx_nxt_st = OWT_IDLE_ST;    
        end
    endcase
end

gnrl_sync #(
    .DW(1)
)U_GNRL_SYNC(
    .i_data     (i_hv_lv_owt_rx ),
    .o_data     (hv_lv_owt_rx   ),
    .i_clk      (i_clk          ),
    .i_rst_n    (i_rst_n        )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        hv_lv_owt_rx_ff <= 1'b0;
    end
    else begin
        hv_lv_owt_rx_ff <= hv_lv_owt_rx;
    end
end

assign dn_th = (symbol_cyc_cnt_lock<=2) ? CNT_OWT_EXT_CYC_W'(2) : (symbol_cyc_cnt_lock-2);
assign up_th = (symbol_cyc_cnt_lock<=2) ? CNT_OWT_EXT_CYC_W'(3) : (symbol_cyc_cnt_lock-1);

signal_detect #(
    .CNT_W(CNT_OWT_EXT_CYC_W    ),
    .DN_TH(OWT_EXT_CYC_NUM-2    ),
    .UP_TH(OWT_EXT_CYC_NUM-1    ),
    .MODE (1                    )
) U_OWT_RX_SIGNAL_DETECT(
    .i_vld        (1'b1          ),
    .i_vld_data   (hv_lv_owt_rx  ),
    .i_dn_th      (dn_th         ),
    .i_up_th      (up_th         ),
    .o_vld        (rx_vld        ),
    .o_vld_data   (rx_vld_data   ),
    .i_clk        (i_clk         ),
    .i_rst_n      (i_rst_n       )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_vld_lock       <= 1'b0;
        rx_vld_data_lock  <= 1'b0;
    end
    else begin
        rx_vld_lock       <= rx_vld ? 1'b1        : rx_vld_lock     ;
        rx_vld_data_lock  <= rx_vld ? rx_vld_data : rx_vld_data_lock;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_gen_mcst_code <= 1'b0;
    end
    else if((owt_rx_cur_st==OWT_CMD_ST) |
            (owt_rx_cur_st==OWT_ADC_DATA_ST) | (owt_rx_cur_st==OWT_NML_DATA_ST) | (owt_rx_cur_st==OWT_CRC_ST)) begin
        rx_gen_mcst_code <= rx_vld ? ~rx_gen_mcst_code : rx_gen_mcst_code;
    end
    else begin
        rx_gen_mcst_code <= 1'b0;
    end
end

assign rx_mcst_vld_one  = rx_vld & rx_vld_lock & ~rx_vld_data &  rx_vld_data_lock & rx_gen_mcst_code; //negedge 1->0
assign rx_mcst_vld_zero = rx_vld & rx_vld_lock &  rx_vld_data & ~rx_vld_data_lock & rx_gen_mcst_code; //posedge 0->1
assign rx_mcst_invld    = rx_vld & rx_vld_lock & ~(rx_vld_data ^ rx_vld_data_lock)& rx_gen_mcst_code;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_sync_tail_bit[OWT_TAIL_BIT_NUM-1: 0] <= {OWT_TAIL_BIT_NUM{1'b0}};
    end
    else if(rx_vld & ((owt_rx_cur_st==OWT_SYNC_TAIL_ST) | (owt_rx_cur_st==OWT_END_TAIL_ST))) begin
        rx_sync_tail_bit[OWT_TAIL_BIT_NUM-1: 0] <= {rx_sync_tail_bit[OWT_TAIL_BIT_NUM-2: 0], rx_vld_data}; 
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_cmd_data[OWT_CMD_BIT_NUM-1: 0] <= {OWT_CMD_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CMD_ST)) begin
        rx_cmd_data[OWT_CMD_BIT_NUM-1: 0] <= {rx_cmd_data[OWT_CMD_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_cmd_rd = ~rx_cmd_data[OWT_CMD_BIT_NUM-1];
assign rx_cmd_wr =  rx_cmd_data[OWT_CMD_BIT_NUM-1];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_adc_data[OWT_ADCD_BIT_NUM-1: 0] <= {OWT_ADCD_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & ((owt_rx_cur_st==OWT_ADC_DATA_ST) | (owt_rx_cur_st==OWT_NML_DATA_ST))) begin
        rx_adc_data[OWT_ADCD_BIT_NUM-1: 0] <= {rx_adc_data[OWT_ADCD_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_nml_data = rx_adc_data[OWT_DATA_BIT_NUM-1: 0];

assign crc8_chk_vld     = ((owt_rx_cur_st==OWT_CMD_ST) | (owt_rx_cur_st==OWT_ADC_DATA_ST) | (owt_rx_cur_st==OWT_NML_DATA_ST)) & (rx_mcst_vld_one | rx_mcst_vld_zero);
assign crc8_chk_bit     = (~rx_mcst_vld_zero | rx_mcst_vld_one);
assign crc8_chk_start   = (owt_rx_cur_st==OWT_CMD_ST) & (rx_cnt_bit==CNT_OWT_MAX_W'(0)) & (rx_mcst_vld_one | rx_mcst_vld_zero);

crc8_serial U_CRC8_CHK(
    .i_vld             (crc8_chk_vld        ),
    .i_data            (crc8_chk_bit        ),
    .i_new_calc        (crc8_chk_start      ),
    .o_vld_crc         (crc8_chk_o_crc      ),
    .i_clk             (i_clk               ),
    .i_rst_n           (i_rst_n             )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_crc_data[OWT_CRC_BIT_NUM-1: 0] <= {OWT_CRC_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CRC_ST)) begin
        rx_crc_data[OWT_CRC_BIT_NUM-1: 0] <= {rx_crc_data[OWT_CRC_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_bit_done <= 1'b0;
    end
    else if(rx_vld & (owt_rx_cur_st==OWT_SYNC_HEAD_ST) & (rx_cnt_bit==(OWT_SYNC_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if(rx_vld & (owt_rx_cur_st==OWT_SYNC_TAIL_ST) & (rx_cnt_bit==(OWT_TAIL_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CMD_ST) & (rx_cnt_bit==(OWT_CMD_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_ADC_DATA_ST) & (rx_cnt_bit==(OWT_ADCD_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_NML_DATA_ST) & (rx_cnt_bit==(OWT_DATA_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CRC_ST) & (rx_cnt_bit==(OWT_CRC_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if(rx_vld & (owt_rx_cur_st==OWT_END_TAIL_ST) & (rx_cnt_bit==(OWT_TAIL_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else begin
        rx_bit_done <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_cnt_bit <= CNT_OWT_MAX_W'(0);
    end
    else if(owt_rx_cur_st==OWT_SYNC_HEAD_ST) begin
        if(rx_pos | rx_bit_done) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_SYNC_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1);
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_SYNC_TAIL_ST) begin
        if(rx_vld) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1);
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_CMD_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_CMD_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_ADC_DATA_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_ADCD_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_NML_DATA_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_DATA_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_CRC_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_CRC_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==OWT_END_TAIL_ST) begin
        if(rx_vld) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (rx_cnt_bit+1'b1);
        end
        else;
    end
    else begin
        rx_cnt_bit <= CNT_OWT_MAX_W'(0);
    end
end

assign owt_rx_ack = (owt_rx_cur_st != OWT_IDLE_ST) & (owt_rx_nxt_st==OWT_IDLE_ST) & ~dly_rx_ack;
                    
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_rx_wdg_rsp <= 1'b0;
    end
    else begin
        o_owt_rx_wdg_rsp <= (owt_rx_ack & ~owt_rx_status) | dly_rx_ack;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_rx_ack <= 1'b0;
    end
    else begin
        o_owt_rx_ack <= (owt_rx_ack & ~owt_rx_status) | dly_rx_ack;
    end
end

assign owt_rx_status = (((owt_rx_cur_st != OWT_IDLE_ST) & (owt_rx_cur_st != OWT_END_TAIL_ST)) & (owt_rx_nxt_st==OWT_IDLE_ST)) |
                        (((rx_sync_tail_bit != 4'b1100) & (owt_rx_cur_st == OWT_END_TAIL_ST)) & (owt_rx_nxt_st==OWT_IDLE_ST)) |
                        (crc8_chk_o_crc != rx_crc_data) | (i_owt_tx_cmd_lock != rx_cmd_data);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_rx_status <= 1'b0;
    end
    else begin
        o_owt_rx_status <= dly_rx_ack ? 1'b1 : 1'b0;
    end
end

assign o_owt_rx_cmd  = rx_cmd_data;
assign o_owt_rx_data = rx_adc_data;


assign owt_com_err_add_sel = i_reg_comerr_config[3: 2];
assign owt_com_cor_sub_sel = i_reg_comerr_config[1: 0];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_com_err_cnt <= INIT_OWT_COM_ERR_NUM;
    end
    else if(owt_rx_ack & owt_rx_status) begin
        if((owt_com_err_cnt+OWT_COM_ERR_SET_NUM[owt_com_err_add_sel])>=OWT_COM_MAX_ERR_NUM) begin
            owt_com_err_cnt <= OWT_COM_MAX_ERR_NUM;
        end
        else begin
            owt_com_err_cnt <= (owt_com_err_cnt+OWT_COM_ERR_SET_NUM[owt_com_err_add_sel]);
        end
    end
    else if(owt_rx_ack & ~owt_rx_status) begin
        if(OWT_COM_COR_SUB_NUM[owt_com_cor_sub_sel]>=owt_com_err_cnt) begin
            owt_com_err_cnt <= OWT_COM_ERR_CNT_W'(0);
        end
        else begin
            owt_com_err_cnt <= (owt_com_err_cnt-OWT_COM_COR_SUB_NUM[owt_com_cor_sub_sel]);
        end
    end
    else;
end

assign owt_com_err = (~i_reg_comerr_mode & (owt_com_err_cnt>=OWT_COM_ERR_SET_NUM[owt_com_err_add_sel])) |
                     ( i_reg_comerr_mode & (owt_com_err_cnt==OWT_COM_ERR_CNT_W'(0)));

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_com_err <= 1'b1;
    end
    else if(owt_com_err) begin
        o_owt_com_err <= 1'b1;
    end
    else begin
        o_owt_com_err <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        dly_rx_ack_flag <= 1'b0;
    end
    else if(dly_rx_ack_cnt==(MAX_OWT_RX_CYC_NUM-1)) begin
        dly_rx_ack_flag <= 1'b0;
    end
    else if(owt_rx_ack & owt_rx_status) begin
        dly_rx_ack_flag <= 1'b1;        
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        dly_rx_ack_cnt <= DLY_RX_ACK_CNT_W'(0);
    end
    else if(dly_rx_ack_flag) begin
        dly_rx_ack_cnt <= (dly_rx_ack_cnt==(MAX_OWT_RX_CYC_NUM-1)) ? DLY_RX_ACK_CNT_W'(0) : (dly_rx_ack_cnt+1'b1);
    end
    else begin
        dly_rx_ack_cnt <= DLY_RX_ACK_CNT_W'(0);
    end
end


assign dly_rx_ack = (dly_rx_ack_cnt==(MAX_OWT_RX_CYC_NUM-1));


// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule











