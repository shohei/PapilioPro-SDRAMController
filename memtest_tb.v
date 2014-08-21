`timescale 1ns / 1ps
module memtest_tb;

	// Inputs
	reg CLK;
	reg RST;

	// Outputs
	wire [7:0] nSEG;
	wire [3:0] nAN;
	wire TXD;
	wire [7:0] LED;
	wire [11:0] SDRAM_ADDR;
	wire [1:0] SDRAM_BA;
	wire [1:0] SDRAM_DQM;
	wire SDRAM_nWE;
	wire SDRAM_nCAS;
	wire SDRAM_nRAS;
	wire SDRAM_nCS;
	wire SDRAM_CLK;
	wire SDRAM_CKE;

	// Bidirs
	wire [15:0] SDRAM_DATA;

	// Instantiate the Unit Under Test (UUT)
	MEMTEST uut (
		.CLK(CLK), 
		.RST(RST), 
		.nSEG(nSEG), 
		.nAN(nAN), 
		.TXD(TXD), 
		.LED(LED), 
		.SDRAM_ADDR(SDRAM_ADDR), 
		.SDRAM_BA(SDRAM_BA), 
		.SDRAM_DATA(SDRAM_DATA), 
		.SDRAM_DQM(SDRAM_DQM), 
		.SDRAM_nWE(SDRAM_nWE), 
		.SDRAM_nCAS(SDRAM_nCAS), 
		.SDRAM_nRAS(SDRAM_nRAS), 
		.SDRAM_nCS(SDRAM_nCS), 
		.SDRAM_CLK(SDRAM_CLK), 
		.SDRAM_CKE(SDRAM_CKE)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		#1;
		RST = 1;
		#1;
		RST = 0;

		// Wait 100 ns for global reset to finish
		//#100;
        
	        //wait for 200us
		#10000;
		//wait for 5us
		#250;
		// Add stimulus here



	end

	always #(31.25/2) begin
		CLK = !CLK;
	end
      
