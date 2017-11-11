// top
`include "Add.v"
`include "ALU.v"
`include "Controller.v"
`include "Jump_Ctrl.v"
`include "Mux2to1.v"
`include "Mux4to1.v"
`include "PC.v"
`include "Regfile.v"
`include "Sign_Extend.v"
`include "EX_M.v"
`include "FU.v"
`include "HDU.v"
`include "ID_EX.v"
`include "IF_ID.v"
`include "M_WB.v"

module top ( clk,
             rst,
			 // Instruction Memory
			 IM_Address,
             Instruction,
			 // Data Memory
			 DM_Address,
			 DM_enable,
			 DM_Write_Data,
			 DM_Read_Data);

	parameter data_size = 32;
	parameter mem_size = 16;	
	parameter pc_size = 18;
	
	input  clk, rst;
	
	// Instruction Memory
	output [mem_size-1:0] IM_Address;	
	input  [data_size-1:0] Instruction;

	// Data Memory
	output [mem_size-1:0] DM_Address;
	output DM_enable;
	output [data_size-1:0] DM_Write_Data;	
    input  [data_size-1:0] DM_Read_Data;
	
	// write your code here
	
	// ALU
	wire [3:0] ALUOp;
	wire [4:0] shamt;
	wire [data_size-1:0] src;
	wire [data_size-1:0] ALU_result;
	wire EX_Zero;
	
	// Controller
	wire [5:0] opcode;
	wire [5:0] funct;	
	wire Branch;
	wire Jr;
	wire Jump;
	wire Jal;
	wire MemWrite;
	wire MemtoReg;
	wire RegDst;
	wire Extend_h;
	
	// Jump_Ctrl
	wire [1:0] JumpOP;
	
	// PC	
	wire [pc_size-1:0] PCin;
	wire [pc_size-1:0] PCout;
	wire [pc_size-1:0] Branch_addr;
	wire [pc_size-1:0] PC_add1; 
	
	// RegFile
	wire [4:0] Rs;
	wire [4:0] Rt;
	wire [4:0] Rd;
	wire [4:0] WR_out;
	wire [data_size-1:0] Rs_data;
	wire [data_size-1:0] Rt_data;	
	wire [data_size-1:0] Write_data;
	wire [4:0] WB_Write_addr;
	wire [4:0] R_out;
	
	// Sign_Extend
	wire [mem_size-1:0] imm_ins;
	wire [data_size-1:0] imm_Extend;	
	
	// FU	
	wire [4:0] EX_Rs;
    wire [4:0] EX_Rt;
    wire [4:0] M_WR_out;    
    wire [4:0] WB_WR_out;
	wire EN_Rs;
	wire EN_Rt;
	wire S_Rs;
	wire S_Rt;
	wire [data_size-1:0] Mux_Rs1;
	wire [data_size-1:0] Mux_Rs_data;
	wire [data_size-1:0] Mux_Rt1;
	wire [data_size-1:0] Mux_Rt_data;
	
	// HDU		
	wire [4:0] EX_WR_out;	
	wire [1:0] EX_JumpOP;
	wire PCWrite;
	wire IF_IDWrite;
	wire IF_Flush;
	wire ID_Flush;
	
	// IF_ID
	/*-------------------*/	
	wire [pc_size-1:0] IF_PC;
	wire [data_size-1:0] IF_ir;
	wire [pc_size-1:0] ID_PC;
	wire [data_size-1:0]ID_ir;
	
	// ID_EX
	/*-------------------*/	
	// EX
	wire Reg_imm;	
	// WB
	wire EX_MemtoReg;
	wire EX_RegWrite;
	// M
	wire EX_MemWrite;
	wire EX_Jal;	
	// EX
	wire EX_Reg_imm;
	// write your code in here
	wire EX_Jump;
	wire EX_Branch;
	wire EX_Jr;
	// pipe
	wire [pc_size-1:0] EX_PC;
	wire [3:0] EX_ALUOp;
	wire [4:0] EX_shamt;
	wire [data_size-1:0] EX_Rs_data;
	wire [data_size-1:0] EX_Rt_data;
	wire [data_size-1:0] EX_se_imm;
	
	// EX_M
	/*-------------------*/	
	// pipe
	wire [data_size-1:0] EX_ALU_result;	
	wire [pc_size-1:0] EX_PCplus8;
	wire [data_size-1:0] M_ALU_result;	
	wire [data_size-1:0] M_Rt_data;
	wire [pc_size-1:0] M_PCplus8;
	wire M_MemWrite;
	
	// M_WB
	/*-------------------*/
	// WB
    wire M_MemtoReg;	
    wire M_RegWrite;	
	// pipe
    wire [data_size-1:0] M_DM_Read_Data;
    wire [data_size-1:0] M_WD_out;
    // WB
	wire WB_MemtoReg;
	wire WB_RegWrite;
	// pipe
    wire [data_size-1:0] WB_DM_Read_Data;
    wire [data_size-1:0] WB_WD_out;    
	wire [data_size-1:0] WB_WD_out_Final;
	
	/*******************************************************************************/
	// connect wire
	
	// ALU
	assign opcode = ID_ir[31:26];
	assign shamt = ID_ir[10:6];		//shift
	assign funct = ID_ir[5:0];		
	// Register
	assign Rs = ID_ir[25:21];
	assign Rt = ID_ir[20:16];
	assign Rd = ID_ir[15:11];		
	assign imm_ins = ID_ir[15:0];		//immediate
	// IM
	assign IM_Address = PCout[17:2];	
	//DM
	assign DM_Address = M_ALU_result[17:2];	
	assign DM_enable = M_MemWrite;
	assign DM_Write_Data = M_Rt_data;		
	
	/*******************************************************************************/
	// CPU
	
	//---------------------- IF ----------------------//	
	PC#(pc_size) PC1( .clk(clk),
					  .rst(rst),
					  .PCWrite(PCWrite),
					  .PCin(PCin),
					  .PCout(PCout));
	
	Add#(pc_size) Add4_1( .In1(PCout),
						  .In2(18'd4),
						  .out(PC_add1));
	
	IF_ID IF_ID1( .clk(clk),
				  .rst(rst),
				  // input
				  .IF_IDWrite(IF_IDWrite),
			      .IF_Flush(IF_Flush),
			      .IF_PC(PC_add1),
			      .IF_ir(Instruction),
			      // output
			      .ID_PC(ID_PC),
			      .ID_ir(ID_ir));
				 
	//---------------------- ID ----------------------//		
	Controller control( .opcode(opcode),
						.funct(funct),
						.ALUOp(ALUOp),							
						.Branch(Branch),		
						.Jr(Jr),
						.Jump(Jump),
						.Jal(Jal),					
						.MemWrite(MemWrite),	
						.MemtoReg(MemtoReg),	 
						.RegWrite(RegWrite),	
						.RegDst(RegDst),											
						.Extend_h(Extend_h),
						.Reg_imm(Reg_imm));
						
	HDU HDU1( // input
			  .ID_Rs(Rs),
              .ID_Rt(Rt),
			  .EX_WR_out(EX_WR_out),
			  .EX_MemtoReg(EX_MemtoReg),
			  .EX_JumpOP(EX_JumpOP),
			  // output
			  .PCWrite(PCWrite),			 
			  .IF_IDWrite(IF_IDWrite),
			  .IF_Flush(IF_Flush),
			  .ID_Flush(ID_Flush));
			  
	Regfile register( .clk(clk),
					  .rst(rst),
					  .Read_addr_1(Rs),
					  .Read_addr_2(Rt),
					  .Read_data_1(Rs_data),
					  .Read_data_2(Rt_data),
					  .RegWrite(WB_RegWrite),
					  .Write_addr(WB_WR_out),
					  .Write_data(WB_WD_out_Final));
	
	Sign_Extend sign_ex( .in(imm_ins),
						 .out(imm_Extend));
						 
	//choose Rt or Rd to write
	Mux2to1#(5) mux_Rt_Rd( .select(RegDst),
						   .In1(Rt),
						   .In2(Rd),
						   .out(R_out));
	
	Mux2to1#(5) mux_WR( .select(Jal),
						.In1(R_out),
						.In2(5'd31),
						.out(WR_out));
	
	ID_EX ID_EX( .clk(clk),  
                 .rst(rst),
				 // input 
			     .ID_Flush(ID_Flush),
			     // WB
			     .ID_MemtoReg(MemtoReg),
			     .ID_RegWrite(RegWrite),
			     // M
			     .ID_MemWrite(MemWrite),
			     .ID_Jal(Jal),	
			     // EX
			     .ID_Reg_imm(Reg_imm),			  
			     .ID_Jump(Jump),
			     .ID_Branch(Branch),
			     .ID_Jr(Jr),			   
			     // pipe
			     .ID_PC(ID_PC),		
			     .ID_ALUOp(ALUOp),
			     .ID_shamt(shamt),
			     .ID_Rs_data(Rs_data),
			     .ID_Rt_data(Rt_data),
			     .ID_se_imm(imm_Extend),
			     .ID_WR_out(WR_out),
			     .ID_Rs(Rs),
			     .ID_Rt(Rt),
			     // output
			     // WB
			     .EX_MemtoReg(EX_MemtoReg),
			     .EX_RegWrite(EX_RegWrite),
			     // M
			     .EX_MemWrite(EX_MemWrite),
			     .EX_Jal(EX_Jal),	
			     // EX
			     .EX_Reg_imm(EX_Reg_imm),			     
			     .EX_Jump(EX_Jump),
			     .EX_Branch(EX_Branch),
			     .EX_Jr(EX_Jr),
			     // pipe
			     .EX_PC(EX_PC),
			     .EX_ALUOp(EX_ALUOp),
			     .EX_shamt(EX_shamt),
			     .EX_Rs_data(EX_Rs_data),
			     .EX_Rt_data(EX_Rt_data),
			     .EX_se_imm(EX_se_imm),
			     .EX_WR_out(EX_WR_out),
			     .EX_Rs(EX_Rs),
			     .EX_Rt(EX_Rt));
	
	//---------------------- EX ----------------------//	
	// Branch Address
	Add EX_Mux( .In1(EX_PC),
				.In2({EX_se_imm[15:0],2'b0}),
				.out(Branch_addr));
		
	Jump_Ctrl Jump_Control( .Zero(EX_Zero),
							.Branch(EX_Branch),
							.Jump(EX_Jump),
							.Jump_Addr(EX_Jr),
							.JumpOP(EX_JumpOP));
							
	//select next PC source (PC+4, or Branch addr, or jr's $Rs, or JumpAddr)
	Mux4to1#(pc_size) Mux4( .select(EX_JumpOP),
							.In1(PC_add1),
							.In2(Branch_addr),
							.In3(Mux_Rs_data[pc_size-1:0]),	
							.In4({EX_se_imm[15:0],2'b0}),
							.out(PCin));
	//------ Rs Fowarding ------//
	// S_Rs==1,foward data is from WB,else foward data is from MEM
	Mux2to1#(data_size) WB_Rs( .select(S_Rs),
							   .In1(M_WD_out),	
							   .In2(WB_WD_out_Final),	
							   .out(Mux_Rs1));
	
	// EN_Rs==1,data is from foward data,else data is from origin data
	Mux2to1#(data_size) ALU_Rs( .select(EN_Rs),		
								.In1(EX_Rs_data),
								.In2(Mux_Rs1),
								.out(Mux_Rs_data));
	//------ Rt Fowarding ------//
	// S_Rt==1,foward data is from WB,else foward data is from MEM
	Mux2to1#(data_size) WB_Rt( .select(S_Rt),
							   .In1(M_WD_out),	
							   .In2(WB_WD_out_Final),	
							   .out(Mux_Rt1));
							   
	// EN_Rt==1,data is from foward data,else data is from origin data						   
	Mux2to1#(data_size) ALU_Rt1( .select(EN_Rt),
								 .In1(EX_Rt_data),
								 .In2(Mux_Rt1),
								 .out(Mux_Rt_data));
								 
	// ALU src2 - select Rt or imm
	Mux2to1#(data_size) ALU_Rt2( .select(EX_Reg_imm),
								 .In1(Mux_Rt_data),
								 .In2(EX_se_imm),
								 .out(src));
	
	ALU ALU1( .ALUOp(EX_ALUOp),
			  .src1(Mux_Rs_data),
			  .src2(src),
			  .shamt(EX_shamt),
			  .ALU_result(EX_ALU_result),
			  .Zero(EX_Zero));	
				
	// PC+4 used for Jal
	Add EX_4( .In1(EX_PC),
			  .In2(18'd4),
			  .out(EX_PCplus8));
			  
	FU FU1( // input
			.EX_Rs(EX_Rs),
			.EX_Rt(EX_Rt),
			.M_RegWrite(M_RegWrite),
			.M_WR_out(M_WR_out),
			.WB_RegWrite(WB_RegWrite),
			.WB_WR_out(WB_WR_out),
			// output
			.EN_Rs(EN_Rs),
			.EN_Rt(EN_Rt),
			.S_Rs(S_Rs),
			.S_Rt(S_Rt));
	
	EX_M EX_M1( .clk(clk),
				.rst(rst),
				// input 
				// WB
				.EX_MemtoReg(EX_MemtoReg),
				.EX_RegWrite(EX_RegWrite),
				// M
				.EX_MemWrite(EX_MemWrite),
				.EX_Jal(EX_Jal),	
				// pipe
				.EX_ALU_result(EX_ALU_result),
				.EX_Rt_data(Mux_Rt_data),		
				.EX_PCplus8(EX_PCplus8),
				.EX_WR_out(EX_WR_out),
				// output
				// WB
				.M_MemtoReg(M_MemtoReg),
				.M_RegWrite(M_RegWrite),
				// M
				.M_MemWrite(M_MemWrite),
				.M_Jal(M_Jal),	
				// pipe
				.M_ALU_result(M_ALU_result),
				.M_Rt_data(M_Rt_data),
				.M_PCplus8(M_PCplus8),
				.M_WR_out(M_WR_out));
	
	//---------------------- MEM ----------------------//
	// sw or sh for DM_Write_data
	Mux2to1#(data_size) DM_WD( .select(Extend_h && MemWrite),	
							   .In1(M_Rt_data),
							   .In2({{16{M_Rt_data[15]}},M_Rt_data[15:0]}),
							   .out(M_Rt_data));
							   
	// lw or lh for DM_Read_data
	Mux2to1#(data_size) DM_RD( .select(Extend_h && MemtoReg),
							   .In1(DM_Read_Data),
							   .In2({{16{DM_Read_Data[15]}},DM_Read_Data[15:0]}),
							   .out(DM_Read_Data));
							   
	// select Jal or ALU result
	Mux2to1#(data_size) Mux_PC_Rt( .select(M_Jal),
								   .In1(M_ALU_result),
								   .In2({14'b0,M_PCplus8}),
								   .out(M_WD_out));
	
	M_WB M_WB1( .clk(clk),
				.rst(rst),
				// input 
				// WB
				.M_MemtoReg(M_MemtoReg),
				.M_RegWrite(M_RegWrite),
				// pipe
				.M_DM_Read_Data(DM_Read_Data),	
				.M_WD_out(M_WD_out),	
				.M_WR_out(M_WR_out),	
				// output
				// WB
				.WB_MemtoReg(WB_MemtoReg),	
				.WB_RegWrite(WB_RegWrite),	//write to register
				// pipe
				.WB_DM_Read_Data(WB_DM_Read_Data),
				.WB_WD_out(WB_WD_out),
				.WB_WR_out(WB_WR_out));
	
	//---------------------- WB ----------------------//
	Mux2to1#(data_size) Mux_WB( .select(WB_MemtoReg),
								.In1(WB_WD_out),
								.In2(WB_DM_Read_Data),
								.out(WB_WD_out_Final));	
	
	
endmodule







