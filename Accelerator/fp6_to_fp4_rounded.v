module fp6_to_fp4_rounded (
    input  [5:0] fp6_in,
    output reg [3:0] fp4_out
);

    wire sign     = fp6_in[5];
    wire [1:0] exp_in = fp6_in[4:3];
    wire [2:0] man_in = fp6_in[2:0];

    wire man_top      = man_in[2];  // most significant mantissa bit to retain
    wire round_bit    = man_in[1];  // next bit used for rounding

    // Attempt rounding
    wire [1:0] rounded_man = {1'b0, man_top} + round_bit;

    // Check for mantissa overflow (if 2'b10 => overflow)
    wire mantissa_overflow = rounded_man[1];

    always @(*) begin
        if (exp_in == 2'b11) begin
            // Reserved/Inf/NaN case
            fp4_out = {sign, 2'b11, 1'b0};  // force Inf
        end else begin
            if (mantissa_overflow) begin
                // Mantissa overflowed, increment exponent
                if (exp_in == 2'b10)
                    fp4_out = {sign, 2'b11, 1'b0};  // Clamp to Inf
                else
                    fp4_out = {sign, exp_in + 1'b1, 1'b0};
            end else begin
                // Normal case with rounded mantissa
                fp4_out = {sign, exp_in, rounded_man[0]};
            end
        end
    end

endmodule


