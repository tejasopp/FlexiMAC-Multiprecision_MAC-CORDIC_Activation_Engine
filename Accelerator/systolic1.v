module systolic1 (
	input clk, rst,
	input sel, stop_proc,
    // Integer inputs corresponding to the weights
    input [8*1024-1:0] in_r,
//    input [8*784-1:0] in_g, 
//    input [8*784-1:0] in_b,
    input [7:0] w_r,
    output [8*1024-1:0] p
);

    
//    reg [31:0] im;            
//    always @(posedge clk) 
//    begin
//        if(start)
//            im <= 0; 
//        else
//            im <= image;
//    end	    

    // Instantiating the MAC units
    wire clk_f = (~ stop_proc) & clk;
genvar i;
generate
    for (i = 0; i < 1024; i = i + 1) begin : mac_array
        simd_pipelined_mac mac_inst ( 
        .a(in_r[8*i +: 8]),     // 8-bit slice of input
        .b(w_r), 
        .sel(sel), 
        .clk(clk_f), 
        .rst(rst), 
        .out(p[8*i +: 8])
              
        );
    end
endgenerate


endmodule // systolic1
