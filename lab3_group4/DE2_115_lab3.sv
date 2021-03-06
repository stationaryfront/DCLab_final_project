module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	//*********************SevenHex******************* 
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	//*********************SevenHex******************* 
    //*********************LCD*******************    
	output LCD_BLON,    
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
    //*********************LCD*******************
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
    //*********************CODEC*******************
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
    //*********************CODEC*******************
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
    //*********************SRAM********************
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
    //*********************SRAM********************
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
//*********************CLKgenerator********************
	logic clk12M, clk100K;
	logic DLY_RST; 
	assign AUD_XCK = clk12M;				// 餵12M的clk訊號到AUD_XCK(WM8731)

	clkgen clkg(
		.inclk0(CLOCK_50),
		.c0(clk12M),
		.c1(clk100K)
	);

    Reset_Delay rst0(
        .iCLK(clk12M),
        .oRESET(DLY_RST)
    );
	
	//  KEYs
   logic keydown_rst;
	logic keydown_playorpause;
	logic keydown_spdup;
	logic keydown_spddown;

//*********************Debounce********************
	//  Debounce
	Debounce deb_rst(
		.i_in(KEY[0]),
		.i_clk(AUD_BCLK),
		.o_neg(keydown_rst)
	);
	Debounce deb_playorpause(
		.i_in(KEY[1]),
		.i_clk(AUD_BCLK),
		.o_neg(keydown_playorpause)
	);
    Debounce deb_spdup(
		.i_in(KEY[2]),
		.i_clk(AUD_BCLK),
		.o_neg(keydown_spdup)
	);
	Debounce deb_spddown(
		.i_in(KEY[3]),
		.i_clk(AUD_BCLK),
		.o_neg(keydown_spddown)
	);
//

	 Initialize i0(
       .i_clk(clk100K),
		.i_rst(DLY_RST),
		.o_sclk(I2C_SCLK),
		.o_sdat(I2C_SDAT)
	);


//*********************Record********************

Record record(
	.i_rst(DLY_RST),				
	.i_stop(keydown_rst),				
	.i_playpause(keydown_playorpause),			
	.i_record(SW[0]),						
	// codec
	.i_BCLK(AUD_BCLK),				
	.i_LRC(AUD_ADCLRCK),
	.i_DAT(AUD_ADCDAT),
	// LCD
	.state_denote(rec_state),     							// 做LCD的請留意!!!!
	// SRAM 
	.i_Memory_full_flag(memory_full),  	   								
	.sram_start(sram_record_start),											
	.o_reset_all_sram_addr(address_reset),       						
	.o_sram_data(sram_data)												
);



//*********************PLAY********************
PLAY p1(
	.i_rst(DLY_RST),
	.i_clk(AUD_BCLK),
	.i_stop(keydown_rst),
	.i_playorpause(keydown_playorpause),
	.i_spdup(keydown_spdup),
	.i_spddown(keydown_spddown),
	.i_record(SW[0]),
	.i_interpolation(SW[1]),
	
	.o_state(play_state),
	.o_play_speed(play_speed),
	
	.i_aud_DAClrck(AUD_DACLRCK),
	.o_aud_DACdat(AUD_DACDAT),
	
	.o_sram_start(sram_play_start),
	.i_sram_data(SRAM_DQ),
	.i_sram_play_complete(i_sram_play_complete),
	.o_speedup_parameter(speedup_parameter)
);


//*********************SRAM_Communicator*******
	logic [15:0] sram_data;
	logic address_reset;
	logic memory_full;
	logic sram_record_start, sram_play_start;
	logic i_sram_play_complete;
	logic [3:0]speedup_parameter;


SRAMCommunicator s1(
	.i_clk(AUD_BCLK),
	.i_rst(DLY_RST),
	.i_write(SW[0]),
	
	.i_start_play(sram_play_start),
	.i_play_state(play_state),
	.i_speedup_parameter(speedup_parameter),
	
	.i_start_rec(sram_record_start),
	.i_record_rst(address_reset),
	.i_data_write(sram_data),
	
	.o_sram_addr(SRAM_ADDR),
	.o_sram_ce_n(SRAM_CE_N),
    .io_sram_dq(SRAM_DQ),
    .o_sram_lb_n(SRAM_LB_N),
    .o_sram_oe_n(SRAM_OE_N),
    .o_sram_ub_n(SRAM_UB_N),
    .o_sram_we_n(SRAM_WE_N),
	
	.o_full(memory_full),
	.o_play_complete(i_sram_play_complete)
);
//*********************SRAM_Communicator*******







//*********************Debug********************
 //  LCD  
    logic [1:0]rec_state;
    logic [1:0]play_state;
    logic [3:0]play_speed;
//  LCD
    assign LCD_BLON = 0;
    assign LCD_ON = 1;  
	
	localparam	S_STOP          =	0;
    localparam	S_REC	        =	1;
    localparam	S_PLAY	        =	2;
    localparam	S_PAUSE_REC	    =	3;
    localparam  S_PAUSE_PLAY    =   4;
    logic [2:0]ST;
    always_comb begin
        if(SW[0] == 1) begin
            case(rec_state)
                0:    ST = S_STOP;  
                1:    ST = S_REC;  
                2:    ST = S_PAUSE_REC; 
			 default:    ST = S_STOP;
            endcase
        end
        else begin
            case(play_state)
                0:   ST = S_STOP;
                1:   ST = S_PLAY;
			    2:   ST = S_PLAY;
                3:   ST = S_PAUSE_PLAY;                
            endcase
        end
	end
    LCD_SHOW lcd0(
        .iCLK(AUD_BCLK), 
        .iRST_N(DLY_RST),
        .iST(ST),
        .iSPEED(play_speed),
        .LCD_DATA(LCD_DATA),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_EN(LCD_EN)
);

// Seven Decoder
SevenDecoder sevendecoder(
	.i_dec_rec(rec_state),
	.o_dec_rec_seven(HEX0),
	.i_dec_pla(play_state),
	.o_dec_pla_seven(HEX1),
	.i_dec_key(i_sram_play_complete),
	.o_dec_key_seven(HEX2),
	.i_dec_sw(SW[0]),
	.o_dec_sw_seven(HEX3),
	.i_dec_speed(speedup_parameter),
	.o_dec_speed_seven(HEX6),
	.i_hex(play_speed),
	.o_seven_ten(HEX5),
	.o_seven_one(HEX4),
//	.i_play_state(play_state),
//	.i_rec_state(rec_state),
	.o_txt_seven(HEX7)	

);



endmodule

