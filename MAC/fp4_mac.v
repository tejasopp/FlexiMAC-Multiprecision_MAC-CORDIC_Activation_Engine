module fp4_mac (
	input [3:0] a0, a1, a2, a3, b0, b1, b2, b3, c0, c1, c2, c3,
	input clk, rst,
	output reg [3:0] facc0, facc1, facc2, facc3
	);
	reg [5:0] acc0, acc1, acc2, acc3;
	wire [5:0] m0, m1, m2, m3, c00, c11, c22, c33;
	wire  [5:0] corr_acc0, corr_acc1, corr_acc2, corr_acc3;
	wire [5:0] out0, out1, out2, out3, o0, o1, o2, o3;
	wire [3:0] fout0, fout1, fout2, fout3;
	assign c00 = {2'd0,c0};
	assign c11 = {2'd0,c1};
	assign c22 = {2'd0,c2};
	assign c33 = {2'd0,c3};
	
	fp4_mul mul0 (.a(a0), .b(b0), .clk(clk), .rst(rst), .out(m0));
	fp4_mul mul1 (.a(a1), .b(b1), .clk(clk), .rst(rst), .out(m1));
	fp4_mul mul2 (.a(a2), .b(b2), .clk(clk), .rst(rst), .out(m2));
	fp4_mul mul3 (.a(a3), .b(b3), .clk(clk), .rst(rst), .out(m3));
	fp4_add add0 (.clk(clk), .rst(rst), .a(m0), .b(acc0), .result(o0));
	fp4_add add0_f (.clk(clk), .rst(rst), .a(o0), .b(c00), .result(out0));
	fp4_special_case s0(.fp6_in(out0), .fp6_out(corr_acc0));
	fp6_to_fp4_rounded uu0(.fp6_in(corr_acc0),.fp4_out(fout0));
	fp4_add add1 (.clk(clk), .rst(rst), .a(m1), .b(acc1), .result(o1));
	fp4_add add1_f (.clk(clk), .rst(rst), .a(o1), .b(c11), .result(out1));
	fp4_special_case s1 (.fp6_in(out1), .fp6_out(corr_acc1));
	fp6_to_fp4_rounded uu1(.fp6_in(corr_acc1),.fp4_out(fout1));
	fp4_add add2 (.clk(clk), .rst(rst), .a(m2), .b(acc2), .result(o2));
	fp4_add add2_f (.clk(clk), .rst(rst), .a(o2), .b(c22), .result(out2));
	fp4_special_case s2 (.fp6_in(out2), .fp6_out(corr_acc2));
	fp6_to_fp4_rounded uu2(.fp6_in(corr_acc2),.fp4_out(fout2));
	fp4_add add3 (.clk(clk), .rst(rst), .a(m3), .b(acc3), .result(o3));
	fp4_add add3_f (.clk(clk), .rst(rst), .a(o3), .b(c33), .result(out3));
	fp4_special_case s3 (.fp6_in(out3), .fp6_out(corr_acc3));
	fp6_to_fp4_rounded uu3(.fp6_in(corr_acc3),.fp4_out(fout3));
	
//	initial 
//		begin
//			acc0 <= 0;
//			acc1 <= 0;
//			acc2 <= 0;
//			acc3 <= 0;
//		end
		
	always @ (posedge clk or posedge rst) begin
		if(rst)
			begin
				acc0 <= 0;
				acc1 <= 0;
				acc2 <= 0;
				acc3 <= 0;
				facc0 <= 0;
				facc1 <= 0;
				facc2 <= 0;
				facc3 <= 0;
			end
		else
			begin
				acc0 <= corr_acc0;
				acc1 <= corr_acc1;
				acc2 <= corr_acc2;
				acc3 <= corr_acc3;
				facc0 <= fout0;
				facc1 <= fout1;
				facc2 <= fout2;
				facc3 <= fout3;
			end
		end
	endmodule
				
