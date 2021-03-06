module LCD_SHOW(
    input   iCLK, iRST_N,     //Host Side
    input   [2:0] iST,        
    input   [3:0] iSPEED,
    output  [7:0] LCD_DATA,  //LCD1602 Side
    output  LCD_RS, LCD_RW, LCD_EN
);

logic [1:0] state_r, state_w;
logic [5:0] index_r,index_w;
logic [7:0] show_DATA_r, show_DATA_w;
logic [8:0] data_r, data_w;
logic [17:0] delay_r, delay_w;
logic show_Start_r, show_Start_w, show_RS_r, show_RS_w;
wire [8:0] txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9, txt0, num1, num2, num3;
wire show_Done;

localparam S_Start = 0;
localparam S_Wait_Done = 1;
localparam S_Delay = 2;
localparam S_Index_Incr = 3;

parameter   LCD_INTIAL  =   0;
parameter   LCD_LINE1   =   5;
parameter   LCD_CH_LINE =   LCD_LINE1+16;
parameter   LCD_LINE2   =   LCD_LINE1+16+1;
parameter   LUT_SIZE    =   LCD_LINE1+32+1;

always_comb begin
    case(state_r)
        S_Start : begin
            state_w = S_Wait_Done;
        end

        S_Wait_Done : begin
            if(show_Done == 1) begin
                state_w = S_Delay;
            end
            else begin
                state_w = state_r;
            end
        end

        S_Delay : begin
            if(delay_r >= 15'hF6BE) begin
                state_w = S_Index_Incr;
            end
            else begin
                state_w = state_r;
            end
        end

        S_Index_Incr : begin
            state_w = S_Start;
        end
    endcase

    if(state_r == S_Start) begin
        index_w =index_r;
        delay_w = delay_r;

        show_Start_w = 1;
        show_RS_w = data_r[8];
        show_DATA_w = data_r[7:0];
    end

    else if(state_r == S_Wait_Done) begin
        index_w =index_r;
        delay_w = delay_r;
        show_RS_w = show_RS_r;
        show_DATA_w = show_DATA_r;

        if(show_Done) begin
            show_Start_w = 0;
        end
        else begin
           show_Start_w = show_Start_r;
        end
    end

    else if(state_r == S_Delay) begin
        index_w =index_r;
        show_Start_w = show_Start_r;
        show_RS_w = show_RS_r;
        show_DATA_w = show_DATA_r;

        if(delay_r < 15'hF6BE) begin
           delay_w = delay_r + 1;
        end
        else begin
            delay_w = 0;
        end
    end

    else begin
        delay_w = delay_r;
        show_Start_w = show_Start_r;
        show_RS_w = show_RS_r;
        show_DATA_w = show_DATA_r;

        if(index_r < LUT_SIZE) begin
            index_w = index_r + 1;
        end
        else begin
            index_w = 4;
        end
    end
end

always_comb begin
    case(index_r)
        //  Initial
        LCD_INTIAL+0:   data_w  =  9'h038;
        LCD_INTIAL+1:   data_w  =  9'h00C;
        LCD_INTIAL+2:   data_w  =  9'h001;
        LCD_INTIAL+3:   data_w  =  9'h006;
        LCD_INTIAL+4:   data_w  =  9'h080; //  LINE 2
            //  Line 1
        LCD_LINE1+0:    data_w  =  9'h120; //
        LCD_LINE1+1:    data_w  =  txt1;   //  txt1
        LCD_LINE1+2:    data_w  =  txt2;   //  txt2
        LCD_LINE1+3:    data_w  =  txt3;   //  txt3
        LCD_LINE1+4:    data_w  =  txt4;   //  txt4
        LCD_LINE1+5:    data_w  =  txt5;   //  txt5
        LCD_LINE1+6:    data_w  =  txt6;   //  txt6
        LCD_LINE1+7:    data_w  =  9'h120; //
        LCD_LINE1+8:    data_w  =  9'h120; //
        LCD_LINE1+9:    data_w  =  9'h120; //
        LCD_LINE1+10:   data_w  =  9'h120; //
        LCD_LINE1+11:   data_w  =  9'h14D; //  M
        LCD_LINE1+12:   data_w  =  9'h14F; //  O
        LCD_LINE1+13:   data_w  =  9'h144; //  D
        LCD_LINE1+14:   data_w  =  9'h145; //  E
        LCD_LINE1+15:   data_w  =  9'h120; //
        //  Change Line
        LCD_CH_LINE:    data_w  =  9'h0C0; //  LINE 1
        //  Line 2
        LCD_LINE2+0:    data_w  =  9'h120; // 
        LCD_LINE2+1:    data_w  =  num3;   //  num3
        LCD_LINE2+2:    data_w  =  9'h13A; //  :
        LCD_LINE2+3:    data_w  =  num1;   //  num1
        LCD_LINE2+4:    data_w  =  num2;   //  num2
        LCD_LINE2+5:    data_w  =  9'h120; //
        LCD_LINE2+6:    data_w  =  9'h173; //  s
        LCD_LINE2+7:    data_w  =  9'h165; //  e
        LCD_LINE2+8:    data_w  =  9'h163; //  c
        LCD_LINE2+9:    data_w  =  9'h120; //
        LCD_LINE2+10:   data_w  =  9'h120; //
        LCD_LINE2+11:   data_w  =  txt7;   //  txt7
        LCD_LINE2+12:   data_w  =  txt8;   //  txt8
        LCD_LINE2+13:   data_w  =  txt9;   //  txt9
        LCD_LINE2+14:   data_w  =  txt0;   //  txt10
        LCD_LINE2+15:   data_w  =  9'h120; //
        default:        data_w  =  9'h120; //
    endcase
end

LCD_txt lcdtxt0 (
    .iCLK(iCLK),
    .iRST_N(iRST_N),
    .iST(iST),
    .iSPEED(iSPEED),
    .oTx1(txt1),
    .oTx2(txt2),
    .oTx3(txt3),
    .oTx4(txt4),
    .oTx5(txt5),
    .oTx6(txt6),
    .oTx7(txt7),
    .oTx8(txt8),
    .oTx9(txt9),
    .oTx0(txt0),
    .oNu1(num1),
    .oNu2(num2),
    .oNu3(num3)
);

LCD_controller lcdctrl0 (
    .iCLK(iCLK),
    .iRST_N(iRST_N),
    .ctrl_RS(show_RS_r),
    .ctrl_Start(show_Start_r),
    .ctrl_DATA(show_DATA_r),
    .ctrl_Done(show_Done),
    .LCD_DATA(LCD_DATA),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN)
);

always_ff@(posedge iCLK or negedge iRST_N) begin
    if(!iRST_N) begin
        state_r <= S_Start;
        index_r <= 0;
        show_DATA_r <= 0;
        data_r <= 0;
        show_Start_r <= 0;
        show_RS_r <= 0;
        delay_r <= 0;
    end
    else begin
        state_r <= state_w;
        index_r <= index_w;
        show_DATA_r <= show_DATA_w;
        data_r <= data_w;
        show_Start_r <= show_Start_w;
        show_RS_r <= show_RS_w;
        delay_r <= delay_w;
    end
end

endmodule
