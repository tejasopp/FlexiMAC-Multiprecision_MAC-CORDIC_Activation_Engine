module accelerator (
    input clk, 
    input reset, load_r, load_wr, relu, sel,
    input [7:0] data_in,
    output done
    );
    
    wire rst_array;
    wire stop_proc;
    wire [8*1024-1:0] in_r;
    wire [7:0] w_r;
    wire [8*1024-1:0] p;
    
    wire [8*1024-1:0] out;
    wire flag;
    
    wire [1:0] load_mem;
    wire rst_mem;
    wire [5:0] cnt_r, cnt_c;
    wire [4:0] cnt_w;
    
    systolic1 sys (
	.clk(clk), 
	.rst(rst_array),
	 .sel(sel), 
	 .stop_proc(stop_proc),
     .in_r(in_r),
     .w_r(w_r),
     .p(p)
);
    
    relu r (
    .in(p),
    .p(out),
    .clk(clk),
    .flag(flag)
);

    control c (
    .clk(clk), 
    .load_r(load_r), 
    .load_wr(load_wr), 
    .relu(relu),
    .reset(reset),
    .load_mem(load_mem),
    .rst_mem(rst_mem), 
    .rst(rst_array), 
    .flag(flag),
    .cnt_r(cnt_r), 
    .cnt_c(cnt_c), 
    .cnt_w(cnt_w), 
    .done(done), 
    .stop_proc(stop_proc)
);
    
	wbmem w (
    .clk(clk), 
    .rst(rst_mem),
    .load(load_mem),
    .data_in(data_in),
    .res(out),
    .cnt_r(cnt_r), 
    .cnt_c(cnt_c),    // Acts as address 
    .cnt_w(cnt_w),
    .im_r(in_r),   // flattened 32x32 r image = 1024 bytes 
    .w_r(w_r)
   );

endmodule // accelerator
