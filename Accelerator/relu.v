module relu (
    input [8*1024-1:0] in,
    output reg [8*1024-1:0] p,
    input clk,
    input flag
);

   
    integer k;
    always @(*)
    begin
       if (!flag) p = in;
       else begin
       for (k = 0; k < 1024; k = k + 1) begin
                                p[8*k +: 8] = (in[8*k +: 8] >= 0) ? in[8*k +: 8] : 0;  
                                end
    end
    end
endmodule 
