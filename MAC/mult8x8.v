module mult8x8 (
    input  [7:0] a,   
    input  [7:0] b,   
    output [15:0] p   
);

    wire [7:0] pp0 = b[0] ? a : 8'b00000000;
    wire [7:0] pp1 = b[1] ? a : 8'b00000000;
    wire [7:0] pp2 = b[2] ? a : 8'b00000000;
    wire [7:0] pp3 = b[3] ? a : 8'b00000000;
    wire [7:0] pp4 = b[4] ? a : 8'b00000000;
    wire [7:0] pp5 = b[5] ? a : 8'b00000000;
    wire [7:0] pp6 = b[6] ? a : 8'b00000000;
    wire [7:0] pp7 = b[7] ? a : 8'b00000000;

    wire [15:0] sum0 = {8'b00000000, pp0};
    wire [15:0] sum1 = {7'b0000000, pp1, 1'b0};
    wire [15:0] sum2 = {6'b000000, pp2, 2'b00};
    wire [15:0] sum3 = {5'b00000,  pp3, 3'b000};
    wire [15:0] sum4 = {4'b0000,   pp4, 4'b0000};
    wire [15:0] sum5 = {3'b000,    pp5, 5'b00000};
    wire [15:0] sum6 = {2'b00,     pp6, 6'b000000};
    wire [15:0] sum7 = {1'b0,      pp7, 7'b0000000};

    assign p = sum0 + sum1 + sum2 + sum3 +
               sum4 + sum5 + sum6 + sum7;

endmodule

