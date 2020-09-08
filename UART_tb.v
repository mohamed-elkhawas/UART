

module clk( output out);
reg out;
initial
begin
    out <= 0;
end
always 
    begin
    #1  out = ~out;
    end

endmodule

module UART_tb ();
wire clk , data , writedone ,readinterrupt ;
reg  writestart ;
reg [7:0] in ;
wire  [7:0] out ;
clk c (clk);


UART u0 (.data_out (data), .clk (clk), .in (in), .writedone (writedone) ,.writestart (writestart));  
UART u1 (.out (out),.parity (parity) ,.readinterrupt (readinterrupt) , .clk (clk), .data_in (data)); 


initial
    begin

$dumpfile("UART_tb.vcd");
$dumpvars(0,UART_tb);

$monitor ($time ,"  writestart =  %b     in = %b  out = %b     writedone = %b readinterrupt  %b parity = %b "
    ,  writestart ,in ,  out , writedone ,readinterrupt,parity);    
in = 0 ;   writestart = 0 ; 

#101 in =8'b 01000101 ;  
#2 writestart = 1 ;
#2    writestart = 0 ;
#200 in =8'b 01000111 ; 
#2  writestart = 1 ;
#2    writestart = 0 ;

#500
$finish;

    end
endmodule

