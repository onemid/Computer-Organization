`timescale 1ns/1ps

`include "INSTRUCTION_FETCH.v"
`include "INSTRUCTION_DECODE.v"
`include "EXECUTION.v"
`include "MEMORY.v"

module CPU(
	clk,
	rst
);
input clk, rst;
/*============================== Wire  ==============================*/
// INSTRUCTION_FETCH wires
wire [31:0] FD_PC, FD_IR, BranchAddr;
wire [2:0] BranchCtr;
// INSTRUCTION_DECODE wires
wire [31:0] A, B;
wire [4:0] DX_RD;
wire [2:0] ALUctr;
wire [2:0] FD_MemCtr;
wire [2:0] DX_MemCtr, DX_BranchCtr, FD_BranchCtr;
wire [31:0] RegtoMem, FD_BranchAddr;
wire [31:0] DX_RegtoMem, DX_BranchAddr;
// EXECUTION wires
wire [31:0] XM_ALUout, XM_ALUoutBK;
wire [4:0] XM_RD;
wire [2:0] XM_MemCtr, XM_BranchCtr;
wire [31:0] XM_RegtoMem, XM_BranchAddr;
// DATA_MEMORY wires
wire [31:0] MW_ALUout, MW_ALUoutBK;
wire [4:0]	MW_RD;

/*============================== INSTRUCTION_FETCH  ==============================*/

INSTRUCTION_FETCH IF(
	.clk(clk),
	.rst(rst),
	.BranchCtr(BranchCtr),
	.BranchAddr(BranchAddr),

	.PC(FD_PC),
	.IR(FD_IR),
	.FD_BranchCtr(FD_BranchCtr),
	.FD_BranchAddr(FD_BranchAddr)
);

/*============================== INSTRUCTION_DECODE ==============================*/

INSTRUCTION_DECODE ID(
	.clk(clk),
	.rst(rst),
	.PC(FD_PC),
	.IR(FD_IR),
	.FD_BranchCtr(FD_BranchCtr),
	.FD_BranchAddr(FD_BranchAddr),
	.FD_MemCtr(FD_MemCtr),
	.MW_RD(MW_RD),
	.MW_ALUout(MW_ALUout),

	.A(A),
	.B(B),
	.RD(DX_RD),
	.DX_BranchCtr(DX_BranchCtr),
	.DX_BranchAddr(DX_BranchAddr),
	.ALUctr(ALUctr),
	.DX_MemCtr(DX_MemCtr),
	.RegtoMem(DX_RegtoMem)
);

/*==============================     EXECUTION  	==============================*/

EXECUTION EXE(
	.clk(clk),
	.rst(rst),
	.A(A),
	.B(B),
	.DX_RD(DX_RD),
	.DX_BranchCtr(DX_BranchCtr),
	.DX_BranchAddr(DX_BranchAddr),
	.ALUctr(ALUctr),
	.DX_MemCtr(DX_MemCtr),
	.DX_RegtoMem(DX_RegtoMem),

	.ALUout(XM_ALUout),
	.ALUoutBK(XM_ALUoutBK),
	.XM_RD(XM_RD),
	.XM_BranchCtr(XM_BranchCtr),
	.XM_BranchAddr(XM_BranchAddr),
	.XM_MemCtr(XM_MemCtr),
	.XM_RegtoMem(XM_RegtoMem)
);

/*==============================     DATA_MEMORY	==============================*/

MEMORY MEM(
	.clk(clk),
	.rst(rst),
	.ALUout(XM_ALUout),
	.ALUoutBK(XM_ALUoutBK),
	.XM_RD(XM_RD),
	.XM_BranchCtr(XM_BranchCtr),
	.XM_BranchAddr(XM_BranchAddr),
	.XM_MemCtr(XM_MemCtr),
	.XM_RegtoMem(XM_RegtoMem),

	.MW_ALUout(MW_ALUout),
	.MW_ALUoutBK(MW_ALUoutBK),
	.BranchCtr(BranchCtr),
	.BranchAddr(BranchAddr),
	.FD_MemCtr(FD_MemCtr),
	.MW_RD(MW_RD)
);

endmodule
