// Regfile

module Regfile ( clk, 
				 rst,
				 Read_addr_1,
				 Read_addr_2,
				 Read_data_1,
                 Read_data_2,
				 RegWrite,
				 Write_addr,
				 Write_data);
	
	parameter bit_size = 32;
	
	input  clk, rst;
	input  [4:0] Read_addr_1;
	input  [4:0] Read_addr_2;
	
	output [bit_size-1:0] Read_data_1;
	output [bit_size-1:0] Read_data_2;
	
	input  RegWrite;
	input  [4:0] Write_addr;
	input  [bit_size-1:0] Write_data;
	
    // write your code in here
	reg [bit_size-1:0] register[0:31];	
	
	// Read from register
	assign Read_data_1 = register[Read_addr_1];	
	assign Read_data_2 = register[Read_addr_2];
		
	integer i=0;
	always @(posedge clk or posedge rst)
	begin
		if(rst)		//rst==1,reset register to 0
			for(i=0;i<32;i=i+1)
				register[i] <= 0;
		else if(RegWrite)	// Write data into register
			register[Write_addr] <= Write_data;
	end	
	
endmodule






