// Generator : SpinalHDL dev    git head : 196c88c250c8a53da425b2e185580e43b8edc1c5
// Component : Timer
// Git hash  : febadb68d0e4ae36c7b6dfac1793cfd41024899a

`timescale 1ns/1ps

module Timer (
  output reg  [7:0]    time_1,
  input  wire          clk,
  input  wire          reset
);


  always @(posedge clk or posedge reset) begin
    if(reset) begin
      time_1 <= 8'h7b;
    end else begin
      time_1 <= 8'h01;
    end
  end


endmodule
