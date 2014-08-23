`timescale 1ns / 1ps

module memif_tb;

	// Inputs
	reg CLK;
	reg RST;
	reg [31:0] IO_Address;
	reg [31:0] IO_Write_Data;
	reg [3:0] IO_Byte_Enable;
	reg IO_Addr_Strobe;
	reg IO_Read_Strobe;
	reg WRMEM;
	reg WRREG;
	reg [20:0] DMEMADDR;
	reg [20:0] CMEMADDR;
	reg [15:0] CMEMDOUT;
	reg CMEMnWE_asrt;
	reg CMEMnWE_deas;

	// Outputs
	wire [23:1] MEMADDR;
	//wire MEMnOE;
	//wire MEMnWE;
	//wire MEMnUB;
	//wire MEMnLB;
	wire [31:0] RDATA0;
	wire [31:0] RDATA1;
	wire MEMIORDY;
	wire [1:0] MODE;
	wire SDRAM_CLK;
	wire [11:0] SDRAM_ADDR;
	wire [1:0] SDRAM_DQM;
	wire [1:0] SDRAM_BA;
	wire SDRAM_nWE;
	wire SDRAM_nCAS;
	wire SDRAM_nRAS;
	wire SDRAM_nCS;

	// Bidirs
	wire [15:0] SDRAM_DATA;
	reg CLK_50_SHIFT;
	reg DebugCLK;

	//assign SDRAM_CLK = !CLK;

	// Instantiate the Unit Under Test (UUT)
	MEMIF uut (
		.CLK(CLK), 
		.RST(RST), 
		.CLK_50_SHIFT_SDRAM(!CLK),
		.DebugCLK(DebugCLK),
		//.MEMADDR(MEMADDR), 
		//.MEMnOE(MEMnOE), 
		//.MEMnWE(MEMnWE), 
		//.MEMnUB(MEMnUB), 
		//.MEMnLB(MEMnLB), 
		.IO_Address(IO_Address), 
		.IO_Write_Data(IO_Write_Data), 
		.IO_Byte_Enable(IO_Byte_Enable), 
		.IO_Addr_Strobe(IO_Addr_Strobe), 
		.IO_Read_Strobe(IO_Read_Strobe), 
		.WRMEM(WRMEM), 
		.WRREG(WRREG), 
		.RDATA0(RDATA0), 
		.RDATA1(RDATA1), 
		.MEMIORDY(MEMIORDY), 
		.DMEMADDR(DMEMADDR), 
		.CMEMADDR(CMEMADDR), 
		.CMEMDOUT(CMEMDOUT), 
		.CMEMnWE_asrt(CMEMnWE_asrt), 
		.CMEMnWE_deas(CMEMnWE_deas), 
		.MODE(MODE), 
		.SDRAM_CLK(SDRAM_CLK), 
		.SDRAM_ADDR(SDRAM_ADDR), 
		.SDRAM_DATA(SDRAM_DATA), 
		.SDRAM_DQM(SDRAM_DQM), 
		.SDRAM_BA(SDRAM_BA), 
		.SDRAM_nWE(SDRAM_nWE), 
		.SDRAM_nCAS(SDRAM_nCAS), 
		.SDRAM_nRAS(SDRAM_nRAS), 
		.SDRAM_nCS(SDRAM_nCS)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		IO_Address = 0;
		IO_Write_Data = 0;
		IO_Byte_Enable = 0;
		IO_Addr_Strobe = 0;
		IO_Read_Strobe = 0;
		WRMEM = 0;
		WRREG = 0;
		DMEMADDR = 0;
		CMEMADDR = 0;
		CMEMDOUT = 0;
		CMEMnWE_asrt = 0;
		CMEMnWE_deas = 0;

		#10
		RST=1;
		#20;
		RST=0;
		// Wait 100 ns for global reset to finish
		//#100;
		//wait for 200us (20us*10*1000clk)
		//#200_000;
		//wait for 100us 
		#100_000;
		//wait for 50us 
		#50_000;
		//MCS mode configuration
		WRREG = 1'b1;
		IO_Byte_Enable[3:0] = 4'b0001;
		IO_Write_Data[1:0] = 2'b10;
		#20;
		WRREG = 1'b0;
		IO_Byte_Enable[3:0] = 4'b0000;
		IO_Write_Data[31:0] = 32'b0;
		//wait for 5us
		#5_000;
		//Write something
       		//IO_Write_Data[31:0] = 32'hff002244; 
       		IO_Write_Data[31:0] = 32'h11112222; 
		WRMEM = 1'b1;
		IO_Addr_Strobe = 1'b1;
		//IO_Address[31:0] = 32'hC0000001;
		IO_Address[31:0] = 32'hC0012345;
		IO_Byte_Enable[3:0] = 4'b1111;	
		#20 // 1 clock
		WRMEM = 1'b0;
		IO_Addr_Strobe = 1'b0;
		// Add stimulus here
		//wait for 200ns
		//#400;
		//Write something
		#200;
       		//IO_Write_Data[31:0] = 32'hff002244; 
       		IO_Write_Data[31:0] = 32'h33334444; 
		WRMEM = 1'b1;
		IO_Addr_Strobe = 1'b1;
		//IO_Address[31:0] = 32'hC0000001;
		IO_Address[31:0] = 32'hC0012345;
		IO_Byte_Enable[3:0] = 4'b1111;	
		#20 // 1 clock
		WRMEM = 1'b0;
		IO_Addr_Strobe = 1'b0;
		#200;
		//Read something
		IO_Addr_Strobe = 1'b1;
		IO_Read_Strobe = 1'b1;
		//IO_Address[31:0] = 32'hC0000001;
		IO_Address[31:0] = 32'hC0012345;
		IO_Byte_Enable[3:0] = 4'b1111;	
		#20 // 1 clock
		IO_Addr_Strobe = 1'b0;
		IO_Read_Strobe = 1'b0;


	end

	always #(20/2) begin
		CLK = !CLK;
	end


	initial
	begin
		CLK_50_SHIFT <= 1'b0;
		#(10-20/6);
		forever
		begin
			CLK_50_SHIFT <= 1'b1;
			#(20/2);
			CLK_50_SHIFT <= 1'b0;
			#(20/2);
		end
	end

	initial
	begin
		DebugCLK <= 1'b0;
		#(10-20/4);
		forever
		begin
			DebugCLK <= 1'b1;
			#(20/2);
			DebugCLK <= 1'b0;
			#(20/2);
		end
	end

      
endmodule

