module bf16_mac (
    input  [15:0] a, b, c,
    input         clk, rst,
    output reg [15:0] acc
);

    wire [15:0] mul_out;
    wire [15:0] add_out;
    wire [15:0] a1;
    wire [15:0] corrected_acc;

   
    bf16_mul mul_inst (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .out(mul_out)
    );

    
    bf16_add add_inst (
        .clk(clk),
        .rst(rst),
        .a(mul_out),
        .b(acc),
        .result(a1)
    );

    bf16_add add_bias (
        .clk(clk),
        .rst(rst),
        .a(a1),
        .b(c),
        .result(add_out)
    );
    bf16_special_case special_case_handler (
        .bf16_in(add_out),
        .bf16_out(corrected_acc)
    );
	
//	initial acc <= 0;
	
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            acc <= 16'b0;
        else
            acc <= corrected_acc;
    end

endmodule
