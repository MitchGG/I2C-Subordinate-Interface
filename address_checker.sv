//This module checks if the device address matches the address sent by the master device
//It also checks whether the subordinate should operate in read or write mode


module address_checker (input logic rst, input logic sda, input logic scl, input logic read_address,
                        input logic [3:0] clock_count, input logic start, input logic stop,
                        output logic address_match, output logic read_bit, output logic write_bit);


logic [6:0] device_address;
assign device_address = 7'b1100110;

logic [6:0] address;

always_ff @(posedge scl or negedge rst) begin
  if (!rst)
    address = 7'b0;
  else begin
    if (read_address && (clock_count <= 4'd6))
      address[4'd6 - clock_count] = sda;
  end
end

always_comb begin
  if (read_address && (clock_count == 4'd7) && (address == device_address))
    address_match = 1'b1;
  else
    address_match = 1'b0;
end

//Add in reset for start/stop condiiton
always_ff @(posedge scl, negedge rst, posedge start, posedge stop) begin
  if (!rst || start || stop) begin
    read_bit = 1'b0;
    write_bit = 1'b0;
  end
  else begin
    if (read_address && (clock_count == 4'd7)) begin
      if (sda == 1'b1) begin
        read_bit = 1'b1;
        write_bit = 1'b0;
      end
      else if (sda == 1'b0) begin
        read_bit = 1'b0;
        write_bit = 1'b1;
      end
    end
  end
end




endmodule: address_checker
