`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2023 20:42:10
// Design Name: 
// Module Name: softmax_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module softmax_pipeline_bf_asic(input [8:-7]z,input clk,EN,output reg [8:-7]softmax_out);

reg [8:-7] inp[0:9];
reg EN0, EN1,EN2,EN3,EN4,EN5,EN6,EN7,EN8,EN9;
reg [3:0]cout;
always@(posedge clk) begin
    if(EN) cout<=4'd0;
    else if(cout<4'd10) cout<=cout+4'd1;
end


always@(posedge clk) begin
    case(cout)
    4'd0:begin 
    inp[0]<=z;
    EN0<=1'd1;
    end
    4'd1:begin
        EN0<=1'd0;
        EN1<=1'd1;
        inp[1]<=z;
    end
    4'd2:begin
        EN1<=1'd0;
        EN2<=1'd1;
        inp[2]<=z;
    end
    4'd3:begin
        EN2<=1'd0;
        EN3<=1'd1;
        inp[3]<=z;
    end   
    4'd4:begin
        EN3<=1'd0;
        EN4<=1'd1;
        inp[4]<=z;
    end
    4'd5:begin
        EN4<=1'd0;
        EN5<=1'd1;
        inp[5]<=z;
    end
    4'd6:begin
        EN5<=1'd0;
        EN6<=1'd1;
        inp[6]<=z;
    end   
    4'd7:begin
        EN6<=1'd0;
        EN7<=1'd1;
        inp[7]<=z;
    end
    4'd8:begin
        EN7<=1'd0;
        EN8<=1'd1;
        inp[8]<=z;
    end
    4'd9:begin
        EN8<=1'd0;
        EN9<=1'd1;
        inp[9]<=z;
    end   
    4'd10:begin
        EN9<=1'd0;
    end

    endcase
end
wire done[0:9];
wire [15:0] exp[0:9];

cordic_bfloat_hypb p1(.clk(clk),.EN(EN0),.z(inp[0]),.out(exp[0]),.done(done[0]));
cordic_bfloat_hypb p2(.clk(clk),.EN(EN1),.z(inp[1]),.out(exp[1]),.done(done[1]));
cordic_bfloat_hypb p3(.clk(clk),.EN(EN2),.z(inp[2]),.out(exp[2]),.done(done[2]));
cordic_bfloat_hypb p4(.clk(clk),.EN(EN3),.z(inp[3]),.out(exp[3]),.done(done[3]));
cordic_bfloat_hypb p5(.clk(clk),.EN(EN4),.z(inp[4]),.out(exp[4]),.done(done[4]));
cordic_bfloat_hypb p6(.clk(clk),.EN(EN5),.z(inp[5]),.out(exp[5]),.done(done[5]));
cordic_bfloat_hypb p7(.clk(clk),.EN(EN6),.z(inp[6]),.out(exp[6]),.done(done[6]));
cordic_bfloat_hypb p8(.clk(clk),.EN(EN7),.z(inp[7]),.out(exp[7]),.done(done[7]));
cordic_bfloat_hypb p9(.clk(clk),.EN(EN8),.z(inp[8]),.out(exp[8]),.done(done[8]));
cordic_bfloat_hypb p10(.clk(clk),.EN(EN9),.z(inp[9]),.out(exp[9]),.done(done[9]));

reg [15:0] exp_mem[0:9];


wire [15:0] exp_out,add_in,add_fb,add_out;
wire done_exp;

reg [15:0]buffer,buf_fb;
reg exp_done = 1'd0;

always @(posedge clk) begin
if(done[0])
begin
exp_mem[0]<=exp[0];
exp_mem[1]<=exp[1];
exp_mem[2]<=exp[2];
exp_mem[3]<=exp[3];
exp_mem[4]<=exp[4];
exp_mem[5]<=exp[5];
exp_mem[6]<=exp[6];
exp_mem[7]<=exp[7];
exp_mem[8]<=exp[8];
exp_mem[9]<=exp[9];
exp_done <= 1'd1;
end
end

reg [5:0]count;

always@(posedge clk)
begin
    if(EN)
    begin
    buffer <= 16'd0;
    buf_fb <= 16'd0;
    count<=6'd23;
    end
    
    if(exp_done && count<6'd33) begin
    
    buffer<=exp_mem[count-6'd23]; 
    buf_fb<= add_out;
    count<=count+5'd1;
   
    end
end
wire enable=(count==6'd33)?1'd0:1'd1;
reg lin_enable;
always@(posedge clk) begin
lin_enable<=enable;
end

assign add_in = buffer;
assign add_fb = buf_fb;

fp_adder exp_add(.mode(1'b1),.a(add_in),.b(add_fb),.out(add_out));

wire lin_done[0:9];
wire [8:-7]s1,s2,s3,s4,s5,s6,s7,s8,s9,s10;
cordic_bfloat_linear l1(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[0]),.done(lin_done[0]),.out(s1));
cordic_bfloat_linear l2(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[1]),.done(lin_done[1]),.out(s2));
cordic_bfloat_linear l3(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[2]),.done(lin_done[2]),.out(s3));
cordic_bfloat_linear l4(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[3]),.done(lin_done[3]),.out(s4));
cordic_bfloat_linear l5(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[4]),.done(lin_done[4]),.out(s5));

cordic_bfloat_linear l6(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[5]),.done(lin_done[5]),.out(s6));
cordic_bfloat_linear l7(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[6]),.done(lin_done[6]),.out(s7));
cordic_bfloat_linear l8(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[7]),.done(lin_done[7]),.out(s8));
cordic_bfloat_linear l9(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[8]),.done(lin_done[8]),.out(s9));
cordic_bfloat_linear l10(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[9]),.done(lin_done[9]),.out(s10));




reg [3:0]count1;
reg en;
always@(posedge clk) begin
    if(EN) en<=0;
    else en<=lin_done[0];
end
wire en1=lin_done[0]& ~en;

always@(posedge clk) begin
    if(en1) begin 
        count1<=4'd0;
    end
    else count1<=count1+4'd1;
end
always@(posedge clk) begin
    case(count1)
    4'd0:softmax_out=s1;
    4'd1:softmax_out=s2;
    4'd2:softmax_out=s3;
    4'd3:softmax_out=s4;
    4'd4:softmax_out=s5;
    4'd5:softmax_out=s6;
    4'd6:softmax_out=s7;
    4'd7:softmax_out=s8;
    4'd8:softmax_out=s9;
    4'd9:softmax_out=s10;
    endcase
end

endmodule





/*
module softmax_pipeline(input [8:-7]z,input clk,EN,output reg [8:-7]softmax_out);

reg [8:-7] inp[0:9];
reg EN1,EN2,EN3,EN4,EN5,EN6,EN7,EN8,EN9;
reg [3:0]cout;
always@(posedge clk) begin
    if(EN) cout<=4'd0;
    else if(cout<4'd10) cout<=cout+4'd1;
end


always@(posedge clk) begin
    case(cout)
    4'd0:begin 
    inp[0]<=z;
    end
    4'd1:begin
     
        EN1<=1'd1;
        inp[1]<=z;
    end
    4'd2:begin
        EN1<=1'd0;
        EN2<=1'd1;
        inp[2]<=z;
    end
    4'd3:begin
        EN2<=1'd0;
        EN3<=1'd1;
        inp[3]<=z;
    end   
    4'd4:begin
        EN3<=1'd0;
        EN4<=1'd1;
        inp[4]<=z;
    end
    4'd5:begin
        EN4<=1'd0;
        EN5<=1'd1;
        inp[5]<=z;
    end
    4'd6:begin
        EN5<=1'd0;
        EN6<=1'd1;
        inp[6]<=z;
    end   
    4'd7:begin
        EN6<=1'd0;
        EN7<=1'd1;
        inp[7]<=z;
    end
    4'd8:begin
        EN7<=1'd0;
        EN8<=1'd1;
        inp[8]<=z;
    end
    4'd9:begin
        EN8<=1'd0;
        EN9<=1'd1;
        inp[9]<=z;
    end   
    4'd10:begin
        EN9<=1'd0;
    end

    endcase
end
wire done[0:9];
wire [15:0] exp[0:9];

cordic_bfloat_hypb p1(.clk(clk),.EN(EN),.z(inp[0]),.out(exp[0]),.done(done[0]));
cordic_bfloat_hypb p2(.clk(clk),.EN(EN1),.z(inp[1]),.out(exp[1]),.done(done[1]));
cordic_bfloat_hypb p3(.clk(clk),.EN(EN2),.z(inp[2]),.out(exp[2]),.done(done[2]));
cordic_bfloat_hypb p4(.clk(clk),.EN(EN3),.z(inp[3]),.out(exp[3]),.done(done[3]));
cordic_bfloat_hypb p5(.clk(clk),.EN(EN4),.z(inp[4]),.out(exp[4]),.done(done[4]));
cordic_bfloat_hypb p6(.clk(clk),.EN(EN5),.z(inp[5]),.out(exp[5]),.done(done[5]));
cordic_bfloat_hypb p7(.clk(clk),.EN(EN6),.z(inp[6]),.out(exp[6]),.done(done[6]));
cordic_bfloat_hypb p8(.clk(clk),.EN(EN7),.z(inp[7]),.out(exp[7]),.done(done[7]));
cordic_bfloat_hypb p9(.clk(clk),.EN(EN8),.z(inp[8]),.out(exp[8]),.done(done[8]));
cordic_bfloat_hypb p10(.clk(clk),.EN(EN9),.z(inp[9]),.out(exp[9]),.done(done[9]));

reg [15:0] exp_mem[0:9];


wire [15:0] exp_out,add_in,add_fb,add_out;
wire done_exp;

reg [15:0]buffer,buf_fb;


always @(posedge clk) begin
exp_mem[0]<=exp[0];
exp_mem[1]<=exp[1];
exp_mem[2]<=exp[2];
exp_mem[3]<=exp[3];
exp_mem[4]<=exp[4];
exp_mem[5]<=exp[5];
exp_mem[6]<=exp[6];
exp_mem[7]<=exp[7];
exp_mem[8]<=exp[8];
exp_mem[9]<=exp[9];

end

reg [5:0]count;

always@(posedge clk)
begin
    if(EN)
    begin
    buffer <= 16'd0;
    buf_fb <= 16'd0;
    count<=6'd23;
    end
    
    if(done[0]&& count<6'd33) begin
    
    buffer<=exp_mem[count-6'd23]; 
    buf_fb<= add_out;
    count<=count+5'd1;
   
    end
end
wire enable=(count==6'd33)?1'd0:1'd1;
reg lin_enable;
always@(posedge clk) begin
lin_enable<=enable;
end

assign add_in = buffer;
assign add_fb = buf_fb;

fp_adder exp_add(.mode(1'b1),.a(add_in),.b(add_fb),.out(add_out));

wire lin_done[0:9];
wire [8:-7]s1,s2,s3,s4,s5,s6,s7,s8,s9,s10;
cordic_bfloat_linear l1(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[0]),.done(lin_done[0]),.out(s1));
cordic_bfloat_linear l2(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[1]),.done(lin_done[1]),.out(s2));
cordic_bfloat_linear l3(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[2]),.done(lin_done[2]),.out(s3));
cordic_bfloat_linear l4(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[3]),.done(lin_done[3]),.out(s4));
cordic_bfloat_linear l5(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[4]),.done(lin_done[4]),.out(s5));

cordic_bfloat_linear l6(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[5]),.done(lin_done[5]),.out(s6));
cordic_bfloat_linear l7(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[6]),.done(lin_done[6]),.out(s7));
cordic_bfloat_linear l8(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[7]),.done(lin_done[7]),.out(s8));
cordic_bfloat_linear l9(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[8]),.done(lin_done[8]),.out(s9));
cordic_bfloat_linear l10(.clk(clk),.EN(lin_enable),.x(add_out),.y(exp_mem[9]),.done(lin_done[9]),.out(s10));




reg [3:0]count1;
reg en;
always@(posedge clk) begin
    if(EN) 
    begin
        en<=0;
        count1<=4'd0;
    end
    else
    begin 
        en<=lin_done[0];
//        if(lin_done[0])
//            count1 <= 4'd0;
//        else if (lin_done[1])
//            count1 <= 4'd1;
//        else if (lin_done[2])
//            count1 <= 4'd2;
//        else if (lin_done[3])
//            count1 <= 4'd3;
//        else if (lin_done[4])
//            count1 <= 4'd4;
//        else if (lin_done[5])
//            count1 <= 4'd5;
//        else if (lin_done[6])
//            count1 <= 4'd6;
//        else if (lin_done[7])
//            count1 <= 4'd7;
//        else if (lin_done[8])
//            count1 <= 4'd8;
//        else if (lin_done[9])
//            count1 <= 4'd9;
    end
end
wire en1=lin_done[0]& ~en;


always@(posedge clk) begin
    if(en) begin 
        count1<=4'd0;
    end
    else count1<=count1+4'd1;
end


always@(posedge clk) begin
    case(count1)
    4'd0:
    begin
    softmax_out<=s1;
    en <= 0;
    end
    4'd1:softmax_out=s2;
    4'd2:softmax_out=s3;
    4'd3:softmax_out=s4;
    4'd4:softmax_out=s5;
    4'd5:softmax_out=s6;
    4'd6:softmax_out=s7;
    4'd7:softmax_out=s8;
    4'd8:softmax_out=s9;
    4'd9:softmax_out=s10;
    endcase
end

endmodule

*/






module atanh_LOOKUP_hypb(index, value);
    localparam EXP_SIZE = 8;
    localparam SIGN_SIZE = 1;
    localparam MANTISSA_SIZE = 7;

    input wire signed [7:0] index;
    output reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] value;

    always @(index)
    begin
        case (index)
            -5: value = 16'h4031;  //  atanh(1-2^(-7))=h02_c5481e
            -4: value = 16'h401b;  //  atanh(1-2^(-6))=h02_6c0b28
            -3: value = 16'h4004;  //  atanh(1-2^(-5))
            -2: value = 16'h3fdb;  //  atanh(1-2^(-4))
            -1: value = 16'h3fad;  //  atanh(1-2^(-3))
            0:  value = 16'h3f79;  //  atanh(1-2^(-2))
            1:  value = 16'h3f0c;  //  atanh(2^(-1))
            2:  value = 16'h3e82;  //  atanh(2^(-2))
            3:  value = 16'h3e00;  //  atanh(2^(-3))
            4:  value = 16'h3d80;  //  atanh(2^(-4))
            5:  value = 16'h3d00;  //  atanh(2^(-5))
            6:  value = 16'h3c80;  //  atanh(2^(-6))
            7:  value = 16'h3c00;  //  atanh(2^(-7))
            8:  value = 16'h3b80;  //  atanh(2^(-8))
            9:  value = 16'h3b00;  //  atanh(2^(-9))
            10: value = 16'h3a80;  //  atanh(2^(-10))
            11: value = 16'h39ff;  //  atanh(2^(-11))
            12: value = 16'h3980;  //  atanh(2^(-12))
            13: value = 16'h3900;  //  atanh(2^(-13))
            default: 
                value = 16'h00_00;
        endcase
    end
endmodule




module cordic_bfloat_hypb(
        input clk,
        input EN,
        input [8:-7] z,
        output [15:0] out,
        output done
);

    parameter EXP_SIZE = 8;
    parameter SIGN_SIZE = 1; 
    parameter MANTISSA_SIZE = 7;
    parameter SIGN_BIT = 9;                          // 8 | 7 6 5 4 3 2 1 0 | -1 -2 -3 -4 -5 -6 -7
                                                     // S |   EXPONENT BIT  |        MANTISSA

    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] x_;
    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] y_;
    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] z_;
    reg signed [7:0] i;
    wire signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] Z_UPDATE;
    // wire signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] shifted_out;
    reg IS_FIRST4;
    reg IS_FIRST13;
    wire [8:-7] mid_out;
    wire [15:0] x_shift_out,y_shift_out,x_out,y_out,z_out,x_neg_out,x_pos_out,y_pos_out,y_neg_out;

    atanh_LOOKUP_hypb LOOKUP(
        .index(i),
        .value(Z_UPDATE));

    fp_adder z1 (.mode(z_[SIGN_BIT-1]),.a(z_),.b(Z_UPDATE),.out(z_out));
    // rshift r11 (.a(x_),.shift_size(i),.pos_out(x_pos_out),.neg_out(x_neg_out));
    // rshift r12 (.a(y_),.shift_size(i),.pos_out(y_pos_out),.neg_out(y_neg_out));

    // assign x_shift_out = (i < 1) ? x_neg_out : x_pos_out;
    // assign y_shift_out = (i < 1) ? y_neg_out : y_pos_out;

    rshift r11 (.a(x_),.shift_size(i),.out(x_shift_out));
    rshift r12 (.a(y_),.shift_size(i),.out(y_shift_out));

    fp_adder x1 (.mode(~z_[SIGN_BIT-1]),.a(x_),.b(y_shift_out),.out(x_out));
    fp_adder y1 (.mode(~z_[SIGN_BIT-1]),.a(y_),.b(x_shift_out),.out(y_out));

    fp_adder o (.mode(1'b1),.a(x_out),.b(y_out),.out(mid_out));

    assign out = {mid_out[SIGN_BIT-1],(mid_out[EXP_SIZE-1:0] + 8'd11),mid_out[-1:-MANTISSA_SIZE]};

    assign done = (i==14) ? 1'd1 : 1'd0;

    always @(posedge clk)
    begin
        if (EN) //  Like Reset
        begin
            x_ <= 16'h3f80;
            y_ <= 16'h00_00;
            // z_ <= {4'h0,z,20'h00000};      // modify for decimal change
            z_ <= z;
            i <= -5;
            IS_FIRST4 <= 1'b1;
            IS_FIRST13 <= 1'b1;
        end
        else
        begin
            if(i<14)
            begin
                i <= i+1;
                x_ <= x_out;
                y_ <= y_out;
                z_ <= z_out;
            end
        end
    end
        
endmodule

module rshift(
    input [8:-7] a,
    input signed [7:0] shift_size,
    // output [15:0] pos_out,
    // output [15:0] neg_out
    output [15:0] out
);
parameter EXP_SIZE = 8;
parameter SIGN_BIT = 9; 
parameter MANTISSA_SIZE = 7;

wire [15:0] pos_out;
wire [15:0] neg_out;

assign pos_out = (a==16'd0) ? 16'd0 : ((shift_size < 1) ? {a[SIGN_BIT-1],(a[EXP_SIZE-1:0] + shift_size - 8'd2),a[-1:-MANTISSA_SIZE]} : {a[SIGN_BIT-1],a[EXP_SIZE-1:0] - shift_size,a[-1:-MANTISSA_SIZE]});

fp_adder z1 (.mode(1'b0),.a(a),.b(pos_out),.out(neg_out));

assign out = (a==16'd0) ? 16'd0 : ((shift_size < 1) ? neg_out : pos_out);

endmodule




module fp_adder(
    a,
    b,
    out,
    mode
);
parameter EXP_SIZE = 8;
parameter SIGN_SIZE = 1; 
parameter MANTISSA_SIZE = 7;
parameter SIGN_BIT = 9;                             
integer i;
input [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] a;
input [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] b;

input mode;
output [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] out;

wire a_sign,b_sign,b_sign1,borrow,carry;
wire [MANTISSA_SIZE-1:0] a_mantissa,b_mantissa,m1_out,m2_out,out_mantissa;
wire [EXP_SIZE-1:0] a_exp,b_exp,sub_exp_out,m3_out,out_exp;
wire [MANTISSA_SIZE:0] p1_out,r1_out,p2_out,r2_out,a1_out;
wire outSignBit,condition;


assign {a_sign,a_exp,a_mantissa} = a;
assign {b_sign1,b_exp,b_mantissa} = b;
assign b_sign = mode ? b_sign1 : (~b_sign1); 

assign condition= (a_sign == b_sign) ? 1:0;
//assign b_sign = mode ? b_sign1 : (~b_sign1); 




sub #(.INPUT_SIZE(8)) s1 (a_exp,b_exp,sub_exp_out,borrow);


mux_2_1 #(.INPUT_SIZE(7)) m1 (b_mantissa,a_mantissa,borrow,m1_out);
mux_2_1 #(.INPUT_SIZE(7)) m2 (a_mantissa,b_mantissa,borrow,m2_out);

prepend #(.INPUT_SIZE(7)) p1 (m1_out,p1_out);
right_shift  #(.INPUT_SIZE(8),.SHIFT_SIZE(EXP_SIZE)) r1 (p1_out,sub_exp_out,r1_out,1'b1);
prepend #(.INPUT_SIZE(7)) p2 (m2_out,p2_out);

wire [7:0] sub_man_out;
wire man_borrow;
sub #(.INPUT_SIZE(8)) s2 (r1_out,p2_out,sub_man_out,man_borrow);
wire [7:0]man3_out,man4_out;
mux_2_1 #(.INPUT_SIZE(8)) m5 (r1_out,p2_out,man_borrow,man3_out);
mux_2_1 #(.INPUT_SIZE(8)) m4 (p2_out,r1_out,man_borrow,man4_out);

mux_2_1 #(.INPUT_SIZE(EXP_SIZE)) m3 (a_exp,b_exp,borrow,m3_out);

adder_sub_8_bit a1 (.a(man3_out),.b(man4_out),.out(a1_out),.condition(condition),.exp(m3_out),.exp_out(out_exp));

//exp_shifter e1(m3_out,carry,out_exp,condition);
//right_shift #(.INPUT_SIZE(8),.SHIFT_SIZE(1)) r2 (a1_out,carry,r2_out,condition);

assign out_mantissa = a1_out[MANTISSA_SIZE-1:0];


assign outSignBit = ((a_exp>b_exp)||((a_exp==b_exp)&&(a_mantissa>=b_mantissa))) ? a_sign : b_sign;
assign out = {outSignBit,out_exp,out_mantissa};

endmodule

module mux_2_1 #(parameter INPUT_SIZE = 8)(
    i1,
    i2,
    select,
    out
);
input [INPUT_SIZE-1: 0] i1;
input [INPUT_SIZE-1: 0] i2;
input select;
output [INPUT_SIZE-1: 0] out;

assign out = select ? i2 : i1;

endmodule

module sub #(parameter INPUT_SIZE = 7)(
    a,
    b,
    out,
    borrow
);
input [INPUT_SIZE-1: 0] a;
input [INPUT_SIZE-1: 0] b;
output [INPUT_SIZE-1: 0] out;
output borrow;

wire [INPUT_SIZE-1: 0]par_out;

assign par_out = a-b;
assign borrow = par_out[INPUT_SIZE-1];
assign out = borrow ? -par_out : par_out;

endmodule

module adder_sub_8_bit(
    a,
    b,
    out,
    condition,
    exp,
    exp_out
);
input [7:0] a;
input [7:0] b,exp;
input condition;
output reg [7:0] out;
output reg [7:0]exp_out;
 reg carry;
 integer i;

always @(*) begin
    if(condition==1'd1) {carry,out}=a+b;
    else 
    if (a>b) begin
    {carry,out}=a-b;
    end
    else 
    {carry,out}=b-a;
    
     exp_out=exp;

    if(condition==1'd1) begin
        out=out>>carry;
        exp_out=exp_out+carry;
    end
    else begin
      for(i=0;i<8&&out[7]!=1'b1;i=i+1)
       //while(out[7]!=1'b1)
        begin
           // if(out[7]!=1'b1)
            out=out<<1'b1;
            exp_out=exp_out-1'b1;
        end
    end
end




endmodule

 module right_shift #(parameter INPUT_SIZE = 8,parameter SHIFT_SIZE = 1)(
     in,
     shift_amount,
     out,
     condition
 );
 input [INPUT_SIZE-1:0] in;
 input [SHIFT_SIZE-1:0] shift_amount;
 output [INPUT_SIZE-1:0] out;
 input condition;
 assign out =condition? in >>> shift_amount : in << shift_amount;

 endmodule

module prepend #(parameter INPUT_SIZE = 7)(
    in,
    out
);
input [INPUT_SIZE-1:0] in;
output [INPUT_SIZE:0] out;

assign out = {1'b1,in};

endmodule

/*
module exp_shifter(
    in,
    c_add,
    out,condition
);
input [7:0] in;
input c_add;
output [7:0] out;
input condition;
assign out = condition ? in + c_add :in;

endmodule
*/

module atanh_LOOKUP_linear(index, value);
    localparam EXP_SIZE = 8;
    localparam SIGN_SIZE = 1;
    localparam MANTISSA_SIZE = 7;

    input wire signed [7:0] index;
    output reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] value;

    always @(index)
    begin
        case (index)
            -5: value = 16'h3f7e;  //  atanh(1-2^(-7))=h02_c5481e
            -4: value = 16'h3f7c;  //  atanh(1-2^(-6))=h02_6c0b28
            -3: value = 16'h3f78;  //  atanh(1-2^(-5))
            -2: value = 16'h3f70;  //  atanh(1-2^(-4))
            -1: value = 16'h3f60;  //  atanh(1-2^(-3))
            0:  value = 16'h3f40;  //  atanh(1-2^(-2))
            1:  value = 16'h3f00;  //  atanh(2^(-1))
            2:  value = 16'h3e80;  //  atanh(2^(-2))
            3:  value = 16'h3e00;  //  atanh(2^(-3))
            4:  value = 16'h3d80;  //  atanh(2^(-4))
            5:  value = 16'h3d00;  //  atanh(2^(-5))
            6:  value = 16'h3c80;  //  atanh(2^(-6))
            7:  value = 16'h3c00;  //  atanh(2^(-7))
            8:  value = 16'h3b80;  //  atanh(2^(-8))
            9:  value = 16'h3b00;  //  atanh(2^(-9))
            10: value = 16'h3a80;  //  atanh(2^(-10))
            11: value = 16'h3a00;  //  atanh(2^(-11))
            12: value = 16'h3980;  //  atanh(2^(-12))
            13: value = 16'h3900;  //  atanh(2^(-13))
            default: 
                value = 16'h00_00;
        endcase
    end
endmodule


module cordic_bfloat_linear(
        input clk,
        input EN,
        input [8:-7] x,
        input [8:-7] y,
        output done,
        output [15:0] out
);

    parameter EXP_SIZE = 8;
    parameter SIGN_SIZE = 1; 
    parameter MANTISSA_SIZE = 7;
    parameter SIGN_BIT = 9;                          // 8 | 7 6 5 4 3 2 1 0 | -1 -2 -3 -4 -5 -6 -7
                                                     // S |   EXPONENT BIT  |        MANTISSA

    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] x_;
    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] y_;
    reg signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] z_;
    reg signed [7:0] i;
    wire signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] Z_UPDATE;
    // wire signed [SIGN_SIZE + EXP_SIZE-1:-MANTISSA_SIZE] shifted_out;
    reg IS_FIRST4;
    reg IS_FIRST13;
    wire [8:-7] mid_out;
    wire [15:0] x_shift_out,y_shift_out,x_out,y_out,x_neg_out,x_pos_out,y_pos_out,y_neg_out;
    wire [8:-7]z_out;

    atanh_LOOKUP_linear LOOKUP(
        .index(i),
        .value(Z_UPDATE));

    fp_adder z1 (.mode(~y_[SIGN_BIT-1]),.a(z_),.b(Z_UPDATE),.out(z_out));
    // rshift r11 (.a(x_),.shift_size(i),.pos_out(x_pos_out),.neg_out(x_neg_out));
    // rshift r12 (.a(y_),.shift_size(i),.pos_out(y_pos_out),.neg_out(y_neg_out));

    // assign x_shift_out = (i < 1) ? x_neg_out : x_pos_out;
    // assign y_shift_out = (i < 1) ? y_neg_out : y_pos_out;

    rshift r11 (.a(x_),.shift_size(i),.out(x_shift_out));
    //rshift r12 (.a(y_),.shift_size(i),.out(y_shift_out));

    //fp_adder x1 (.mode(~z_[SIGN_BIT-1]),.a(x_),.b(y_shift_out),.out(x_out));
    fp_adder y1 (.mode(y_[SIGN_BIT-1]),.a(y_),.b(x_shift_out),.out(y_out));

    // fp_adder o (.mode(1'b1),.a(x_out),.b(y_out),.out(mid_out));

    assign out = {z_out[SIGN_BIT-1],(z_out[EXP_SIZE-1:0]),z_out[-1:-MANTISSA_SIZE]};
    
    assign done = (i==14)&&(!EN) ? 1'd1 : 1'd0;
    
    // wire lin_enable=(done)? 1'd1:1'd0;
    always @(posedge clk)
    begin
        if (EN) //  Like Reset
        begin
            x_ <= x;
            y_ <= y;
            // z_ <= {4'h0,z,20'h00000};      // modify for decimal change
            z_ <= 16'h00_00;
            i <= -5;
            IS_FIRST4 <= 1'b1;
            IS_FIRST13 <= 1'b1;
            // done <= 1'd0;
        end
        else
        begin
            if(i<14)
            begin
                i <= i+1;
                x_ <= x_;
                y_ <= y_out;
                z_ <= z_out;
            end
            // if(i==14)
            // done <= 1'd1;
        end
    end
endmodule


