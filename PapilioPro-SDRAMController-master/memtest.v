module MEMTEST(
    input   CLK, RST,
    output  [7:0]   nSEG,
    output  [3:0]   nAN,
    //output  [23:1]  MEMADDR,
    //inout   [15:0]  MEMDQ,
    //output          MEMnOE, MEMnWE, MEMnCS, MEMnUB, MEMnLB,
    //output          MEMnADV, MEMCLK, MEMCRE,
    output          TXD,
    output  [7:0]   LED,

    //modify
    //output [11:0] SDRAM_ADDR,
    output [12:0] SDRAM_ADDR,
    output [1:0] SDRAM_BA,
    inout [15:0] SDRAM_DATA,
    output [1:0] SDRAM_DQM,     
    output SDRAM_nWE,     
    output SDRAM_nCAS,     
    output SDRAM_nRAS,     
    output SDRAM_nCS,     
    output SDRAM_CLK,    //forward phase, for example 60deg(-60deg)
    output SDRAM_CKE
    //output SDRAM_ADDR12
);

//assign SDRAM_CLK = !CLK_50;

wire CLK_50;
wire CLK_50_F;
wire CLK_50_B;
wire CLK_90_F;
wire CLK_90_B;
wire CLK_60;
wire CLK_70;
wire CLK_80;
wire CLK_90;
wire CLK_100;
wire CLK_110;
wire CLK_120;
wire CLK_130;
wire CLK_140;
//assign SDRAM_ADDR12 = 1'b0;

/* 7セグメントLED出力の固定 */
assign nSEG = 8'hff;
assign nAN  = 4'hf;

/* 端子の固定 */
//assign MEMnCS   = 1'b0;
//assign MEMnADV  = 1'b0;
//assign MEMCLK   = 1'b0;
//assign MEMCRE   = 1'b0;
assign LED[7:2] = 6'b0;

/* 内部信号宣言 */
wire [31:0] IO_Address, IO_Write_Data, IO_Read_Data;
wire [3:0]  IO_Byte_Enable;
wire        IO_Addr_Strobe, IO_Read_Strobe, IO_Write_Strobe;
wire        IO_Ready;
wire [7:0]  WR;
wire [31:0] RDATA0, RDATA1, RDATA2, RDATA3,
            RDATA4, RDATA5, RDATA6, RDATA7;
wire        MEMIORDY;

/* MODE信号を単体LEDに表示 */
wire [1:0]  MODE;
assign LED[1:0] = MODE;

/* バンク番号の設定 */
parameter SDRAM=3'h0, MEMMODE=3'h1, LEDBANK=3'h2, PS2BANK=3'h3,
          VGABANK=3'h4,   GRAPH=3'h5,  CAMPIC=3'h6, CAMCTRL=3'h7;

/* 各モジュールの接続 */
mcs mcs_0 (
    .Clk            (CLK_50),
    .Reset          (RST),
    .IO_Addr_Strobe (IO_Addr_Strobe),
    .IO_Read_Strobe (IO_Read_Strobe),
    .IO_Write_Strobe(IO_Write_Strobe),
    .IO_Address     (IO_Address),
    .IO_Byte_Enable (IO_Byte_Enable),
    .IO_Write_Data  (IO_Write_Data),
    .IO_Read_Data   (IO_Read_Data),
    .IO_Ready       (IO_Ready),
    .UART_Tx        (TXD)
);

BUSIF BUSIF(
    .CLK            (CLK_50),
    .RST            (RST),
    .IO_Address     (IO_Address),
    .IO_Read_Data   (IO_Read_Data),
    .IO_Addr_Strobe (IO_Addr_Strobe),
    .IO_Read_Strobe (IO_Read_Strobe),
    .IO_Write_Strobe(IO_Write_Strobe),
    .IO_Ready       (IO_Ready),
    .WR             (WR),
    .RDATA0         (RDATA0),
    .RDATA1         (RDATA1),
    .RDATA2(32'b0), .RDATA3(32'b0), 
    .RDATA4(32'b0), .RDATA5(32'b0),
    .RDATA6(32'b0), .RDATA7(32'b0),
    .MEMIORDY       (MEMIORDY)
);

