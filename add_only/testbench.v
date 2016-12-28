`define CYCLE_TIME 20
`define INSTRUCTION_NUMBERS 86
`timescale 1ns/1ps
`include "CPU.v"

module mul(
        input clk100mhz,
        input rst,
        input a1,
        input a2,
        input a3,
        input a4,
        input b1,
        input b2,
        input b3,
        input b4,
        
        output o1,
        output o2,
        output o3,
        output o4,
        output o5,
        output o6,
        output o7,
        output o8,
        
        output  ca,
        output  cb,
        output  cc,
        output  cd,
        output  ce,
        output  cf,
        output  cg,
        //output  dp,
        
        
        output an0,
        output an1,
        output an2,
        output an3,
        output an4,
        output an5,
        output an6,
        output an7,
        

        output LED_15   
        
    );

module testbench;
reg Clk, Rst;
reg [31:0] i;
reg [6:0] seg [0:9];
reg [7:0] answer ;
reg [7:0] an ;

always@ (posedge clk100mhz)begin
    seg[0] = 7'b1000000;//h40;//8'hc0;
    seg[1] = 7'b1111001;//h79;//8'hf9;
    seg[2] = 7'b0100100;//h24;//8'ha4;
    seg[3] = 7'b0110000;//h30;//8'hb0;
    seg[4] = 7'b0011001;//h19;//8'h99;
    seg[5] = 7'b0010010;//h12;//8'h92;
    seg[6] = 7'b0000010;//h02;//8'h82;
    seg[7] = 7'b1111000;//h78;//8'hf8;
    seg[8] = 7'b0000000;//h00;//8'h80;
    seg[9] = 7'b0010000;//h10;//8'h90;  
end 

// Instruction DM initialilation
initial
begin 
		for (i=0; i<54; i=i+1) cpu.IF.instruction[i] = 32'b000000_00000_00000_00000_00000_100000;
//                          bxxxxxx_sssss_ttttt_ddddd_xxxxx_xxxxxx
        cpu.IF.instruction[ 00] = 32'b100011_00000_00010_00000_00000_000001;    //01    lw $2, offset(0+1)
        cpu.IF.instruction[ 01] = 32'b100011_00000_00001_00000_00000_000000;    //02    lw $1, offset(0+0)

        cpu.IF.instruction[ 04] = 32'b000100_00010_00000_00000_00000_010000;    //03    beq $2, $0, PEq (5+16 = 21)
       
        cpu.IF.instruction[ 09] = 32'b000000_00001_00010_00000_00000_011010;    //04    LOOP: div $1, $2
        cpu.IF.instruction[ 10] = 32'b000000_00010_00000_00001_00000_100000;    //05    LOOP: add $1, $2, $0
        cpu.IF.instruction[ 13] = 32'b000000_00000_00000_00010_00000_010000;    //06    LOOP: mfhi $2
        cpu.IF.instruction[ 17] = 32'b000101_00010_00000_11111_11111_110111;    //07    LOOP: bne $2, $0, LOOP                                                       
        cpu.IF.instruction[ 21] = 32'b101011_00000_00001_00000_00000_000010;    //08    PEq: sw $1, offset(0+2)
                                                                                
		cpu.IF.PC = 0;
end

// Data Memory & Register Files initialilation
initial
begin
	cpu.MEM.DM[0] = {28'b0, {a4,a3,a2,a1}};
	cpu.MEM.DM[1] = {28'b0, {b4,b3,b2,b1}};
	for (i=2; i<128; i=i+1) cpu.MEM.DM[i] = 32'b0;
	
	cpu.ID.REG[0] = 32'd0;
	cpu.ID.REG[1] = 32'd0;
	cpu.ID.REG[2] = 32'd0;
	for (i=3; i<32; i=i+1) cpu.ID.REG[i] = 32'b0;

end

//clock cycle time is 20ns, inverse Clk value per 10ns
initial Clk = 1'b1;
always #(`CYCLE_TIME/2) Clk = ~Clk;

//Rst signal
initial begin
	cycles = 32'b0;
	Rst = 1'b1;
	#12 Rst = 1'b0;
end

CPU cpu(
	.clk(Clk),
	.rst(Rst)
);

always @(posedge clk100mhz or posedge rst)
begin
    if(rst)begin 
        an <=8'b11111111;
        answer <= 'b1111111;
    end else if(Product_Valid == 1'b1 ) begin
        if(count[15:14] == 2'd0 )begin
            answer <= seg[cpu.MEM.DM[2] % 10] ;            //fisrt
            an <=8'b11111110;
        end else if(count[15:14] == 2'd1 )begin
            answer <= seg[(cpu.MEM.DM[2]%100)/10] ;           // second 7 segment
            an <=8'b11111101;
       end else if(count[15:14] == 2'd2)begin
            answer <= seg[cpu.MEM.DM[2]/100] ;             // third 7 segment
            an <=8'b11111011;
        end else begin
            answer <= 7'b1111111;
            an <=8'b11110111;
        end
        
    end else begin
        answer <= 7'b1111111;
        
    end
end 

assign {cg,cf,ce,cd,cc,cb,ca} = answer ;
assign {an7,an6,an5,an4,an3,an2,an1,an0} = an;

endmodule

