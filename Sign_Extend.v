// Extend sign from 16 bits to 32 bits	

module Sign_Extend( in,
					out);
					
	input [15:0] in;
	output [31:0] out;
	
	//repeat in[15] 16 times , and connect with original in		
	assign out={{16{in[15]}},in};	
					
endmodule