MEMIF MEMIF(
    .CLK            (CLK_50),
    .CLK_50_SHIFT_SDRAM(~CLK_50),
    //.CLK_50_SHIFT_SDRAM(CLK_50_F),
    //.CLK_50_SHIFT_SDRAM(CLK_50_B),
    //.CLK_50_SHIFT_SDRAM(CLK_90_F),
    //.CLK_50_SHIFT_SDRAM(CLK_90_B),
    .DebugCLK(CLK_90_F),
    .RST            (RST),
    //.MEMADDR        (MEMADDR),
    .SDRAM_ADDR        (SDRAM_ADDR),
    .SDRAM_BA(SDRAM_BA),
    //.MEMDQ          (MEMDQ),
    .SDRAM_DATA   (SDRAM_DATA),
    //.MEMnOE         (MEMnOE),
    //.MEMnWE         (MEMnWE),
    //.MEMnUB         (MEMnUB),
    //.MEMnLB         (MEMnLB),
    .SDRAM_CLK(SDRAM_CLK),
    .SDRAM_DQM(SDRAM_DQM),
    .SDRAM_nWE(SDRAM_nWE),     
    .SDRAM_nCAS(SDRAM_nCAS),     
    .SDRAM_nRAS(SDRAM_nRAS),     
    .SDRAM_nCS(SDRAM_nCS),     
    .SDRAM_CKE(SDRAM_CKE),
    .IO_Address     (IO_Address),
    .IO_Write_Data  (IO_Write_Data),
    .IO_Byte_Enable (IO_Byte_Enable),
    .IO_Addr_Strobe (IO_Addr_Strobe), 
    .IO_Read_Strobe (IO_Read_Strobe),
    .WRMEM          (WR[SDRAM]),
    .WRREG          (WR[MEMMODE]),
    .RDATA0         (RDATA0),
    .RDATA1         (RDATA1),
    .MEMIORDY       (MEMIORDY),
    .DMEMADDR       (21'b0),
    .CMEMADDR       (21'b0),
    .CMEMDOUT       (16'b0),
    .CMEMnWE_asrt   (1'b0),
    .CMEMnWE_deas   (1'b0),
    .MODE           (MODE)
);

/*
SDRAM_Controller hamster(
    .clk (CLK_80),
    .reset(RST),
    .SDRAM_ADDR        (SDRAM_ADDR),
    .SDRAM_BA(SDRAM_BA),
    .SDRAM_DATA   (SDRAM_DATA),
    .SDRAM_CLK(SDRAM_CLK),
    .SDRAM_DQM(SDRAM_DQM),
    .SDRAM_WE(SDRAM_nWE),     
    .SDRAM_CAS(SDRAM_nCAS),     
    .SDRAM_RAS(SDRAM_nRAS),     
    .SDRAM_CS(SDRAM_nCS),     
    .SDRAM_CKE(SDRAM_CKE),
    .IO_Address     (IO_Address),
    .IO_Write_Data  (IO_Write_Data),
    .IO_Byte_Enable (IO_Byte_Enable),
    .IO_Addr_Strobe (IO_Addr_Strobe), 
    .IO_Read_Strobe (IO_Read_Strobe),
    .WRMEM          (WR[SDRAM]),
    .WRREG          (WR[MEMMODE]),
    .RDATA0         (RDATA0),
    .RDATA1         (RDATA1),
    .MEMIORDY       (MEMIORDY),
    .DMEMADDR       (21'b0),
    .CMEMADDR       (21'b0),
    .CMEMDOUT       (16'b0),
    .CMEMnWE_asrt   (1'b0),
    .CMEMnWE_deas   (1'b0),
    .MODE           (MODE)
);
*/
dcm32to50 dcm_inst
   (// Clock in ports
    .CLK_IN1(CLK),    
    // Clock out ports
    .CLK_OUT1(CLK_50),   //clock 50MHz 
    .CLK_OUT2(CLK_60),    //clock 50MHz, 60 deg forward
    .CLK_OUT3(CLK_70),
    .CLK_OUT4(CLK_80),
    .CLK_OUT5(CLK_90),
    .CLK_OUT6(CLK_100)
   );  

endmodule
