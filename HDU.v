// Hazard Detection Unit

module HDU ( // input
			 ID_Rs,
             ID_Rt,
			 EX_WR_out,
			 EX_MemtoReg,
			 EX_JumpOP,
			 // output
			 // write your code in here
			 PCWrite,			 
			 IF_IDWrite,
			 IF_Flush,
			 ID_Flush);
	
	parameter bit_size = 32;
	
	input [4:0] ID_Rs;
	input [4:0] ID_Rt;
	input [4:0] EX_WR_out;
	input EX_MemtoReg;
	input [1:0] EX_JumpOP;
	
	// write your code in here
	output reg PCWrite;
	output reg IF_IDWrite;
	output reg IF_Flush;
	output reg ID_Flush;	
	
	always @(*)
	begin
		PCWrite <= 1;		//PCout=PCin
		IF_IDWrite <= 1;	//ID data=IF data
		IF_Flush <= 0;
		ID_Flush <= 0;
			
		// Load
		if(EX_MemtoReg)
		begin
			if((EX_WR_out == ID_Rs) || (EX_WR_out == ID_Rt))
			begin 
				PCWrite <= 0;
				IF_IDWrite <= 0;
			end
		end
		// Branch
		if(EX_JumpOP != 0)
		begin
			// clear wrong instruction
			IF_Flush <= 1;	
			ID_Flush <= 1;	
		end	
	end
	
endmodule