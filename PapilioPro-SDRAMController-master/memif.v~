module MEMIF(
    input   CLK, RST,
    /* I/Oバス */
    input       [31:0]  IO_Address, IO_Write_Data,
    input       [3:0]   IO_Byte_Enable,
    input               IO_Addr_Strobe, IO_Read_Strobe,
    /* バス・インターフェース */
    input               WRMEM,  WRREG,
    output      [31:0]  RDATA0, RDATA1,
    output              MEMIORDY,
    /* グラフィック表示回路 */
    //input       [23:1]  DMEMADDR,
    input       [20:0]  DMEMADDR,
    /* キャプチャ回路 */
    //input       [23:1]  CMEMADDR,//22bit
    input       [20:0]  CMEMADDR,//22bit
    input       [15:0]  CMEMDOUT,
    input               CMEMnWE_asrt, CMEMnWE_deas,
    /* MODE信号のLED表示用 */
    output  reg [1:0]   MODE,
    ///* SDRAM */
    input CLK_50_SHIFT_SDRAM,
    input DebugCLK,
    output SDRAM_CLK,
    output reg [11:0] SDRAM_ADDR,
    inout [15:0] SDRAM_DATA,
    output reg [1:0] SDRAM_DQM,     
    output reg [1:0] SDRAM_BA,
    output SDRAM_nWE,     
    output SDRAM_nCAS,     
    output SDRAM_nRAS,     
    output SDRAM_nCS,
    output SDRAM_CKE
);

