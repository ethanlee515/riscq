// Generator : SpinalHDL dev    git head : 196c88c250c8a53da425b2e185580e43b8edc1c5
// Component : MyTimer
// Git hash  : febadb68d0e4ae36c7b6dfac1793cfd41024899a

`timescale 1ns/1ps

module MyTimer (
  output reg  [7:0]    counter,
  input  wire          clk,
  input  wire          reset
);


  always @(posedge clk or posedge reset) begin
    if(reset) begin
      counter <= 8'h7b;
    end else begin
      counter <= (counter + 8'h01);
    end
  end


endmodule
