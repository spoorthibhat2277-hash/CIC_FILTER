`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2026 17:43:14
// Design Name: 
// Module Name: cic_top
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


module cic_top #(
  parameter R=2048,
  
  parameter N=3,
  parameter M=1,
  parameter BIN=2,
  parameter BOUT=38
  ) 
   (input clk,
    input reset,
    input enable,
    input signed [1:0] bits,
    output reg signed [BOUT-1:0] cicout,
    output reg outready );
    
reg signed [BOUT-1:0] integrator [0:N-1];
reg signed [BOUT-1:0] comb_in [0:N-1];
reg signed [BOUT-1:0] comb_delay [0:N-1];
reg signed [BOUT-1:0] comb_out [0:N-1];

reg [$clog2(R)-1:0] count;
reg dec_pulse;

always @(posedge clk) begin
    if (reset) begin
      integrator[0] <= 0;
      integrator[1] <= 0;
      integrator[2] <= 0;
    
      count <=0;
      dec_pulse <=0;

    end
    else if (enable) begin
        integrator[0]<= integrator[0] + bits;
        integrator[1] <= integrator[1] + integrator[0];
        integrator[2] <= integrator[2] +integrator[1];
            
        if (count==R-1) begin
          count <=0;
          dec_pulse <=1;
          end
        else begin
          count<= count + 1;
          dec_pulse<=0;
          end
      end
end
 always @(posedge clk) begin
   if (reset) begin
        comb_in[0] <= 0;    comb_in[1] <= 0;    comb_in[2] <= 0; 
         comb_delay[0] <= 0; comb_delay[1] <= 0; comb_delay[2] <= 0;
        comb_out[0] <= 0;   comb_out[1] <= 0;   comb_out[2] <= 0; 
        cicout <= 0;
        outready <= 0;
    end
    else if (dec_pulse) begin
     comb_delay[0]<= comb_in[0];
     comb_in[0] <= integrator[2];
     comb_out[0] <= comb_in[0] - comb_delay[0];
     comb_delay[1]<= comb_in[1];
     comb_in[1] <= comb_out[0];
     comb_out[1] <= comb_in[1] - comb_delay[1];
     comb_delay[2]<= comb_in[2];
     comb_in[2] <= comb_out[1];
     comb_out[2] <= comb_in[2] - comb_delay[2];
         
      cicout <= $signed(comb_out[2][BOUT-6 -: 20]);
      outready <= 1;
    end
    else begin
        outready <= 0;
    end
    
end

endmodule
