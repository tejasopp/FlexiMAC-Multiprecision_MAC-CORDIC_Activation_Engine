module mult4x4 (
    input  [3:0] a,   
    input  [3:0] b,   
    output [7:0] p    
);

    wire [3:0] pp0 = b[0] ? a : 4'b0000;
    wire [3:0] pp1 = b[1] ? a : 4'b0000;
    wire [3:0] pp2 = b[2] ? a : 4'b0000;
    wire [3:0] pp3 = b[3] ? a : 4'b0000;

    wire [7:0] sum1 = {4'b0000, pp0};
    wire [7:0] sum2 = {3'b000, pp1, 1'b0};
    wire [7:0] sum3 = {2'b00, pp2, 2'b00};
    wire [7:0] sum4 = {1'b0, pp3, 3'b000};

    assign p = sum1 + sum2 + sum3 + sum4;

endmodule


