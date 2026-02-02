`timescale 1ns/1ps

module async_fifo_tb;

  parameter WIDTH = 8;
  parameter DEPTH = 16;

  reg                 w_clk, r_clk;
  reg                 rst_w_n, rst_r_n;
  reg                 w_en, r_en;
  reg  [WIDTH-1:0]    w_data;

  wire [WIDTH-1:0]    r_data;   
  wire                full;   
  wire                empty;    

  integer i;
  integer exp_q [0:DEPTH-1];
  integer rd_ptr = 0;

 
  async_fifo #(
    .width(WIDTH),
    .depth(DEPTH)
  ) dut (
    .w_clk   (w_clk),
    .r_clk   (r_clk),
    .rst_w_n (rst_w_n),
    .rst_r_n (rst_r_n),
    .w_en    (w_en),
    .r_en    (r_en),
    .w_data  (w_data),
    .r_data  (r_data),
    .full    (full),
    .empty   (empty)
  );

 
  initial w_clk = 0;
  always #5 w_clk = ~w_clk;   

  initial r_clk = 0;
  always #7 r_clk = ~r_clk;   
 

  
  initial begin

   
    rst_w_n = 0; rst_r_n = 0;
    w_en = 0; r_en = 0; w_data = 0;

    #30;
    rst_w_n = 1; rst_r_n = 1;


    @(posedge r_clk);
    r_en = 1;
    @(posedge r_clk);
    r_en = 0;

    
    for (i = 0; i < DEPTH; i = i + 1) begin
      @(posedge w_clk);
      if (!full) begin
        w_en   = 1;
        w_data = i;
        exp_q[i] = i;
      end
      @(posedge w_clk);
      w_en = 0;
    end

    
    @(posedge w_clk);
    w_en = 1;
    w_data = 8'hAA;
    @(posedge w_clk);
    w_en = 0;

   
    for (i = 0; i < DEPTH; i = i + 1) begin
      @(posedge r_clk);
      r_en = 1;

      @(posedge r_clk);
      r_en = 0;

      if (r_data !== exp_q[rd_ptr]) begin
        $display("ERROR: expected %0d got %0d", exp_q[rd_ptr], r_data);
      end
      rd_ptr = rd_ptr + 1;
    end

    rd_ptr = 0;

    for (i = 0; i < 4; i = i + 1) begin
      fork
        begin
          @(posedge w_clk);
          w_en   = 1;
          w_data = i + 20;
          @(posedge w_clk);
          w_en   = 0;
        end
        begin
          @(posedge r_clk);
          r_en = 1;
          @(posedge r_clk);
          r_en = 0;
        end
      join
    end

   
    #50;
    $display("TEST COMPLETED");
    $finish;

  end

endmodule
