`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2023 21:43:45
// Design Name: 
// Module Name: sigmoid
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
        output reg signed [8:-7] out,
        output done
);

    parameter EXP_SIZE = 8;
    parameter SIGN_SIZE = 1; 
    parameter MANTISSA_SIZE = 7;
    parameter SIGN_BIT = 9;                          // 8 | 7 6 5 4 3 2 1 0 | -1 -2 -3 -4 -5 -6 -7
                                                     // S |   EXPONENT BIT  |        MANTISSA
//    reg signed out;
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
    wire [15:0] out_mid;
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

    assign out_mid = {mid_out[SIGN_BIT-1],(mid_out[EXP_SIZE-1:0] + 8'd11),mid_out[-1:-MANTISSA_SIZE]};

    assign done = (i==14)? 1'd1 : 1'd0;

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
            out <= 16'd0;
        end
        else
        begin
            out <= out_mid;
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

// module rshift(
//     input [8:-7] a,
//     input signed [7:0] shift_size,
//     // output [15:0] pos_out,
//     // output [15:0] neg_out
//     output [15:0] out
// );
// parameter EXP_SIZE = 8;
// parameter SIGN_BIT = 9; 
// parameter MANTISSA_SIZE = 7;

// wire [15:0] pos_out;
// wire [15:0] neg_out;

// assign pos_out = (a==16'd0) ? 16'd0 : ((shift_size < 1) ? {a[SIGN_BIT-1],(a[EXP_SIZE-1:0] + shift_size - 8'd2),a[-1:-MANTISSA_SIZE]} : {a[SIGN_BIT-1],a[EXP_SIZE-1:0] - shift_size,a[-1:-MANTISSA_SIZE]});

// fp_adder z1 (.mode(1'b0),.a(a),.b(pos_out),.out(neg_out));

// assign out = (a==16'd0) ? 16'd0 : ((shift_size < 1) ? neg_out : pos_out);

// endmodule




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

always @(a,b) begin
    if(condition) {carry,out}=a+b;
    else 
    if (a>b) begin
    {carry,out}=a-b;
    end
    else 
    {carry,out}=b-a;
    
     exp_out=exp;

    if(condition) begin
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

//module exp_shifter(
//    in,
//    c_add,
//    out,condition
//);
//input [7:0] in;
//input c_add;
//output [7:0] out;
//input condition;
//assign out = condition ? in + c_add :in;

//endmodule



module sigmoid_bf_asic (
    input [15:0] x,
    input clk,
    input EN,
    output[15:0] sigmoid 
    );
 wire [15:0] out1,oneplusx;
 wire done;
 cordic_bfloat_hypb exp (
        .clk(clk),
        .EN(EN),
        .z(x),
        .out(out1),
        .done(done)
    );

 fp_adder oneplus(
    .a(16'h3f80),
    .b(out1),
    .out(oneplusx),
    .mode(1'b1)
     );
 
 reg q;


 wire lin_enable = done ? done & !q : lin_enable;
always@(posedge clk)begin
    if(EN) q<= 1'd0;
    else
    q <= done;
end


 wire lin_done;
 cordic_bfloat_linear division(
        .clk(clk),
        .EN1(lin_enable),
        .x(oneplusx),
        .y(out1),
        .out(sigmoid),
        .done(lin_done)
    );




endmodule


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
        input  EN1,
        input [8:-7] x,
        input [8:-7] y,
        output reg [15:0] out,
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

//    assign out = {z_out[SIGN_BIT-1],(z_out[EXP_SIZE-1:0]),z_out[-1:-MANTISSA_SIZE]};
// reg k=1'd1;
    wire done = (i==14)&&(!EN1) ? 1'd1 : 1'd0;
    always @(posedge clk)
    begin
        if (EN1) //  Like Reset
        begin
            x_ <= x;
            y_ <= y;
            // z_ <= {4'h0,z,20'h00000};      // modify for decimal change
            z_ <= 16'h00_00;
            i <= -5;
            IS_FIRST4 <= 1'b1;
            IS_FIRST13 <= 1'b1;
            out <= 16'd0;
   
        end
        else
        begin
            out <= {z_out[SIGN_BIT-1],(z_out[EXP_SIZE-1:0]),z_out[-1:-MANTISSA_SIZE]};
            if(i<14)
            begin
                i <= i+1;
                x_ <= x_;
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

