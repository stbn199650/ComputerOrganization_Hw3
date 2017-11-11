// Forwarding Unit

module FU ( // input 
			EX_Rs,
            EX_Rt,
			M_RegWrite,
			M_WR_out,
			WB_RegWrite,
			WB_WR_out,
			// output
			// write your code in here
			// Enable forwarding
			EN_Rs,	// EN:select origin Rs、Rt or the forward data
			EN_Rt,	
			// Select Forward signal
			S_Rs,	// S: source of Rs、Rt, 1=>data from WB 0=>data from MEM
			S_Rt);

	input [4:0] EX_Rs;
    input [4:0] EX_Rt;
    input M_RegWrite;
    input [4:0] M_WR_out;
    input WB_RegWrite;
    input [4:0] WB_WR_out;

	// write your code in here
	output reg EN_Rs, EN_Rt, S_Rs, S_Rt;
	
	always @(*)
	begin
		//initialize: no hazards
		EN_Rs <= 0;	
		EN_Rt <= 0;
		S_Rs <= 0;
		S_Rt <= 0;
		
		// EX hazard(EX/MEM)
		//The first ALU operand comes from prior ALU result
		if(M_RegWrite && (M_WR_out!=0))
		begin
			if(M_WR_out == EX_Rs)
			begin
				EN_Rs <= 1;
				S_Rs <= 0;
			end
			if(M_WR_out == EX_Rt)
			begin
				EN_Rt <= 1;
				S_Rt <= 0;
			end
		end
		
		// Mem hazard(MEM/WB)
		//The first ALU operand comes from data memory or early ALU result
		if(WB_RegWrite && (WB_WR_out!=0))
		begin
			if((WB_WR_out == EX_Rs) && (M_WR_out != EX_Rs))
			begin
				EN_Rs <= 1;
				S_Rs <= 1;
			end
			
			if((WB_WR_out == EX_Rt) && (M_WR_out != EX_Rt))
			begin
				EN_Rt <= 1;
				S_Rt <= 1;
			end
		end		
	end	
	
endmodule





