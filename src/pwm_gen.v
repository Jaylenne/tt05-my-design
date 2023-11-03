`default_nettype none

module pwm_gen(
    input   wire        clk,
    input   wire        rst_n,
    input   wire        i_pwm_tri,
    input   wire [11:0] i_pulse_width,
    output  reg         o_pwm
);

reg [11:0] counter_reg, counter_next;
reg [1:0] state_reg, state_next;

localparam  S_IDLE  = 2'd0,
            S_PWM   = 2'd1,
            S_END   = 2'd2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_reg <= 12'd0;
        state_reg <= S_IDLE;
    end else begin
        counter_reg <= counter_next;
        state_reg <= state_next;
    end
end

always @(*) begin
    counter_next = counter_reg;
    state_next = state_reg;

    case(state_reg) 
        S_IDLE: begin
            o_pwm = 0;
            if(i_pwm_tri) state_next = S_PWM;
        end

        S_PWM: begin
            if(counter_reg < i_pulse_width) begin
                o_pwm = 1;
                counter_next = counter_reg + 1'b1;
            end else begin
                o_pwm = 0;
                counter_next = 12'd0;
                state_next = S_END;
            end
        end

        S_END: begin
            o_pwm = 0;
            state_next = S_IDLE;
        end

        default: begin
            o_pwm = 0;
        end
    endcase
end

endmodule