ODDR2 #(
  .DDR_ALIGNMENT("NONE"),
  .INIT(1'b0),
  .SRTYPE("SYNC")
) ODDR_inst (
  .Q(SDRAM_CLK),
  //.C0(CLK),
  //.C1(!CLK),
  .C0(~CLK_50_SHIFT_SDRAM),
  .C1(CLK_50_SHIFT_SDRAM),
  .CE(1'b1),
  .D0(1'b0),
  .D1(1'b1),
  .R(1'b0),
  .S(1'b0)
);

wire [15:0] SDRAM_DIN;
wire [15:0] writemode_arr = {16{writemode}};
genvar i;
generate 
    for(i=0;i<16;i=i+1)
    begin
    IOBUF #(
        .DRIVE(12),
        .IOSTANDARD("LVTTL"),
        .SLEW("FAST")
    )
    IOBUF_inst(
        //.O (SDRAM_DIN[i]),
        //.IO (SDRAM_DATA[i]),
        .O (SDRAM_DIN[i]),
        .IO (SDRAM_DATA[i]),
        .I (wrdata[i]),
        .T (~writemode_arr[i])
    );
    end
endgenerate;

/* SDRAM 制御信号（宣言部分） */
reg    nCS, nRAS, nCAS, nWE;
assign {SDRAM_nCS, SDRAM_nRAS, SDRAM_nCAS, SDRAM_nWE}
                             = {nCS, nRAS, nCAS, nWE};

reg CKE;
assign SDRAM_CKE = CKE;

always @(posedge CLK, posedge RST) begin
	if(RST)
		CKE <= 1'b0;
	else if(cur==ICKE)
		CKE <= 1'b1;
end

/* READ/WRITE制御ステートマシン宣言部分 5bit=32 */
parameter IWAIT=5'd0, IPALL=5'd1, IDLY1=5'd2, IRFSH=5'd3,
        IDLY2=5'd4, IDLY3=5'd5, IMODE=5'd6, 
        RACT=5'd7, RDLY1=5'd8, RDA=5'd9, RDLY2=5'd10, RDLY3=5'd11, 
        HALT=5'd12, WACT=5'd13, WDLY1=5'd14, WRA=5'd15, WDLY2=5'd16,
        FRFSH=5'd17, FDLY=5'd18,
	RDLY4=5'd19, RDEND=5'd20, 
	WDLY3=5'd21,WDLY4=5'd22,
	WREND=5'd23,
	IWAIT2=5'd24,ICKE=5'd25,WRA2=5'd26,
	WDLY5=5'd27,WDLY6=5'd28,RDLY5=5'd29,
	WDLYX=5'd30;

reg [4:0]   cur, nxt;

/* 初期化用200μsカウンタ */
parameter MAX200=14'd10000;//10,000CLK=20ns*10,000=200(us)
parameter MAX100=13'd5000;//5,000CLK
parameter MAX75=12'd3750;//5,000CLK
parameter MAX50=12'd2500;  //2,500CLK=50(us)

reg [13:0]  i200cnt;
reg [12:0]  i100cnt;
reg [11:0]  i75cnt;
reg [11:0]  i50cnt;

wire i200cntup = (i200cnt==MAX200-1);
wire i100cntup = (i100cnt==MAX100-1);
wire i75cntup = (i75cnt==MAX75-1);
wire i50cntup = (i50cnt==MAX50-1);

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        //i200cnt <= 14'h0;
        i50cnt <= 12'h0;
    else if(cur==ICKE)
	i50cnt <= 12'h0;
    else
        i50cnt <= i50cnt + 12'h1;
end

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        //i200cnt <= 14'h0;
        i100cnt <= 13'h0;
    else
        i100cnt <= i100cnt + 13'h1;
end

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        i75cnt <= 12'h0;
    else
        i75cnt <= i75cnt + 12'h1;
end

/* 初期化用8回カウンタ */
reg [2:0] cnt3;

wire cnt3max = (cnt3==3'h7);

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        cnt3 <= 3'h0;
    else if ( cur==IWAIT )
        cnt3 <= 3'h0;
    else if ( cur==IDLY3 )
        cnt3 <= cnt3 + 3'h1;
end

/* リフレッシュカウンタ */
/* 64ms/4096/20ns=781.25、マージンをとって770にした */
reg [9:0]   refcnt;
//parameter   REFMAX=10'd770;
parameter   REFMAX=10'd750;

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        refcnt <= 10'h0;
    else if ( cur==FRFSH )
        refcnt <= 10'h0;
    else
        refcnt <= refcnt + 10'h1;
end

/* READ/WRITE制御ステートマシン */
always @( posedge CLK, posedge RST ) begin
    if ( RST )
        cur <= IWAIT;
    else
        cur <= nxt;
end

always @* begin
    case ( cur )
        IWAIT:  if ( i75cntup )
                    nxt <= ICKE;
                else
                    nxt <= IWAIT;
	ICKE: nxt <= IWAIT2;
        IWAIT2:  if ( i50cntup )
                    nxt <= IPALL;
                else
                    nxt <= IWAIT2;
        IPALL:  nxt <= IDLY1;
        IDLY1:  nxt <= IRFSH;
        IRFSH:  nxt <= IDLY2;
        IDLY2:  nxt <= IDLY3;
        IDLY3:  if ( cnt3max )
                    nxt <= IMODE;
                else
                    nxt <= IDLY1;
        IMODE:  nxt <= HALT;
        HALT:   if ( refcnt>=REFMAX )
                    nxt <= FRFSH;
                //else if ( writemode )
		else if ( WRMEM || writeWait==1'b1) 
                    nxt <= WACT;
		else if ( RDMEM || readWait==1'b1) 
                    nxt <= RACT;
                else
                    nxt <= HALT;
        /* WRITE動作 */
        WACT:   nxt <= WDLY1;
        WDLY1:  nxt <= WRA;
        WRA:    nxt <= WRA2;
        WRA2:    nxt <= WDLY2;
	WDLY2: nxt <= WDLY3;
	WDLY3: nxt <= WDLY4;
	WDLY4: nxt <= WREND;
	WREND: nxt <= HALT;

        /* READ動作 */
        RACT:   nxt <= RDLY1;
        RDLY1:  nxt <= RDA;
        RDA:    nxt <= RDLY2;
        RDLY2:  nxt <= RDLY3;
        RDLY3:  nxt <= RDLY4;
        RDLY4:  nxt <= RDEND;
        RDEND:  nxt <= HALT;

        /* リフレッシュ */
        FRFSH:  nxt <= FDLY;
        FDLY:   nxt <= HALT;
        default:nxt <= HALT;
    endcase
end

/* SDRAM 制御信号 */
always @* begin
    if ( cur==IMODE )
        {nCS, nRAS, nCAS, nWE} <= 4'b0000;  /* MRS  */
    else if ( cur==RACT || cur==WACT )
        {nCS, nRAS, nCAS, nWE} <= 4'b0011;  /* ACT  */
    else if ( cur==IPALL )
        {nCS, nRAS, nCAS, nWE} <= 4'b0010;  /* PALL */
    else if ( cur==RDA )
        {nCS, nRAS, nCAS, nWE} <= 4'b0101;  /* RDA  */
    else if ( cur==RDLY2)
        {nCS, nRAS, nCAS, nWE} <= 4'b0101;  /* RDA  */
    else if ( cur==WRA )
        {nCS, nRAS, nCAS, nWE} <= 4'b0100;  /* WRA  */
    else if ( cur==WRA2 )
        {nCS, nRAS, nCAS, nWE} <= 4'b0100;  /* WRA  */
    else if ( cur==IRFSH | cur==FRFSH )
        {nCS, nRAS, nCAS, nWE} <= 4'b0001;  /* REF  */
    else if ( cur==ICKE)
        {nCS, nRAS, nCAS, nWE} <= 4'b0111;  /* NOP */
    else if ( cur==IDLY1)
        {nCS, nRAS, nCAS, nWE} <= 4'b0111;  /* NOP */
    else
        {nCS, nRAS, nCAS, nWE} <= 4'b0111;//NOP
end

assign MEMIORDY = (cur==RDEND|| cur==WREND ) ? 1'b1: 1'b0;//TODO: is this MEMIORDY?

/* メモリアクセス・モード設定レジスタ */
parameter DISPMODE=2'b00, CAPTMODE=2'b01, MCSMODE=2'b10;

always @( posedge CLK ) begin
    if ( RST )
        MODE <= 2'h0;
    else if ( WRREG & IO_Byte_Enable[0] )
        MODE <= IO_Write_Data[1:0];
end

assign RDATA1 = {30'b0, MODE};

/* メモリ読み出し信号 */
wire RDMEM = (IO_Address[31:24]==8'hc0) & IO_Addr_Strobe & IO_Read_Strobe;
reg readWait;
always @(posedge CLK) begin
	if(RST)
		readWait <= 1'b0;
	else if(RDMEM)
		readWait <= 1'b1;
	else if(cur==RACT)
		readWait <= 1'b0;
end
reg writeWait;
always @(posedge CLK) begin
	if(RST)
		writeWait <= 1'b0;
	else if (WRMEM)
		writeWait <= 1'b1;
	else if (cur==WACT)
		writeWait <= 1'b0;
end

/* MCSモード時のメモリ信号 */
//reg  [23:1]  MMEMADDR;
reg  [21:0]  MMEMADDR; //21bit address from MCS or other buses
reg          MMEMnOE, MMEMnWE, MMEMnUB, MMEMnLB;

reg         MEMnOE, MEMnWE, MEMnUB, MEMnLB;

/* メモリ信号切り替え */
always @* begin
    case ( MODE )
        DISPMODE:   begin
			SDRAM_BA <= DMEMADDR[20:19];
                        SDRAM_ADDR[11:0] <= DMEMADDR[19:7]; //12 bit ROW ADDRESS(for lower 16bit data)
                        //SDRAM_ADDR[7:0] = {DMEMADDR[6:0],1'b0}; //8 bit COL ADDRESS(for lower 16bit data)
                        MEMnOE  = 1'b0; //VGA read from SDRAM
                        MEMnUB  = 1'b0;
                        MEMnLB  = 1'b0;
                    end
        CAPTMODE:   begin
			SDRAM_BA <= CMEMADDR[20:19];
                        SDRAM_ADDR <= CMEMADDR;
                        //SDRAM_ADDR[7:0] = {CMEMADDR[6:0],1'b0}; //8 bit COL ADDRESS(for lower 16bit data)
                        MEMnOE  = 1'b1; //CAMERA write to SDRAM
                        MEMnUB  = 1'b0;
                        MEMnLB  = 1'b0;
                    end
        MCSMODE:    begin

    			if ( cur==IMODE )
    			    SDRAM_BA <= 2'b00;               /* MRS */
    			else if ( cur==RACT || cur==WACT )
    			    SDRAM_BA <= MMEMADDR[20:19];         /* ACT */
    			else if ( cur==RDA )
    			    SDRAM_BA <= MMEMADDR[20:19];         /* RDA */
    			else if ( cur==RDLY2 )
    			    SDRAM_BA <= MMEMADDR[20:19];         /* RDA */
    			else if ( cur== WRA )
    			    SDRAM_BA <= MMEMADDR[20:19];         /* WRA */
    			else if ( cur== WRA2 )
    			    SDRAM_BA <= MMEMADDR[20:19];         /* WRA */
		        //else if(movtrigger)
			//    SDRAM_BA <= wrdata_high_ba;
    			else
    			    SDRAM_BA <= 2'b00;

    			if ( cur==IMODE ) //immediately reflects value
    			    SDRAM_ADDR <= 12'h020;             /* MRS CL=2,BL=1 */
    			    //SDRAM_ADDR <= 12'h021;               /* MRS CL=2,BL=2 */
    			    //SDRAM_ADDR <= 12'h221;               /* Burst Read Single Write */
    			else if ( cur==RACT || cur==WACT )
    			    SDRAM_ADDR <= MMEMADDR[18:7];            /* ACT  - Pass Row Address to SDRAM*/
    			else if ( cur==IPALL )
    			    //SDRAM_ADDR <= 12'b0100_0000_0000;    /* PALL */
    			    SDRAM_ADDR <= 12'h400;    /* PALL */
    			else if ( cur==RDA )
    			    SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b0};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			else if ( cur==RDLY2 )
    			    SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b1};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			else if ( cur==WRA)
    			    //SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b0};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			    SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b0};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			else if ( cur==WRA2)
    			    //SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b1};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			    SDRAM_ADDR <= {4'b0100, MMEMADDR[6:0],1'b1};  /* RDA and WRA - Pass Column Address to SDRAM and A10 HIGH*/
    			else
    			    SDRAM_ADDR <= 12'h000;

                        MEMnOE  = MMEMnOE; //read or write from MCS
                        MEMnUB  = MMEMnUB;
                        MEMnLB  = MMEMnLB;
                    end
        default:    begin
                        SDRAM_BA <= 2'b0;
                        SDRAM_ADDR <= 12'b0;
                        MEMnOE  = 1'b1;
                        MEMnUB  = 1'b1;
                        MEMnLB  = 1'b1;
                    end
    endcase
end

/* 読み出しデータ */
reg [15:0]  rdata_low;
reg [15:0] rdata_high;

reg [3:0] byteEnable;
always @(posedge CLK ) begin
	if(RST)
		byteEnable <= 4'b0;
	else if(WRMEM)
		byteEnable <= IO_Byte_Enable;
end

always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        rdata_low <= 16'h0;
    else if ( cur==RDLY2) //textbook
          //rdata_low <= byteEnable;
          rdata_low <= SDRAM_DIN;
    else if (cur==RDEND)
	rdata_low <= 16'h0;
end

always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        rdata_high <= 16'h0;
    else if ( cur==RDLY3) //textbook
        //rdata_high <= 16'h0;
        rdata_high <= SDRAM_DIN;
    else if (cur==RDEND)
	rdata_high <= 16'h0;
end

assign RDATA0 = {rdata_high, rdata_low};

reg [15:0] wrcnt;

always @( posedge CLK ) begin
    if ( RST )
        wrcnt <= 16'h0;
    else if(cur==WACT)
	wrcnt <= 16'h0;
    else if(writemode)
	wrcnt <= wrcnt + 16'h1;
    else
	wrcnt <= 16'h0;
end

always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        wrdata <= 16'h0;
    else if(cur==WDLY1)
        wrdata <= IO_Write_Data[15:0];//Lower bit
    else if(cur==WRA)
        wrdata <= IO_Write_Data[31:16];//Upper bit 
    else if(writemode)
	wrdata <= wrcnt;
end

/* 書き込み信号およびトライステート制御 */
reg writemode;
/* 書き込みデータ */
reg [15:0] wrdata;

always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        writemode <= 1'b0;
    else if ( WRMEM )
        writemode <= 1'b1;
    else if ( cur== WREND)
        writemode <= 1'b0;
end

/* MCSモード時のMEMnLB, MEMnUB信号                  */
/* Read時：ともに0、Write時：IO_Byte_Enableを反映 */
always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        SDRAM_DQM <= 2'b11;
    else if ( RDMEM )
        SDRAM_DQM <= 2'b00;
    else if ( cur==WDLY1 )
        SDRAM_DQM <= ~IO_Byte_Enable[1:0];
        //SDRAM_DQM <= 2'b00;
    else if ( cur==WRA )
        //SDRAM_DQM <= ~IO_Byte_Enable[3:2];
        SDRAM_DQM <= ~IO_Byte_Enable[1:0];
    else if (cur==WDLYX)
        SDRAM_DQM <= ~IO_Byte_Enable[3:2];
    else if ( cur==WRA2 )
        SDRAM_DQM <= ~IO_Byte_Enable[3:2];
    else if ( cur==WDLY2)
//        SDRAM_DQM <= ~IO_Byte_Enable[1:0];
        SDRAM_DQM <= 2'b11; 
    else if ( cur==RDEND || cur==WREND )
        SDRAM_DQM <= 2'b11;
end

/* MCSモード時のMEMADDR */
always @( posedge CLK ) begin //change value at next clock
    if ( RST )
        //MMEMADDR <= 23'b0;
        MMEMADDR <= 21'b0;
    else if ( WRMEM | RDMEM )
        //MMEMADDR <= {IO_Address[23:2], 1'b0};
        MMEMADDR <= IO_Address[22:0]>>2; //extract lower 21bit(remember, sdram_address is 22bit)
    /*else if ( status==)
        //MMEMADDR <= {IO_Address[23:2], 1'b1};
        MMEMADDR <= {IO_Address[20:0], 1'b1};
	// do not swap MMEMADDRESS, because of burst transfer(auto asigining) 
    */
end

/* MCSモード時のMEMnOE */
always @( posedge CLK ) begin
    if ( RST )
        MMEMnOE <= 1'b1;
    else if ( RDMEM )
        MMEMnOE <= 1'b0;
    else if ( cur==RDEND || cur==WREND )
        MMEMnOE <= 1'b1;
end

/* MEMnWE */
//
always @( posedge CLK ) begin
    if ( RST )
        MEMnWE <= 1'b1;
    else if ( MODE==CAPTMODE ) begin
        if ( CMEMnWE_asrt )
            MEMnWE <= 1'b0;
        else if ( CMEMnWE_deas )
            MEMnWE <= 1'b1;
    end
    else if ( MODE==MCSMODE ) begin
        if ( writemode & cur==WACT )
            MEMnWE <= 1'b0;
        else if ( cur==WREND )
            MEMnWE <= 1'b1;
    end
    else
        MEMnWE <= 1'b1;
end


endmodule
