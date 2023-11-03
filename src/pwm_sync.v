`default_nettype none

module pwm_sync(
    input   wire        clk,
    input   wire        rst_n,
    input   wire        i_pwm_signal,
    output  wire        o_pwm_sync, // Signals after sync
    output  wire        o_pwm_fall, // Signals denote the falling edge
    output  wire [11:0] o_count
); 

reg pwm_d, pwm_sync, pwm_sync_old;

counter #(.N_BIT(12)) pwm_counter(
    .clk(clk),
    .rst_n(rst_n),
    .i_signal(o_pwm_sync),
    .o_count(o_count)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pwm_d <= 0;
        pwm_sync <= 0;
        pwm_sync_old <= 0;
    end else begin
        pwm_d <= i_pwm_signal;
        pwm_sync <= pwm_d;
        pwm_sync_old <= pwm_sync;
    end
end

assign o_pwm_sync = pwm_sync;
assign o_pwm_fall = pwm_sync_old & (~pwm_sync);

endmodule
