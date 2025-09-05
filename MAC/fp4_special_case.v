module fp4_special_case (
    input  [5:0] fp6_in,
    output [5:0] fp6_out
);

    wire sign     = fp6_in[5];
    wire [1:0] exp = fp6_in[4:3];
    wire [2:0] man = fp6_in[2:0];

    // Special case checks
    wire is_zero      = (exp == 2'b00) && (man == 3'b000);
    wire is_subnormal = (exp == 2'b00) && (man != 3'b000);
    wire is_inf       = (exp == 2'b11) && (man == 3'b000);
    wire is_nan       = (exp == 2'b11) && (man != 3'b000);

    // Constants
    wire [5:0] max_normal = {sign, 2'b10, 3'b111};  
    wire [5:0] zero_val   = 6'b000000;

    assign fp6_out = is_nan       ? zero_val :
                     is_inf       ? max_normal :
                     is_zero      ? zero_val :
                     is_subnormal ? zero_val :
                     fp6_in;  // valid number so pasing same as output

endmodule

