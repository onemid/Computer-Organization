`timescale 1ns/1ps

module INSTRUCTION_DECODE(
	clk,
	rst,
	IR,
	FD_BranchCtr,
	FD_BranchAddr,
	FD_MemCtr,
	PC,
	MW_RD,
	MW_ALUout,
	MW_ALUoutBK,
	
	A,
	B,
	RD,
	DX_BranchCtr,
	DX_BranchAddr,
	ALUctr,
	DX_MemCtr,
	RegtoMem
);

input clk,rst;
input [31:0]IR, PC, MW_ALUout, MW_ALUoutBK;
input [4:0] MW_RD;
input [2:0] FD_BranchCtr,FD_MemCtr;
input [31:0] FD_BranchAddr;

output reg [31:0] A, B;
output reg [4:0] RD;
output reg [2:0] ALUctr;
output reg  [2:0] DX_MemCtr;
output reg  [31:0] RegtoMem;
output reg [2:0] DX_BranchCtr;
output reg [31:0] DX_BranchAddr;

//register file
reg [31:0] REG [0:31];
reg [63:0] HILO;
// 0 ~ 31 for general purpose 
// 32 HI 33 LO

//Write back
always @(posedge clk)//add new Dst REG source here
begin
//$display("FD_MemCtr: %b", FD_MemCtr);
	if(MW_RD)
	  REG[MW_RD] <= MW_ALUout;
	else
	  REG[MW_RD] <= REG[MW_RD];//keep REG[0] always equal zero
	if (FD_MemCtr == 3'd6) begin
	  HILO[63:32] <= MW_ALUout;
	  HILO[31:0] <= MW_ALUoutBK;
	  $display("HILO: %b", MW_ALUout);
	end
end
	
//set A, and other register content(j/beq flag and address)	
always @(posedge clk or posedge rst)
begin
	if(rst) 
	  begin
	    A 	<=32'b0;
	  end 
	else 
	  begin
	    A 	<=REG[IR[25:21]];
	  end
end

//set control signal, choose Dst REG, and set B	
always @(posedge clk or posedge rst)
begin
	if(rst) 
	  begin
		B 		<=32'b0;
		RegtoMem <=32'b0;
		RD 		<=5'b0;
		ALUctr 	<=3'b0;
		DX_MemCtr <= 3'd0;
		DX_BranchCtr <= 3'd0;
		DX_BranchAddr <= 32'd0;
	  end 
	else 
	  begin
	    $display("ID_PC: %d", PC);
	  	DX_BranchCtr <= FD_BranchCtr;
	  	DX_BranchAddr <= FD_BranchAddr;
	    case(IR[31:26])
		  6'b000000://R-Type
		    begin
			  case(IR[5:0])//funct & setting ALUctr
			    6'b10_0110:// XOR
				  begin
		            B	<=REG[IR[20:16]];
		            RD	<=IR[15:11];
		            DX_MemCtr <=3'd0; // Write to Register
					ALUctr <=3'd5; // XOR
					DX_BranchCtr <= 3'd0; // No branch
				  end
			    6'b01_0000:// MFHI
				  begin
		            B	<=HILO[63:32];
		            RD	<=IR[15:11];
		            DX_MemCtr <=3'd0; // Write to Register
					ALUctr <=3'd0; // ADD
					DX_BranchCtr <= 3'd0; // No branch
				  end
				6'b01_0001:// MFLO
				  begin
		            B	<=HILO[31:0];
		            RD	<=IR[15:11];
		            DX_MemCtr <=3'd0; // Write to Register
					ALUctr <=3'd0; // ADD
					DX_BranchCtr <= 3'd0; // No branch
				  end
			    6'b01_1010:// DIV
				  begin
		            B	<=REG[IR[20:16]];
		            RD	<=IR[15:11];
		            DX_MemCtr <=3'd6; // HI LO USAGE
					ALUctr <=3'd4; // DIV
					DX_BranchCtr <= 3'd0; // No branch
					//$display("IDDX_MemCtr: %b", DX_MemCtr);
				  end
			    6'b10_0000:// ADD
				  begin
		            B	<=REG[IR[20:16]];
		            RD	<=IR[15:11];
		            DX_MemCtr <=3'd0; // Write to Register
					ALUctr <=3'd0; // ADD
					DX_BranchCtr <= 3'd0; // No branch
				  end
				6'b10_0100:// SUB
				  begin
					B 	<=REG[IR[20:16]];
					RD	<=IR[15:11];
					DX_MemCtr <=3'd0; // Write to Register
					ALUctr <=3'd1; // SUB
					DX_BranchCtr <= 3'd0; // No branch
				  end
				6'b10_1010:// SLT
				  begin
					B 	<=REG[IR[20:16]];
					RD	<=IR[15:11];
					DX_MemCtr <=3'd0;
					ALUctr <=3'd2; // SLT
					DX_BranchCtr <= 3'd0; // No branch
				  end
			  endcase
			end
	      6'b10_0011:// LW (I-Type)
			begin
			  B 	<=IR[15:0];
			  RD	<=IR[20:16];
			  ALUctr <=3'd0; // ADD
			  DX_MemCtr <=3'd1; // Read DM and load to register
			  DX_BranchCtr <= 3'd0; // No branch
			end
	      6'b10_1011:// SW
			begin
			  B 	<=IR[15:0];
			  RD	<=5'd0;
			  RegtoMem <= REG[IR[20:16]];
			  ALUctr <=3'd0; // ADD
			  DX_MemCtr <=3'd2; // Read register and load to DM
			  DX_BranchCtr <= 3'd0; // No branch
			end
	      6'b00_0100:// BEQ
			begin
			  B 	<=REG[IR[20:16]];
			  if (REG[IR[25:21]] == REG[IR[20:16]]) begin
			  	RD	<=5'b0;
			    ALUctr <=3'd3; // BEQ
			    DX_MemCtr <=3'd7; // DO NOTHING
			    DX_BranchAddr <= ({{16{IR[15]}}, IR[15:0]} * 4) + PC; // DO SIGN EXTENTED
			    DX_BranchCtr <= 3'd1; // DO NOT JUDGE HERE
			  end
			  else begin
			  	RD	<=5'b0;
			    ALUctr <=3'd3; // BEQ
			    DX_MemCtr <=3'd7; // DO NOTHING
			    DX_BranchAddr <= {{16{IR[15]}}, IR[15:0]}; // DO SIGN EXTENTED
			    DX_BranchCtr <= 3'd0; // DO NOT JUDGE HERE
			  end
			  
			end
		  6'b00_0101:// BNE
			begin
			  B 	<=REG[IR[20:16]];
			  if (REG[IR[25:21]] != REG[IR[20:16]]) begin
			  	RD	<=5'b0;
			    ALUctr <=3'd6; // BNE
			    DX_MemCtr <=3'd7; // DO NOTHING
			    DX_BranchAddr <= ({{16{IR[15]}}, IR[15:0]} * 4) + PC; // DO SIGN EXTENTED
			    DX_BranchCtr <= 3'd1; // DO NOT JUDGE HERE
			  end
			  else begin
			  	RD	<=5'b0;
			    ALUctr <=3'd6; // BNE
			    DX_MemCtr <=3'd7; // DO NOTHING
			    DX_BranchAddr <= {{16{IR[15]}}, IR[15:0]}; // DO SIGN EXTENTED
			    DX_BranchCtr <= 3'd0; // DO NOT JUDGE HERE
			  end
			end
	      6'b00_0010:// J
			begin
			  RD	<=5'b0;
			  DX_MemCtr <=3'd7;  // DO NOTHING
			  DX_BranchAddr <= (PC & 32'b11110000000000000000000000000000) | (IR[25:0] << 2);
			  DX_BranchCtr <= 3'd2; // JUMP
			end
		endcase
	  end
end
endmodule
