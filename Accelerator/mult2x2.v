module mult2x2 (
    input  [1:0] a,    
    input  [1:0] b,    
    output [3:0] p     
);

    
    wire [1:0] pp0 = b[0] ? a : 2'b00;   
    wire [1:0] pp1 = b[1] ? a : 2'b00;  

    
    wire [3:0] sum1 = {2'b00, pp0};     
    wire [3:0] sum2 = {1'b0, pp1, 1'b0};

   
    assign p = sum1 + sum2;

endmodule


