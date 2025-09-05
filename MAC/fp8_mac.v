module fp8_mac (
	input [7:0] a0, a1, b0, b1, c0, c1,
	input clk, rst,
	output reg [7:0] facc0, facc1
	);
	reg [11:0] acc0, acc1;
	wire [11:0] c00;
	wire [11:0] c11;
	wire [11:0] m0, m1;
	wire [11:0] corr_acc0, corr_acc1;
	wire [11:0] a0_b0_out, a1_b1_out, o0, o1;
	wire [7:0] fp_out0, fp_out1;
	assign c00 = {4'd0,c0};
	assign c11 = {4'd0,c1};
	
	fp8_mul mul0 (.a(a0), .b(b0), .clk(clk), .rst(rst), .out(m0));
	fp8_mul mul1 (.a(a1), .b(b1), .clk(clk), .rst(rst), .out(m1));
	fp8_add add1 (.clk(clk), .rst(rst), .a(m0), .b(acc0), .result(o0));
	fp8_add add1_f (.clk(clk), .rst(rst), .a(o0), .b(c00), .result(a0_b0_out));
	fp8_special_case s1 (.fp12_in(a0_b0_out), .fp12_out(corr_acc0));
	fp12_to_fp8_rounded zz0 (.fp12_in(corr_acc0), .fp8_out(fp_out0));
	fp8_add add2 (.clk(clk), .rst(rst), .a(m1), .b(acc1), .result(o1));
	fp8_add add2_f (.clk(clk), .rst(rst), .a(o1), .b(c11), .result(a1_b1_out));
	fp8_special_case s2 (.fp12_in(a1_b1_out), .fp12_out(corr_acc1));
	fp12_to_fp8_rounded zz1 (.fp12_in(corr_acc1), .fp8_out(fp_out1));
	
//	initial
//	begin
//		acc0 <= 0;
//		acc1 <= 0;
//	end
	
	always @ (posedge clk or posedge rst)
		begin
		if(rst)
			begin
			acc0 <= 0;
			acc1 <= 0;
			facc0 <= 0;
			facc1 <= 0;
			end
		else
			begin
			acc0 <= corr_acc0;
			acc1 <= corr_acc1;
			facc0 <= fp_out0;
			facc1 <= fp_out1;
			end
		end
	endmodule
		
