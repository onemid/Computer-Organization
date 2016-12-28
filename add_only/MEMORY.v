`timescale 1ns/1ps

module MEMORY(
    clk,
    rst,
    ALUout,
    ALUoutBK,
    XM_RD,
    XM_BranchCtr,
    XM_BranchAddr,
    XM_MemCtr,
    XM_RegtoMem,
    
    MW_ALUout,
    MW_ALUoutBK,
    BranchCtr,
    BranchAddr,
    FD_MemCtr,
    MW_RD,
);
input clk, rst;
input [31:0] ALUout;
input [31:0] ALUoutBK;
input [4:0] XM_RD;
input [2:0] XM_MemCtr;
input [31:0] XM_RegtoMem;
input [2:0] XM_BranchCtr;
input [31:0] XM_BranchAddr;

output reg [31:0] MW_ALUout;
output reg [31:0] MW_ALUoutBK;
output reg [4:0] MW_RD;
output reg [2:0] BranchCtr;
output reg [31:0] BranchAddr;
output reg [2:0] FD_MemCtr;

//data memory
reg [31:0] DM [0:127];
/*
//always store word to data memory
always @(posedge clk)
  if(XM_MemWrite)
    DM[ALUout[6:0]] <= XM_MD;
*/

//send to Dst REG: "load word from data memory" or  "ALUout"
always @(posedge clk)
begin
  if(rst)
    begin
      MW_ALUout <=  32'b0;
      MW_RD     <=  5'b0;
      BranchCtr <= 3'd0;
      BranchAddr <= 32'd0;
      $display("MERESET");
    end
  else
    begin
      BranchCtr <= XM_BranchCtr;
      BranchAddr <= XM_BranchAddr;
      FD_MemCtr <= XM_MemCtr;
      case(XM_MemCtr)
        3'd0:// Write to Register
          begin
            MW_ALUout   <=  ALUout;
            MW_RD     <=  XM_RD;
          end
        3'd1:// Read DM and load to register
          begin
            MW_ALUout   <=  DM[ALUout];
            MW_RD     <=  XM_RD;
          end
        3'd2:// Read register and load to DM
          begin
            DM[ALUout]   <=  XM_RegtoMem;
            MW_RD     <=  5'b0;
          end
        3'd6: // HI LO USAGE
          begin
            MW_ALUout     <=  ALUout;
            MW_ALUoutBK     <=  ALUoutBK;
          end
        3'd7: // DO NOTHING
          begin
            MW_RD     <=  5'b0;
          end
      endcase
      //$display("MEX: %b", XM_BranchCtr);
      //$display("MEB: %b", BranchCtr);
      //$display("MEADR: %b", BranchAddr);
    end
end

endmodule
