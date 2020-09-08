

module counter( output [3:0] count,input clk,input clear); //  1:11
parameter lastnum = 4'd 11 ;
reg     [3:0] count;

always @ (posedge clk)
begin
    if (clear)
        count <= 0;   
    else if(count == lastnum)
        count <= lastnum;
    else 
    	count <= count + 1;
end 

endmodule

module RX_control_unit( clear, readinterrupt,clk, count, in);
output clear, readinterrupt;
input clk,in;
input   [3:0] count ;
reg     clear ,readinterrupt,temp;

always @ (posedge clk)
begin
	readinterrupt <= (in &&(count==9));
	if (in)
		temp = (count == 9)?0:1;
	
    if (temp) 
		clear = 0;
	else 
		clear = 1;
end 

endmodule


module recieved_data(out, clk, in,clear,parity);
output [7:0] out ;
output  parity;
input   clk, in,clear; //clear = parity check start
reg     [9:0] out1 ;
reg   parity;
reg [7:0] out ;

always @ (posedge clk)
begin
	out1 <= {in,out1[9:1]};
	out <= out1[8:1] ;
	parity <= (~clear) &(in ^ parity);  
end 

endmodule


module RX(out,parity,readinterrupt, clk, in);

output [7:0] out ;
output  parity ,readinterrupt;
input   clk, in;
wire    [7:0] out;
wire  parity ,readinterrupt ,clear;
wire [3:0] count ;

counter a1 (.count (count) , .clk (clk) , .clear (clear));
RX_control_unit a2( .readinterrupt (readinterrupt),  .clk (clk) , .clear (clear) , .in (in) ,.count (count));
recieved_data a3 (.out (out) , .clk (clk) , .clear (clear) , .in (in) , .parity (parity) );

endmodule




module TX_control_unit( clear, writedone, clk, count ,writestart ,start,paritybit,finish,clearbit);
output clear, writedone ,start,paritybit,finish,clearbit;
input   clk ,writestart;
input   [3:0] count ;
reg     clear ,writedone ,start,paritybit,finish,temp,clearbit;

always @ (posedge clk)
begin
    
    start <= writestart;
    finish <= (count==8);
    paritybit <=  (count==7);
    writedone <= (count==9);
    clearbit <= (count==1);
    
    if ( writestart ) 
        begin
        	temp <= 1;
            clear <= 0;
        end
    if (temp) begin

    	clear <= 0;
    	if( count == 9) 
            temp <= 0;	
    end

    else 
    	clear <= 1;
end 
endmodule


module data_to_be_sent(out, clk, in,start,paritybit,finish,clearbit);
output out ;
input   clk ,start,paritybit,finish,clearbit;
input   [7:0] in;
reg     out ,parity;
reg [7:0] temp ;

always @ (posedge clk)
begin
    if (start || finish) begin
        out <= 1;
        parity <=0;
        temp <= (finish)?0:in;
    end
    else if (paritybit) begin
        out <= ~parity;
    end
   
    else begin       
            out <= temp[0];
            parity <= parity ^ out;
            temp <= temp >> 1; 
    end
end 
endmodule


module TX(out, clk, in, writedone ,writestart);

output  out ,writedone ;
input   clk, writestart;
input 	[7:0] in ;
wire    out, paritybit ,writedone ,writestart,clear,start,finish,clearbit;
wire [3:0] count ;

counter #(.lastnum (12)) a100 ( .count (count) , .clk (clk) , .clear (clear));
TX_control_unit a200 ( .writedone (writedone) ,  .clk (clk) , .clear (clear)  ,.count (count) , .writestart (writestart)
 , .start (start), .paritybit (paritybit) , .finish (finish),.clearbit (clearbit) );
data_to_be_sent a300 (.out (out) , .clk (clk)  , .in (in) , .paritybit (paritybit) , .start (start) , .finish (finish)
 , .clearbit (clearbit));

endmodule


module UART( clk, writestart ,in , writedone ,data_out ,data_in  ,out ,readinterrupt  ,parity);
output  writedone  ,readinterrupt  ,parity  ,data_out;
output  [7:0] out ;
input   clk, writestart ,data_in;
input 	[7:0] in ;
wire    data , writedone  ,readinterrupt  ,parity;
wire 	[7:0] out ;

TX a0 (.out (data_out), .clk (clk), .in (in), .writedone (writedone) ,.writestart (writestart) ); 
RX a1 (.out (out), .parity (parity) ,.readinterrupt (readinterrupt) , .clk (clk), .in (data_in)); 

endmodule
