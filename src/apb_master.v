module apb_master(PCLK,PRESETn,PADDR,READ_WRITE,PSEL1,PSEL2,TRANSFER,PENABLE,PWRITE,PW_DATA,APB_WRITE_PADDR,APB_WRITE_DATA,APB_READ_PADDR,APB_READ_DATA_OUT,PREADY,PSLVERR,PR_DATA);
input wire PCLK,PRESETn,TRANSFER;
input wire PREADY,PSLVERR;
input wire [7:0]PR_DATA;
input wire READ_WRITE;
input wire [8:0]APB_WRITE_PADDR,APB_READ_PADDR;
input wire [7:0]APB_WRITE_DATA;
output reg PSEL1,PSEL2,PWRITE;
output reg PENABLE;
output reg [7:0]APB_READ_DATA_OUT;
output reg [7:0]PW_DATA;
output reg [8:0]PADDR;
//states
parameter IDLE=2'b00;
parameter SETUP=2'b01;
parameter ACESS=2'b10;
reg [1:0]c_st,n_st;
always@(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
c_st<=IDLE;
else
c_st<=n_st;
end
always@(*)
begin
case(c_st)
IDLE:begin
        if(TRANSFER)
            n_st=SETUP;
        else
            n_st=IDLE;
     end
SETUP:begin
        n_st=ACESS;
      end
ACESS:begin
        if(PREADY && PSLVERR  )
            n_st=IDLE;
        else if(PREADY && !PSLVERR )
             n_st=(TRANSFER)?SETUP:IDLE;
        else
            n_st=ACESS;
      end
default:n_st=IDLE;
endcase
end
always@(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
begin
PENABLE<=0;
APB_READ_DATA_OUT<=8'd0;
end
else
begin
case(c_st)
IDLE:begin
        PENABLE<=0;
     end
SETUP:begin
      PENABLE<=0;
      end
ACESS:begin
        PENABLE<=1;
            if(PREADY && !PSLVERR)
                begin
                    if(READ_WRITE)//read
                        APB_READ_DATA_OUT<=PR_DATA;
                end
      end
      endcase
end
end
always @(*)
begin
PSEL1=0;
PSEL2=0;
PADDR=9'd0;
PWRITE=0;
PW_DATA=8'd0;
case(c_st)
SETUP:begin
        if(!READ_WRITE)//write
           begin
            PADDR=APB_WRITE_PADDR;
            PSEL1=(APB_WRITE_PADDR[8]==0);
            PSEL2=(APB_WRITE_PADDR[8]==1);
            PW_DATA=APB_WRITE_DATA;
            PWRITE=1;
           end
        else
           begin//read
            PADDR=APB_READ_PADDR;
            PSEL1=(APB_READ_PADDR[8]==0);
            PSEL2=(APB_READ_PADDR[8]==1);
            PWRITE=0;
          end
       end
ACESS:begin
        if(!READ_WRITE) begin
                PADDR   = APB_WRITE_PADDR;
                PSEL1   = (APB_WRITE_PADDR[8]==0);
                PSEL2   = (APB_WRITE_PADDR[8]==1);
                PW_DATA = APB_WRITE_DATA;
                PWRITE  = 1;
            end else begin
                PADDR  = APB_READ_PADDR;
                PSEL1  = (APB_READ_PADDR[8]==0);
                PSEL2  = (APB_READ_PADDR[8]==1);
                PWRITE = 0;
            end
       end
endcase
end
endmodule
