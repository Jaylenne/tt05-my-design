`default_nettype none

module k_nn(
    input   wire        clk,
    input   wire        rst_n,
    input   wire [2:0]  i_k, // K-neareset
    input   wire [7:0]  i_fall, // falling detection of signal, align with clk
    output  reg [7:0]   o_nn, // Neareset output
    output  reg [7:0]   o_knn
);

wire fall_all;
reg [7:0] fall_reg; // falling detection register
wire [2:0] nn_count; // Count the number of fall detection at each clock cycle

counter #(.N_BIT(3)) fall_counter(
    .clk(clk),
    .rst_n(rst_n),
    .i_signal(fall_all),
    .o_count(nn_count)
);

assign fall_all = | i_fall; // assign it to high if any fall trigger is activated

// Latch the fall detection at each clock cycle
genvar i;
generate
    for(i=0; i<8; i=i+1) begin: fall_reg_gen
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) fall_reg[i] <= 1'b0;
            else begin
                if(i_fall[i]) fall_reg[i] <= 1'b1;
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_nn <= 8'd0;
        o_knn <= 8'd0;
    end else begin
        if(nn_count == 3'd1) o_nn <= fall_reg;
        else if(nn_count == i_k) o_knn <= fall_reg;
    end
end

endmodule
