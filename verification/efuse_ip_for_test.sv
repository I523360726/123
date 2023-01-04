//============================================================
//Module   : efuse_ip_for_test
//Function : efuse ip for test
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module efuse_ip_for_test #(
    parameter DATA_NUM             = 8 ,
    parameter DW                   = 8 ,
    parameter END_OF_LIST          = 1
)( 
   output logic                     o_efuse_op_finish   ,
   output logic                     o_efuse_reg_update  ,
   output logic [DATA_NUM*DW-1: 0]  o_efuse_reg_data    ,

   input  logic                     i_efuse_load_req    ,
   output logic                     o_efuse_load_done   ,

    input  logic                    i_clk               ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic efuse_load_req_ff ;
//==================================
//main code
//==================================
//scan reg
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        efuse_load_req_ff <= 1'b0;
    end
    else begin
        efuse_load_req_ff <= i_efuse_load_req;    
    end
end

assign o_efuse_load_done  = efuse_load_req_ff   ;
assign o_efuse_op_finish  = efuse_load_req_ff   ;
assign o_efuse_reg_update = efuse_load_req_ff   ;

generate
    for(genvar i=0; i<DATA_NUM; i=i+1) begin: GEN_EFUSE_REG_DATA_BLK
        if(i==(DATA_NUM-1)) begin: LST_DATA_BLK
            assign o_efuse_reg_data[i*DW +: DW] = 8'hFF;
        end
        else begin: NO_LST_DATA_BLK
            assign o_efuse_reg_data[i*DW +: DW] = 8'h00;            
        end
    end
endgenerate

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule







