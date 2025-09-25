module fp12_to_fp8_rounded (
    input  [11:0] fp12_in,
    output reg [7:0]  fp8_out
);

    wire sign = fp12_in[11];
    wire [3:0] exp_in = fp12_in[10:7];
    wire [6:0] man_in = fp12_in[6:0];

    wire [2:0] man_top = man_in[6:4];  // top 3 bits (to be retained)
    wire       round_bit = man_in[3];  // bit that decides rounding

    // Temporary mantissa after rounding
    wire [3:0] rounded_man = {1'b0, man_top} + round_bit;

    // Check for mantissa overflow after rounding
    wire mantissa_overflow = rounded_man[3];  // if 1, mantissa became 4 bits

    always @(*) begin
        if (exp_in == 4'd15) begin
            // Handle Inf or NaN (don't round these)
            fp8_out = {sign, 4'd15, 3'd0};
        end else begin
            if (mantissa_overflow) begin
                // Mantissa overflowed, increment exponent and reset mantissa to 000
                if (exp_in == 4'd14)
                    fp8_out = {sign, 4'd15, 3'd0}; // Clamp to Inf
                else
                    fp8_out = {sign, exp_in + 1, 3'd0};
            end else begin
                // Normal case
                fp8_out = {sign, exp_in, rounded_man[2:0]};
            end
        end
    end

endmodule


