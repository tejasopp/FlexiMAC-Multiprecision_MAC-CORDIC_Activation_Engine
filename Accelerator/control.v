module control (
    input clk, load_r, load_wr, relu,
    input reset,
    output [1:0] load_mem,
    output reg rst_mem, rst, flag,
    output reg [5:0] cnt_r, cnt_c, 
    output reg [4:0] cnt_w, 
    output reg done, stop_proc
) ;
    
   
    assign load_mem = {load_r, load_wr};
    wire [1:0] sig;
    assign sig = {|load_mem, reset};
    
//    reg [1:0] count;
//    reg count_load;
    
    always @ (posedge clk) begin
    case (sig)
        2'b01 : begin 
                
                done <= 0;
                rst <= 0;
                rst_mem <= 0;
                flag <= 0;
                cnt_r <= 0;
                cnt_c <= 0;
                cnt_w <= 0;
                end
        2'b10 : begin
                
                done <= 0;
                rst <= 0;
                flag <= 0;
                cnt_r <= 0;
                cnt_c <= 0;
                cnt_w <= 0;
                end
        2'b11 : begin 
                
                done <= 0;
                rst <= 0;
                flag <= 0;
                rst_mem <= 0;
                cnt_r <= 0;
                cnt_c <= 0;
                cnt_w <= 0;
                end
       2'b00 : begin
                rst <= 1;
                rst_mem <= 1;
                        if(done) begin
                        if(relu)begin
                        flag <= 1;
                        rst_mem <= 0;
                        cnt_r <= 0;
                        cnt_c <= 0;
                        cnt_w <= 0;
                        stop_proc <= 1;
                        
                        end
                        else begin
                        rst_mem <= 0;
                        flag <= 0;
                        cnt_r <= 0;
                        cnt_c <= 0;
                        cnt_w <= 0;
                        stop_proc <= 1;
                        end
                        end
                        else begin
                        cnt_w <= cnt_w + 1;
                        if (cnt_c < 5'd5) cnt_c <= cnt_c + 1;
                        else begin
                        cnt_c <= 0;
                        cnt_r <= cnt_r + 1;
                        end
                        end 
                        if (cnt_w == 5'd24) begin
                        done <= 1;
                        end
                        end                
        default : begin
                done <= 0;
                 rst <= 0;
                 flag <= 0;
                rst_mem <= 0;
                cnt_r <= 0;
                cnt_c <= 0;
                cnt_w <= 0;
                end
        endcase
    end
	   
  
endmodule
