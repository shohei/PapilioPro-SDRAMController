 #include "platform.h"
 #define MEM_C  ((volatile unsigned char  *) 0xc0000000)
 #define MEM_S  ((volatile unsigned short *) 0xc0000000)
 #define MEM_I  ((volatile unsigned int   *) 0xc0000000)
 #define MODEREG *((volatile unsigned int *) 0xc1000000)
 #define MCSMODE 2
 //#define MEMSIZE 0x1E8480
//4Mx16bit address space
//2Mx32bit address space
//0x1E8480
//8MByte SDRAM
//32bit block number: 200_0000
//
//#define MEMSIZE 16 //more than 48(3byte)
//#define MEMSIZE 2000000 //more than 48(3byte)
//#define MEMSIZE 131073*4
//#define MEMSIZE 400000
//#define MEMSIZE 131050*4 //524050*32bit = 2MBite
//#define MEMSIZE 131050*4*4 //2096800*32bit = 8MBite
//#define MEMSIZE 2000000
#define MEMSIZE 2090000
//#define MEMSIZE 8000000
//#define MEMSIZE 0x10000
//#define MEMSIZE 65536
//#define MEMSIZE 0x1000000 - 16Mbit

int main() {
	//printf("hello\r\n");
	 xil_printf("\r\n");
	xil_printf("Hello, shohei.\r\n");
     int i, err,err1,err2,err3=0;
     err=0;
     err1=0;
     err2=0;
     err3=0;
     int j;
     volatile unsigned int i1, i2, i3;
     volatile unsigned int ary[3];
     init_platform();
     MODEREG = MCSMODE;

//     MEM_C[0]=0x12;
//     xil_printf("write: 0x12, read %x\r\n", MEM_C[0]);
//     MEM_C[1]=0xd2;
//     xil_printf("write: 0xd2, read %x\r\n", MEM_C[1]);
//     MEM_S[0]=0x2232;
//     xil_printf("write: 0x2232, read %x\r\n", MEM_S[0] );
//     MEM_I[0]=0x12540093;
//     xil_printf("write: 9x12540093, read %x\r\n", MEM_I[0]);

unsigned int valint[8];
valint[0] = 0x12345678;
MEM_I[0] = valint[0];
xil_printf("MEM_I[0]: %x\r\n",MEM_I[0]);
valint[1] = 0x87654321;
MEM_I[1] = valint[1];
xil_printf("MEM_I[1]: %x\r\n",MEM_I[1]);

     valint[2] = 0xAABBCCDD;
valint[3] = 0xEEFF0011;
valint[4] = 0x1643;
valint[5] = 0xdd21;
valint[6] = 0xCD;
valint[7] = 0x1F;
unsigned int fooint[8];
  for(i=0;i<8;i++){
  MEM_I[i] = valint[i];
  fooint[i] = MEM_I[i];//reading first time
  if(fooint[i]!=valint[i])xil_printf("FAILED. ");
  xil_printf("write: %x, read %x\r\n",valint[i], fooint[i]);
  }
//

unsigned short valshort[16];
valshort[0] = 0x204;
valshort[2] = 0x3344;
valshort[4] = 0x5566;
valshort[6] = 0x7788;
valshort[8] = 0x99AA;
valshort[10] = 0xBBCC;
valshort[12] = 0xDDEE;
valshort[14] = 0xFF00;

  unsigned short fooshort[8];
  for(i=0;i<8;i++){
	  MEM_S[2*i] = valshort[2*i];
	  fooshort[2*i] = MEM_S[2*i];//reading first time
	  if(fooshort[2*i]!=valshort[2*i])xil_printf("FAILED. ");
	  xil_printf("write: %x, read: %x\r\n",valshort[2*i], fooshort[2*i]);
  }

  unsigned short valbyte[32];
  valbyte[0] = 0x24;
  valbyte[4] = 0x34;
  valbyte[8] = 0x56;
  valbyte[12] = 0x78;
  valbyte[16] = 0x9A;
  valbyte[20] = 0xBC;
  valbyte[24] = 0xDE;
  valbyte[28] = 0xF0;


  unsigned int array[]={0,4,8,12,16,20,24,28};
    unsigned short foobyte[8];
    for(i=0;i<8;i++){
      MEM_C[array[i]] = valbyte[array[i]];
  	  foobyte[array[i]] = MEM_C[array[i]];//reading first time
  	  if(foobyte[array[i]]!=valbyte[array[i]])xil_printf("FAILED. ");
  	  xil_printf("%d: write %x, read: %x\r\n",array[i],valbyte[array[i]], foobyte[array[i]]);
    }


//
  /* RAM に書き込む値 */
//
  ary[0] = 0x47bd9f6a;
     ary[1] = 0x1e806c95;
     ary[2] = 0x2fdc3a5c;
     //  /* BYTE 書き込み */
      xil_printf("BYTE Checking...\r\n");

     for ( j=0; j<MEMSIZE-3; j=j+3 ) {
    	 //xil_printf("W:%d\r\n",i);
    	 MEM_C[4*j]   = ary[0] & 0xff;
         MEM_C[4*(j+1)] = ary[1] & 0xff;
         MEM_C[4*(j+2)] = ary[2] & 0xff;
     }
    for ( j=0; j<MEMSIZE-3; j=j+3 ) {
	//xil_printf("R:%d\r\n",i);
    i1 = MEM_C[4*j];
    i2 = MEM_C[4*(j+1)];
    i3 = MEM_C[4*(j+2)];
//    xil_printf("%x:%x %x:%x %x:%x\r\n",ary[0]&0xff,i1,
//    		ary[1]&0xff,i2,ary[2]&0xff,i3);

    if ( i1 != (0xff & ary[0]) ) {
    	//xil_printf("%d: %x->%x\r\n",4*j,ary[0]&0xff,i1);
    	err=1;
    	//return -1;
    }
    if ( i2 != (0xff & ary[1]) ) {
     	//xil_printf("%d: %x->%x\r\n",4*(j+1),ary[1]&0xff,i2);
    	err=1;
    }
   	if ( i3 != (0xff & ary[2]) ) {
     	//xil_printf("%d: %x->%x\r\n",4*(j+2),ary[2]&0xff,i3);
    	err=1;
   	}
}

///* SHORT 書き込み */
     xil_printf("SHORT Checking...\r\n");
 for ( j=0; j<MEMSIZE-3; j=j+3 ) {
	 //xil_printf("%d\r\n",i);
	MEM_S[2*j]   = ary[0];
    MEM_S[2*(j+1)] = ary[1];
    MEM_S[2*(j+2)] = ary[2];
}
/* SHORT 読み出し */
for ( j=0; j<MEMSIZE-3; j=j+3 ) {
    i1 = MEM_S[2*j];
    i2 = MEM_S[2*(j+1)];
    i3 = MEM_S[2*(j+2)];
//    xil_printf("%x:%x %x:%x %x:%x\r\n",ary[0]&0xffff,i1,
//    		ary[1]&0xffff,i2,ary[2]&0xffff,i3);

    if ( i1 != (ary[0] & 0xffff) )
    {err=1;
    //xil_printf("%d: %x->%x\r\n",2*j,ary[0]&0xffff,i1);
;}

    if ( i2 != (ary[1] & 0xffff) ) err=1;
    if ( i3 != (ary[2] & 0xffff) ) err=1;
}

/////* INT 書き込み */
//ary[0] = 0x12345678;
//ary[1] = 0xABCDEF12;
//ary[2] = 0x90224583;
//  ary[0] = 0x78;
//  ary[1] = 0x12;
//  ary[2] = 0x83;

  xil_printf("INT Checking...\r\n");
     for ( i=0; i<MEMSIZE-3; i=i+3 ) {
    //xil_printf("%d",i);
    MEM_I[i]   = ary[0];
    i1 = MEM_I[i];
    MEM_I[i+1] = ary[1];
    i2 = MEM_I[i+1];
    MEM_I[i+2] = ary[2];
    i3 = MEM_I[i+2];
     }

/////* INT 読み出し */

     for ( i=0; i<MEMSIZE-3; i=i+3 ) {
	i1 = MEM_I[i];
    i2 = MEM_I[i+1];
    i3 = MEM_I[i+2];
//    xil_printf("%x:%x %x:%x %x:%x\r\n",ary[0],i1,ary[1],i2,ary[2],i3);
    if ( i1 != ary[0] )
    	 {err=1;
    	 //xil_printf("%d: %x->%x\r\n",i,ary[0],i1);
    	;}
    if ( i2 != ary[1] ) err2=1;;
    if ( i3 != ary[2] ) err3=1;
}

if ( err==1 )
         xil_printf("NG!\n");
else if(err1==1)
    xil_printf("ERROR1.\r\n");
else if(err2==1)
    xil_printf("ERROR2.\r\n");
else if(err3==1)
    xil_printf("ERROR3.\r\n");

else
         xil_printf("OK! Checking End.\r\n");

cleanup_platform();
return 0;
}
