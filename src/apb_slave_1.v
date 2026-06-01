module apb_slave_1(PCLK,PRESETn,PENABLE,PWRITE,PW_DATA,PADDR,PSEL,PREADY,PR_DATA,PSLVERR);
input wire PCLK,PRESETn,PENABLE,PWRITE,PSEL;
input wire [7:0]PADDR,PW_DATA;
output wire PREADY,PSLVERR;
output wire [7:0]PR_DATA;
reg [7:0]mem[0:255];
integer i;
assign PREADY= PSEL && PENABLE;
assign PSLVERR= PSEL && PENABLE &&(PADDR>8'd255);
assign PR_DATA=(PSEL&&PENABLE&&!PWRITE&&(PADDR<=8'd255))?mem[PADDR]:8'h0;
always@(posedge PCLK or negedge PRESETn)
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
