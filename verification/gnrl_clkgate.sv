//============================================================
//Module   : gnrl_clkgate
//Function : general clkgate.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module gnrl_clkgate #(
    parameter END_OF_LIST          = 1
)( 
    input  logic                i_clk       ,
    input  logic                i_test_mode ,
    input  logic                i_clk_en    ,
    output logic                o_clk 
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic enb;
//==================================
//main code
//==================================
always @(*) begin
    if(~i_clk) begin
        enb = (i_clk_en | i_test_mode);
    end
end

assign o_clk = enb & i_clk;

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
