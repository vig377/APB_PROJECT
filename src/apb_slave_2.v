module apb_slave_2(PCLK,PRESETn,PENABLE,PWRITE,PW_DATA,PADDR,PSEL,PREADY,PR_DATA,PSLVERR);
input wire PCLK,PRESETn,PENABLE,PWRITE,PSEL;
input wire [7:0]PW_DATA,PADDR;
output wire PREADY,PSLVERR;
output wire [7:0]PR_DATA;
reg [7:0]mem[0:255];
  reg [2:0]wait_count;
integer i;
  always@(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        wait_count<=3'd0;
      
      else if(PSEL && PENABLE)
        wait_count<=wait_count+1;
      else
        wait_count<=3'd0;
    end
assign PREADY= PSEL && PENABLE&& wait_count==3'd3 ;
assign PSLVERR = PSEL && PENABLE && (PADDR > 8'd255);
  assign PR_DATA= (PSEL && PENABLE && !PWRITE &&(PADDR <= 8'd255)&&wait_count==3'd3)?mem[PADDR]:PR_DATA;
always@( posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
begin
    for(i=0;i<256;i=i+1)
        mem[i]<=8'd0;
end
else
begin
    if(PSEL && PENABLE && PWRITE && (PADDR<=8'd255))
        mem[PADDR]<=PW_DATA;
end
end         
endmodule
