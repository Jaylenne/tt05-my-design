`default_nettype none

module counter #( parameter N_BIT = 12 )(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                i_signal,
    output  reg [N_BIT-1:0]     o_count
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_count <= 'd0;
    end else begin
        if(i_signal) o_count <= o_count + 1'b1;
    end
end

endmodule