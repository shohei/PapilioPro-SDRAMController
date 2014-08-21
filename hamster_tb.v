`timescale 1ns / 1ps
module hamster_tb;

	// Inputs
	reg clk;
	reg RST;
	reg [31:0] IO_Address;
	reg [3:0] IO_Byte_Enable;
	reg [31:0] IO_Write_Data;
	reg IO_Read_Strobe;
	reg IO_Addr_Strobe;
	reg WRMEM;
	reg WRREG;
	reg [20:0] DMEMADDR;
	reg [20:0] CMEMADDR;
	reg [15:0] CMEMDOUT;
	reg CMEMnWE_asrt;
	reg CMEMnWE_deas;

	// Outputs
	wire cmd_ready;
	wire SDRAM_CLK;
	wire SDRAM_CKE;
	wire SDRAM_CS;
	wire SDRAM_RAS;
	wire SDRAM_CAS;
	wire SDRAM_WE;
	wire [1:0] SDRAM_DQM;
	wire [12:0] SDRAM_ADDR;
	wire [1:0] SDRAM_BA;
	wire [31:0] RDATA0;
	wire [31:0] RDATA1;
	wire MEMIORDY;
	wire [1:0] MODE;

	// Bidirs
	wire [15:0] SDRAM_DATA;

	// Instantiate the Unit Under Test (UUT)
	SDRAM_Controller uut (
		.clk(clk), 
		.reset(RST), 
		.IO_Address(IO_Address), 
		.IO_Byte_Enable(IO_Byte_Enable), 
		.IO_Write_Data(IO_Write_Data), 
		.IO_Addr_Strobe(IO_Addr_Strobe), 
		.IO_Read_Strobe(IO_Read_Strobe), 
		//.cmd_ready(cmd_ready), 
		.SDRAM_CLK(SDRAM_CLK), 
		.SDRAM_CKE(SDRAM_CKE), 
		.SDRAM_CS(SDRAM_CS), 
		.SDRAM_RAS(SDRAM_RAS), 
		.SDRAM_CAS(SDRAM_CAS), 
		.SDRAM_WE(SDRAM_WE), 
		.SDRAM_DQM(SDRAM_DQM), 
		.SDRAM_ADDR(SDRAM_ADDR), 
		.SDRAM_BA(SDRAM_BA), 
		.SDRAM_DATA(SDRAM_DATA), 
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
		.MODE(MODE)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		RST = 0;
		IO_Addr_Strobe= 0;
		WRMEM = 0;
		IO_Read_Strobe= 0;
		IO_Byte_Enable = 0;
		IO_Write_Data = 0;
		#10;
		RST=1;
		#10;
		RST=0;

		// Wait 100 ns for global reset to finish
		#100000;//1000*100 : 100us
		#5000;//5us
		//write something
		#5;
		IO_Addr_Strobe = 1'b1;
           	WRMEM = 1'b1;
           	IO_Address = 32'hc0_00_00_00; 
           	IO_Byte_Enable = 4'b1111;
           	IO_Write_Data = 32'h11223344;
 		#20;
		IO_Addr_Strobe = 1'b0;
           	WRMEM = 1'b0;
           	IO_Byte_Enable = 4'b0000;
		// Add stimulus here
		#90;
		IO_Addr_Strobe = 1'b1;
           	WRMEM = 1'b1;
           	IO_Address = 32'hc0_00_00_00_01; 
           	IO_Byte_Enable = 4'b1111;
           	IO_Write_Data = 32'h55667788;
 		#20;
		IO_Addr_Strobe = 1'b0;
           	WRMEM = 1'b0;
           	IO_Byte_Enable = 4'b0000;

		#90;
		//read something
		IO_Addr_Strobe = 1'b1;
		IO_Read_Strobe = 1'b1;
           	IO_Address = 32'hc0_00_00_01; 
		#10;
		IO_Addr_Strobe = 1'b0;
		IO_Read_Strobe = 1'b0;
	end


	always #(10/2) begin
		clk = !clk;
	end

      
      
endmodule

