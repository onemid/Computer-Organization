`timescale 1ns/1ps

module INSTRUCTION_FETCH(
	clk,
	rst,
	BranchCtr,
	BranchAddr,
	
	PC,
	IR,
	FD_BranchCtr,
	FD_BranchAddr
);

input clk, rst;
input [2:0] BranchCtr;
input [31:0] BranchAddr;
output reg [2:0] FD_BranchCtr;
output reg 	[31:0] PC, IR, FD_BranchAddr;

//instruction memory
reg [31:0] instruction [127:0];

//output instruction
always @(posedge clk or posedge rst)
begin
	if(rst)
		IR <= 32'd0;
	else
		begin
	    	case (BranchCtr)
				3'd1: // Branch
					begin
						IR <= instruction[BranchAddr[10:2]];
						PC <= BranchAddr+4;
					end
				3'd2: // jump
					begin
						IR <= instruction[BranchAddr[10:2]];
						PC <= BranchAddr+4;
					end
				default:
					begin
						IR <= instruction[PC[10:2]];
					end
			endcase
		end

end

// output program counter
always @(posedge clk or posedge rst)
begin
	if(rst)
		begin
			PC <= 32'd0;
			FD_BranchCtr <= 3'd0;
			FD_BranchAddr <= 32'd0;
		end
	else//add new PC address here, ex: branch, jump...
	    begin
	    //$display("IF: %b", BranchCtr);
	    	FD_BranchCtr <= BranchCtr;
			FD_BranchAddr <= BranchAddr;
	    	case (BranchCtr)
				3'd1: // Branch
					begin
						//if (BranchAddr[31] == 1'b0) begin
							//PC <= BranchAddr;
							$display("Blah! %d -- %d", PC, BranchAddr[16:0]);
						//end
						//else if (BranchAddr[31] == 1'b1)begin
							//$display("Here!");
							//PC <= (PC) + {15'b0, BranchAddr[16:0]};
							//$display("Nah! %b -- %b", PC, BranchAddr[16:0]);
						//end
						//$display("1PC: %b", PC);
						//$display("??! %b -- %b", PC, BranchAddr);
					end
				3'd2: // jump
					begin
						//PC <= BranchAddr;
					end
				default:
					begin
						PC <= PC + 4;
					end
			endcase
			//PC <= PC + 4;
			
	    end
end

endmodule