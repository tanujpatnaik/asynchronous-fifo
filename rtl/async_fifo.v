module async_fifo #(parameter width = 8 , parameter depth = 16)(r_clk,w_clk,rst_w_n,rst_r_n,w_en,r_en,w_data,r_data,full,empty);
input w_clk;
input rst_w_n;
input w_en;
input [width-1:0] w_data;
output full;
input r_clk;
input rst_r_n;
input r_en;
output reg  [width-1:0] r_data;
output empty;

localparam bit_depth = $clog2(depth);

reg [width-1:0] fifo [0:depth-1];

reg [bit_depth:0] w_ptr_bin,r_ptr_bin;
wire [bit_depth:0] w_ptr_gray,r_ptr_gray;
reg [bit_depth:0] w_ptr_gray_sync1, w_ptr_gray_sync2;
reg [bit_depth:0] r_ptr_gray_sync1, r_ptr_gray_sync2;

assign w_ptr_gray = (w_ptr_bin >> 1) ^ w_ptr_bin;
assign r_ptr_gray = (r_ptr_bin >> 1) ^ r_ptr_bin;

always @(posedge w_clk or negedge rst_w_n) 
begin
    if (!rst_w_n) 
    begin
        w_ptr_bin <= 0;
    end 
    else if (w_en && !full)
    begin
        w_ptr_bin <= w_ptr_bin + 1;
    end 
end

always @(posedge w_clk)
begin
    if (w_en && !full)
        fifo[w_ptr_bin[bit_depth-1:0]] <= w_data;
end


always @(posedge r_clk or negedge rst_r_n)
begin
    if(!rst_r_n)
    begin
        r_ptr_bin <= 0;
    end
    else if(r_en && !empty)
    begin
       r_ptr_bin <= r_ptr_bin + 1; 
    end
end

always @(posedge r_clk or negedge rst_r_n)
begin
    if (!rst_r_n)
        r_data <= {width{1'b0}};
    else if (r_en && !empty)
        r_data <= fifo[r_ptr_bin[bit_depth-1:0]];
end


always @(posedge r_clk or negedge rst_r_n) // synchronization from write to read
begin
    if (!rst_r_n) begin
        w_ptr_gray_sync1 <= 0;
        w_ptr_gray_sync2 <= 0;
    end 
    else begin
        w_ptr_gray_sync1 <= w_ptr_gray;
        w_ptr_gray_sync2 <= w_ptr_gray_sync1;
    end
end

always @(posedge w_clk or negedge rst_w_n) //synchronization from read to write
begin
    if (!rst_w_n) begin
        r_ptr_gray_sync1 <=0;
        r_ptr_gray_sync2 <=0;
    end
    else begin 
        r_ptr_gray_sync1 <=r_ptr_gray;
        r_ptr_gray_sync2 <=r_ptr_gray_sync1;
    end
end

reg empty_reg, full_reg;
// Empty flag - synchronous to read clock
always @(posedge r_clk or negedge rst_r_n)
begin
    if (!rst_r_n)
        empty_reg <= 1'b1;   // FIFO empty after reset
    else
        empty_reg <= (r_ptr_gray == w_ptr_gray_sync2);
end
    
// Full flag - synchronous to write clock
always @(posedge w_clk or negedge rst_w_n)
begin
    if (!rst_w_n)
        full_reg <= 1'b0;    // FIFO not full after reset
    else
        full_reg <= (w_ptr_gray =={~r_ptr_gray_sync2[bit_depth:bit_depth-1],r_ptr_gray_sync2[bit_depth-2:0]});
end
assign empty = empty_reg;
assign full  = full_reg;
endmodule
