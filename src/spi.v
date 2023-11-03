`default_nettype none

module spi(
    input   wire        clk,
    input   wire        rst_n,

    // SPI 1
    input   wire        i_ss_1,
    input   wire        i_mosi_1,
    output  wire        o_miso_1,

    // SPI 2
    input   wire        i_ss_2,
    input   wire        i_mosi_2,
    output  wire        o_miso_2,

    // interface
    output  reg  [95:0] o_spi1_out, // 8 12-bit pulse width
    input   wire [95:0] i_spi1_in, // 8 12-bit counter output
    output  reg  [10:0] o_spi2_out, // 8-bit switch and 3-bit knn threshold
    input   wire [15:0] i_spi2_in // 8-bit NN and 8-bit KNN result
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_spi1_out <= 96'd0;
    end else begin
        if(i_ss_1) o_spi1_out <= {i_mosi_1, o_spi1_out[95:1]};
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_spi2_out <= 11'd0;
    end else begin
        if(i_ss_2) o_spi2_out <= {i_mosi_2, o_spi2_out[10:1]};
    end
end

reg [95:0] spi1_in;
reg [15:0] spi2_in;

always @(posedge clk or negedge rst_n) begin        
    if(i_ss_1) spi1_in <= spi1_in >> 1;
    else spi1_in <= i_spi1_in;
end

always @(posedge clk or negedge rst_n) begin        
    if(i_ss_2) spi2_in <= spi2_in >> 1;
    else spi2_in <= i_spi2_in;
end

assign o_miso_1 = spi1_in[0];
assign o_miso_2 = spi2_in[0];

endmodule