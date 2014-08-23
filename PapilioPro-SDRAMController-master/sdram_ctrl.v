/* Copyright(C) 2011 Cobac.Net All rights reserved. */

module SDRAM_CTRL(
    /* Avalonバス */
    input           CLK, RST,
    input   [21:0]  ADDR,
    input   [1:0]   BYTEEN,
    input           WRITE, READ,
    input   [15:0]  WRDATA,
    output  [15:0]  RDDATA,
    output          WAITREQ,
    /* SDRAM */
    output          DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N,
    output  reg [1:0]   DRAM_BA,
    output  reg [11:0]  DRAM_ADDR,
    inout   [15:0]  DRAM_DQ,
    output  [1:0]   DRAM_DQM

);

/* SDRAM 制御信号（宣言部分） */
reg    nCS, nRAS, nCAS, nWE;
assign {DRAM_CS_N, DRAM_RAS_N, DRAM_CAS_N, DRAM_WE_N}
                             = {nCS, nRAS, nCAS, nWE};

/* READ/WRITE制御ステートマシン宣言部分 */
parameter IWAIT=5'd0, IPALL=5'd1, IDLY1=5'd2, IRFSH=5'd3,
        IDLY2=5'd4, IDLY3=5'd5, IMODE=5'd6, 
        RACT=5'd7, RDLY1=5'd8, RDA=5'd9, RDLY2=5'd10, RDLY3=5'd11, 
        HALT=5'd12, WACT=5'd13, WDLY1=5'd14, WRA=5'd15, WDLY2=5'd16,
        FRFSH=5'd17, FDLY=5'd18;

reg [4:0]   cur, nxt;

/* 初期化用200μsカウンタ */
parameter MAX200=14'd10000;

reg [13:0]  i200cnt;

wire i200cntup = (i200cnt==MAX200-1);

always @( posedge CLK, posedge RST ) begin
    if ( RST )
        i200cnt <= 14'h0;
    else
        i200cnt <= i200cnt + 14'h1;
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
parameter   REFMAX=10'd770;

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
        IWAIT:  if ( i200cntup )
                    nxt <= IPALL;
                else
                    nxt <= IWAIT;
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
                else if ( WRITE )
                    nxt <= WACT;
                else if ( READ )
                    nxt <= RACT;
                else
                    nxt <= HALT;
        /* WRITE動作 */
        WACT:   nxt <= WDLY1;
        WDLY1:  nxt <= WRA;
        WRA:    nxt <= WDLY2;
        WDLY2:  nxt <= HALT;

        /* READ動作 */
        RACT:   nxt <= RDLY1;
        RDLY1:  nxt <= RDA;
        RDA:    nxt <= RDLY2;
        RDLY2:  nxt <= RDLY3;
        RDLY3:  nxt <= HALT;

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
    else if ( cur==WRA )
        {nCS, nRAS, nCAS, nWE} <= 4'b0100;  /* WRA  */
    else if ( cur==IRFSH | cur==FRFSH )
        {nCS, nRAS, nCAS, nWE} <= 4'b0001;  /* REF  */
    else
        {nCS, nRAS, nCAS, nWE} <= 4'b1111;
end

/* アドレス信号 */
always @* begin
    if ( cur==IMODE )
        DRAM_ADDR <= 12'h020;               /* MRS  */
    else if ( cur==RACT || cur==WACT )
        DRAM_ADDR <= ADDR[19:8];            /* ACT  */
    else if ( cur==IPALL )
        DRAM_ADDR <= 12'b0100_0000_0000;    /* PALL */
    else if ( cur==RDA )
        DRAM_ADDR <= {4'b0100, ADDR[7:0]};  /* RDA  */
    else if ( cur==WRA )
        DRAM_ADDR <= {4'b0100, ADDR[7:0]};  /* WRA  */
    else
        DRAM_ADDR <= 12'h000;
end

/* バンクアドレス信号 */
always @* begin
    if ( cur==IMODE )
        DRAM_BA <= 2'b00;               /* MRS */
    else if ( cur==RACT || cur==WACT )
        DRAM_BA <= ADDR[21:20];         /* ACT */
    else if ( cur==RDA )
        DRAM_BA <= ADDR[21:20];         /* RDA */
    else if ( cur==WRA )
        DRAM_BA <= ADDR[21:20];         /* WRA */
    else
        DRAM_BA <= 2'b00;
end

/* DQ、DQM、Avalonバス信号 */
assign DRAM_DQ  = ( cur==WRA ) ? WRDATA: 16'hzzzz;
assign DRAM_DQM = ~BYTEEN;
assign RDDATA   = DRAM_DQ;
assign WAITREQ  = (cur==RDLY3 || cur==WDLY2) ? 1'b0: 1'b1;

endmodule
