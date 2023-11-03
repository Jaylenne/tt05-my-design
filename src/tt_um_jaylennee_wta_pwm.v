`default_nettype none

module tt_um_jaylennee_wta_pwm(
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n    
);

assign uio_oe = 8'b00000000;

// spi outports wire
wire        	o_miso_1;
wire        	o_miso_2;
wire [95:0] 	o_spi1_out;
wire [10:0] 	o_spi2_out;

// spi input wire
wire            i_ss_1, i_ss_2;
wire            i_mosi_1, i_mosi_2;
wire [95:0]     i_spi1_in;
wire [15:0]     i_spi2_in;

assign {i_ss_2, i_ss_1} = ui_in[1:0];
assign {i_mosi_2, i_mosi_1} = ui_in[3:2];
assign uo_out[1:0] = {o_miso_2, o_miso_1};

spi u_spi(
	.clk        	( clk         ),
	.rst_n      	( rst_n       ),
	.i_ss_1     	( i_ss_1      ),
	.i_mosi_1   	( i_mosi_1    ),
	.o_miso_1   	( o_miso_1    ),
	.i_ss_2     	( i_ss_2      ),
	.i_mosi_2   	( i_mosi_2    ),
	.o_miso_2   	( o_miso_2    ),
	.o_spi1_out 	( o_spi1_out  ),
	.i_spi1_in  	( i_spi1_in   ),
	.o_spi2_out 	( o_spi2_out  ),
	.i_spi2_in  	( i_spi2_in   )
);

// PWM generation

// wire [11:0] pulse_width [7:0];
wire [7:0]  o_pwm;
wire        i_pwm_tri;

assign i_pwm_tri = ui_in[4];

genvar i;
// generate
//     for(i=0; i<8; i=i+1) begin: gen_assign_pw  
//         assign pulse_width[i] = o_spi1_out[((i+1)*12-1)-:12];
//     end
// endgenerate

generate
    for(i=0; i<8; i=i+1) begin: gen_pwm
        pwm_gen u_pwm_gen(
            .clk           	( clk            ),
            .rst_n         	( rst_n          ),
            .i_pwm_tri     	( i_pwm_tri      ),
            .i_pulse_width 	( o_spi1_out[((i+1)*12-1)-:12] ),
            .o_pwm         	( o_pwm[i]       )
        );
    end
endgenerate

// Input switches

wire [7:0] pwm_switch;
wire [7:0] pwm_inside;

assign pwm_switch = o_spi2_out[7:0];

generate
    for(i=0; i<8; i=i+1) begin: gen_switch
        assign pwm_inside[i] = pwm_switch[i] ? uio_in[i] : o_pwm[i];
    end
endgenerate

// PWM Synchronize

wire [95:0] pwm_count;
wire [7:0]  pwm_fall;
wire [7:0]  pwm_sync;

assign i_spi1_in = pwm_count;

generate
    for(i=0; i<8; i=i+1) begin: gen_sync 
        pwm_sync u_pwm_sync(
            .clk          	( clk                           ),
            .rst_n        	( rst_n                         ),
            .i_pwm_signal 	( pwm_inside[i]                 ),
            .o_pwm_sync   	( pwm_sync[i]                   ),
            .o_pwm_fall   	( pwm_fall[i]                   ),
            .o_count      	( pwm_count[((i+1)*12-1)-:12]   )
        );
    end
endgenerate    

// KNN Search
// knn outports wire
wire [7:0] 	o_nn;
wire [7:0] 	o_knn;

// knn input wire
wire [2:0]  i_k;

assign i_k = o_spi2_out[10:8];
assign i_spi2_in = {o_knn, o_nn};

k_nn u_k_nn(
	.clk    	( clk     ),
	.rst_n  	( rst_n   ),
	.i_k    	( i_k     ),
	.i_fall 	( pwm_fall),
	.o_nn   	( o_nn    ),
	.o_knn  	( o_knn   )
);

// TT interface
assign uo_out[2] = pwm_inside[0];
assign uo_out[3] = pwm_sync[0];
assign uo_out[4] = pwm_fall[0];
assign uo_out[5] = pwm_inside[7];
assign uo_out[6] = pwm_sync[7];
assign uo_out[7] = pwm_fall[7];

assign uio_out = 8'b0; // Tie output to GND

endmodule
