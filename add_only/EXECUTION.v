`timescale 1ns/1ps

module EXECUTION(
	clk,
	rst,
	A,
	B,
	DX_RD,
	DX_BranchCtr,
	DX_BranchAddr,
	DX_MemCtr,
	DX_RegtoMem,
	ALUctr,
	
	ALUout,
	ALUoutBK,
	XM_RD,
	XM_BranchCtr,
	XM_BranchAddr,
	XM_MemCtr,
	XM_RegtoMem
);

input clk,rst,ALUop;
input [31:0] A,B;
input [4:0] DX_RD;
input [2:0] ALUctr, DX_BranchCtr, DX_MemCtr;
input [31:0] DX_BranchAddr, DX_RegtoMem;

output reg [4:0]XM_RD;
output reg [2:0] XM_BranchCtr, XM_MemCtr;
output reg [31:0]ALUout, ALUoutBK;
output reg [31:0] XM_BranchAddr, XM_RegtoMem;


//set pipeline register
always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
	  XM_RD	<= 5'd0;
	  XM_MemCtr <= 2'd0;
	  XM_BranchCtr <= 3'd0;
	  XM_BranchAddr <= 32'd0;
	end 
  else 
	begin
	  XM_RD <= DX_RD;
	  XM_MemCtr <= DX_MemCtr;
	  XM_RegtoMem <= DX_RegtoMem;
	  XM_BranchCtr <= DX_BranchCtr;
	  XM_BranchAddr <= DX_BranchAddr;
	end
end

// calculating ALUout
always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
	  ALUout	<= 32'd0;
	end 
  else 
	begin
	  case(ALUctr)
	    3'd0: // ADD // LW // SW // These all use ADD op
		  begin
	        ALUout <=A+B;
		  end
		3'd1: // SUB
		  begin
		    ALUout <=A-B;
		  end
		3'd2: // SLT
		  begin
		  	if (A<B) ALUout <=1;
		  	else ALUout <=0;
		  end
		3'd3: // BEQ
		  begin
		  	//if (A==B) begin
		  		//XM_BranchAddr <= (DX_BranchAddr * 4);
		  		XM_BranchAddr <= (DX_BranchAddr);
		  		//XM_BranchCtr <= 3'd1; // Branch
		  		XM_BranchCtr <= DX_BranchCtr; // Branch
		  	//end
		  end
		3'd4: // DIV
		  begin
		  	ALUout <= {A % B};
		  	ALUoutBK <= {A / B};
		  	//$display("HILOEX: %b == %b == %b", ALUout, A[4:0], B[4:0]);
		  end
		3'd5: // XOR 
		  begin
		  	ALUout <= A ^ B;
		  end
		3'd6: // BNE 
		  begin
		  	//if (A!=B) begin
		  		//XM_BranchAddr <= (DX_BranchAddr * 4);
		  		XM_BranchAddr <= (DX_BranchAddr);
		  		//XM_BranchCtr <= 3'd1; // Branch
		  		XM_BranchCtr <= DX_BranchCtr; // Branch
		  	//end
		  end
	  endcase
	  //$display("EX: %b", XM_BranchCtr);
	  //$display("EXADR: %b", XM_BranchAddr);
	end
end
endmodule
	
