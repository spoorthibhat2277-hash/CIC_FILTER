`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2025 20:47:37
// Design Name: 
// Module Name: cic_tb
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


module cic_tb();
    reg data [0:4096025];
    
    reg clk,clk2,clk3,clk4, reset,enable;
    wire outready,outready2;
    
    reg  signed [1:0] bits;
    
    wire signed [37:0] cicout; //change according to need
    wire signed [19:0] firout; //change according to need
    wire firready;
    initial begin
        $readmemb("C:/Users/shrid/Downloads/hz990.mem", data); //input data
        $display("data[0]=%b data[1]=%b data[100]=%b", data[0], data[1], data[100]);
    end
    

    initial begin
        clk=0;
        clk2=0;
        clk3=0;
        bits=0;
        enable=0;
        reset = 1;
        #51 reset = 0;
        enable=1;
    end
    always #50 clk=~clk;
    always #25600 clk2=~clk2; //change according to filter output frequencies
    always #102400 clk3=~clk3; //change according to filter output frequencies

    
    integer i;
    initial i = 0;
    
    integer fd1,fd2,fd3,fd4;
    initial begin
        fd1 = $fopen("bits.txt","w");
        fd2 = $fopen("cic512_990.txt","w"); //ouput file change according to need
        fd3 = $fopen("fircomp.txt","w"); //ouput file change according to need
        fd4 = $fopen("cic512_500_by4.txt","w"); //ouput file change according to need
    end
    always @(posedge clk) begin
        if (i < 4096026) begin
            if(i%2==0)begin
                bits={1'b0,data[i]};
            end else begin
                bits={2{data[i]}};
            end
            i <= i + 1;
        end else begin
            #200;
            $finish;
        end
    end
    always @(posedge clk) begin
        $fwrite(fd1, "%d\n",  bits); 
    end
    always @(posedge clk) begin
        if(outready)begin
            $fwrite(fd2, "%d\n",  $signed(cicout));//keep 20 bits width 
        end
    end
    always @(posedge clk2) begin
       if (firready) begin
            $fwrite(fd3, "%d\n",  $signed(firout)); //keep 20 bits width
       end
    end
    always @(posedge clk3) begin
        $fwrite(fd4, "%d\n",  $signed(cicout));//keep 20 bits width
    end
    cic_top #(.R(2048), .N(3), .M(1), .BIN(2), .BOUT(38)) cic(.clk(clk), .reset(reset), .enable(enable), .bits(bits), .cicout(cicout), .outready(outready) );
    fir_comp #(
    .TAPS(49),
    .DATA_W(20),
    .COEF_W(16),
    .FRAC(14),
    .ACC_W(42)
) fir1 (
    .clk(clk),
    .reset(reset),
    .in_valid(outready),
    .in_data(cicout[19:0]),
    .out_data(firout),
    .out_valid(firready)
);
    
endmodule