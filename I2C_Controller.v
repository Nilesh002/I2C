
module i2c_controller(
	input wire CLK,                   // from processor
	input wire rstn,                  // from processor
	input wire chip_sel,              // from processor
	input wire chip_en,               // from processor 
	input wire chip_write,            // from processor	
	input wire [7:0] chip_addr,       // from processor
	input wire [31:0] wdata,          // from processor
	
	input wire [7:0] data_out,       // from i2c_master
	input wire [7:0]status_reg,       // from i2c master
	
	output reg din_write=0,
	output reg dout_read = 0,    
		
	output reg [31:0] rdata = 0,      // to processor
	output reg [7:0] control_reg = 0, // to i2c master
	output reg [7:0] slave_addr,      // to i2c master
    output reg [7:0] data_in,         // to i2c master
    output reg [7:0] data_count       // to i2c master
    );


always @(negedge CLK) 
begin
    if(rstn)
    begin
       rdata <= 8'h00; 
       control_reg <= 8'h00;
       slave_addr  <= 8'h00;
       data_in     <= 8'h00;
       data_count  <= 8'h00;
       din_write   <= 1'b0;
       dout_read   <= 1'b0;
    end
    else if (chip_addr == 8'h00 && (chip_sel ==1'b1)) begin // control reg access
			if (chip_write == 1) begin // write
                control_reg <= wdata[7:0];
                din_write <= 1'b0;  
                dout_read <= 1'b0;               
		    end					
		    else begin
                rdata[7:0] <= control_reg; 
                din_write <= 1'b0; 
                dout_read <= 1'b0; 
			end					
	   end
	
	   else if (chip_addr[7:0] == 8'h04 && (chip_sel ==1'b1)) begin // data count reg access
			if (chip_write == 1) begin // write
                data_count <= wdata[7:0];
                din_write <= 1'b0; 
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[7:0] <= data_count;   
                din_write <= 1'b0;
                dout_read <= 1'b0;
			end
					
		end
		
	   else if (chip_addr[7:0] == 8'h08 && (chip_sel ==1'b1)) begin // slave addr reg access
			if (chip_write == 1) begin // write
                slave_addr <= wdata[7:0]; 
                din_write <= 1'b0;
                dout_read <= 1'b0;               
		    end					
		    else begin // read 
                rdata[7:0] <= slave_addr;  
                din_write <= 1'b0;
                dout_read <= 1'b0; 
			end
					
		end
		
		else if (chip_addr[7:0] == 8'h0c && (chip_sel ==1'b1) && (chip_write == 0)) begin // status reg access
                rdata[7:0] <= status_reg;   // read	
                din_write <= 1'b0;
                dout_read <= 1'b0;            			
		end	
		
	   else if (chip_addr[7:0] == 8'h10 && (chip_sel ==1'b1) && (chip_write == 1)) begin // data in reg access
                data_in <= wdata[7:0]; // write
                din_write <= 1'b1;  
                dout_read <= 1'b0;               			
		end	
			
	   else if (chip_addr[7:0] == 8'h14 && (chip_sel ==1'b1) && (chip_write == 0)) begin // data out reg access
                rdata[7:0] <= data_out; // read
                din_write <= 1'b0;
                dout_read <= 1'b1;  			
		end	
		
	   else 
	   begin
	           rdata[7:0] <= 8'h00;
	           din_write <= 1'b0;
	           dout_read <= 1'b0;   
	   end
end 
endmodule
