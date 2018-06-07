module layer_8_8_1_20(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [19:0] data_in;
   output logic signed [19:0] data_out;
   output logic m_valid, s_ready;
   logic accum_src, en;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic [7:0] addr_W;
   logic [4:0] addr_B;
   logic [3:0] addr_X;
   mvm_controlpath cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B);
   mvm_datapath datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,accum_src,addr_W,addr_B);
endmodule

module mux(out,in1,in2,sel);
   input signed [19:0] in1;
   input signed [19:0] in2;
   output logic signed [19:0] out;
   input sel;
   logic [19:0] fill_zero;
   assign fill_zero = 8'd0;
   always_comb begin
      if(sel)
        out = {fill_zero,in1};
      else
        out = in2;
   end
endmodule

module layer_8_8_1_20_W_rom(clk, addr, z);
   input clk;
   input [7:0] addr;
   output logic signed [19:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -20'd209;
        1: z <= -20'd195;
        2: z <= 20'd210;
        3: z <= 20'd23;
        4: z <= -20'd424;
        5: z <= -20'd457;
        6: z <= -20'd175;
        7: z <= 20'd88;
        8: z <= -20'd290;
        9: z <= -20'd163;
        10: z <= -20'd279;
        11: z <= -20'd382;
        12: z <= -20'd314;
        13: z <= -20'd52;
        14: z <= 20'd466;
        15: z <= 20'd477;
        16: z <= 20'd227;
        17: z <= -20'd280;
        18: z <= 20'd442;
        19: z <= -20'd323;
        20: z <= 20'd4;
        21: z <= -20'd300;
        22: z <= 20'd180;
        23: z <= -20'd429;
        24: z <= -20'd161;
        25: z <= -20'd27;
        26: z <= 20'd17;
        27: z <= -20'd498;
        28: z <= 20'd224;
        29: z <= 20'd374;
        30: z <= -20'd46;
        31: z <= -20'd497;
        32: z <= -20'd332;
        33: z <= -20'd348;
        34: z <= 20'd38;
        35: z <= -20'd244;
        36: z <= -20'd293;
        37: z <= 20'd376;
        38: z <= 20'd356;
        39: z <= -20'd71;
        40: z <= -20'd299;
        41: z <= -20'd434;
        42: z <= 20'd59;
        43: z <= -20'd101;
        44: z <= 20'd26;
        45: z <= 20'd13;
        46: z <= -20'd136;
        47: z <= -20'd259;
        48: z <= 20'd246;
        49: z <= -20'd205;
        50: z <= -20'd69;
        51: z <= -20'd262;
        52: z <= 20'd7;
        53: z <= -20'd401;
        54: z <= -20'd178;
        55: z <= 20'd358;
        56: z <= 20'd84;
        57: z <= 20'd351;
        58: z <= 20'd372;
        59: z <= -20'd204;
        60: z <= 20'd214;
        61: z <= -20'd186;
        62: z <= -20'd189;
        63: z <= 20'd394;
      endcase
   end
endmodule

module layer_8_8_1_20_B_rom(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [19:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -20'd22;
        1: z <= 20'd362;
        2: z <= -20'd362;
        3: z <= 20'd197;
        4: z <= 20'd226;
        5: z <= 20'd506;
        6: z <= -20'd386;
        7: z <= 20'd439;
      endcase
   end
endmodule

module ff(clk,clear_acc,in,out,enable);
   input clk,clear_acc;
   input signed [19:0] in;
   output logic signed [19:0] out;
   input enable;
   always_ff @(posedge clk) begin
      if(clear_acc)
        out <= 0;
      else if(enable)
        out <= in;
   end
endmodule

module adder(out,in1,in2);
   input signed [19:0] in1;
   input signed [19:0] in2;
   output logic signed [19:0] out;
   always_comb begin
        out = in1 + in2;
   end
endmodule

module memory(clk, data_in, data_out, addr, wr_en);
   parameter WIDTH=20, SIZE=8, LOGSIZE=3;
   input signed [WIDTH-1:0] data_in;
   output logic signed [WIDTH-1:0] data_out;
   input [LOGSIZE-1:0] addr;
   input clk, wr_en;
   logic [SIZE-1:0][WIDTH-1:0] mem;
   always_ff @(posedge clk) begin
        data_out <= mem[addr];
        if(wr_en)
          mem[addr] <= data_in;
   end
endmodule

module mult(out,in1,in2);
   input signed [19:0] in1, in2;
   output logic signed [19:0] out;
   always_comb begin
        out = in1 * in2;
   end
endmodule

module mvm_datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,accum_src,addr_W,addr_B);
   input wr_en_x,clk,reset;
   input [7:0] addr_W;
   input [4:0] addr_B;
   input [3:0] addr_X;
   input accum_src;
   input signed [19:0] data_in;
   input en;
   output logic signed [19:0] data_out;
   logic signed [19:0] adder_data_out;
   logic signed [19:0] mult_out;
   logic signed [19:0] x_data_out;
   logic signed [19:0] adder_out;
   logic signed [19:0] mux_out;
//*************************************************************
   logic signed [19:0] out_rom_W;
   logic signed [19:0] out_rom_B;
   logic signed [19:0] out_rom_r;
//****************PIPELINING***********************************
   logic signed [19:0] pipe_out;
   logic signed [19:0]data_out_r;
   logic clear_acc_pipe, enable_pipe;

//***************ROM MODULE FOR WEIGHTS*************************
   layer_8_8_1_20_W_rom rom_W(.clk(clk),.addr(addr_W),.z(out_rom_W));
//***************ROM MODULE FOR BIAS****************************
   layer_8_8_1_20_B_rom rom_B(.clk(clk),.addr(addr_B),.z(out_rom_B));

//********************Memory x**********************************
   memory #(20,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));
//****************************************************************
   mult multiplier(.out(mult_out),
        .in1(out_rom_W),
        .in2(x_data_out));

//*************Pipelining Stage***********************************
   ff pipe(.clk(clk),
      .clear_acc(clear_acc_pipe),
      .in(mult_out),
      .out(pipe_out),
      .enable(enable_pipe));
   adder a1(.out(adder_out),
         .in1(data_out_r),
         .in2(pipe_out));
//***************************************************************
   mux mux1(.out(mux_out),
        .in2(adder_out),
        .in1(out_rom_B),
        .sel(accum_src));
//******RELU FUNCTION *********************************************
   always @* begin
      if(data_out_r[19]==1)
        data_out <= 0;
      else
        data_out <= data_out_r;
   end

   ff f1(.clk(clk),
      .clear_acc(reset),
      .in(mux_out),
      .out(data_out_r),
      .enable(en));
   assign clear_acc_pipe = 0;
   assign enable_pipe = 1;

endmodule

module mvm_controlpath(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[7:0] addr_W;
   output logic[4:0] addr_B;
   output logic [3:0] addr_X;
   output logic en;
   logic [3:0] next_state;

   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=8;
   parameter N=8;
   logic [4:0] cntr_x;
   logic [3:0] cntr;
   always_ff @(posedge clk) begin
      if(reset == 1) begin
        s_ready <= 0;
        addr_W <= 0;
        addr_B <= 0;
        wr_en_x <= 0;
        en_r <= 1;
        addr_X <= 0;
        accum_src <= 0; //adder_out
        m_valid <= 0;
        cntr_x <= 0;
        cntr <= 0;
        next_state <= Initial;
      end
      else begin
        case(next_state)
        Initial: begin
                   addr_W <= 0;
                   addr_B <= 0;
                   s_ready <= 0;
                   wr_en_x <= 1;
                   addr_X <= 0;
                   accum_src <= 1; //amatrix_out
                   m_valid <= 0;
                   cntr_x <= 0;
                   addr_X <= 0;
                   next_state <= Load_Vector;
                   cntr <= 0;
                 end

        Load_Vector: begin
                       if(s_valid == 1) begin
                         s_ready <= 1;
                          wr_en_x <= 1;
                          accum_src <= 1; //amatrix_out
                         if(addr_X == N-1) begin
                           wr_en_x <= 0;
                           addr_X <= 0;
                           cntr_x <= 0;
                           next_state <= Multiply;
                         s_ready<=0;
                         end
                         else begin
                           cntr_x <= cntr_x + 1;
                            addr_X <= cntr_x;    //Increment address of the memory
                         end
                       end
                       else begin
                          next_state <= Load_Vector;
                       end
                     end

        Multiply: begin
                    if(addr_X == 1) begin
                      accum_src <= 0;
                      addr_B <= addr_B + 1;
                    end
                    if(addr_X >= N) begin
                      next_state <= Idle_pipe2;
                      addr_X <= 0;
                      addr_W <= addr_W;
                    end
                    else begin
                      addr_X <= addr_X +1;
                       addr_W <= addr_W + 1;
                       m_valid<=0;
                    end
                  end

        Idle_pipe2: begin
                     m_valid<= 1;
                      next_state <= Data_output;
                    end

        Data_output: begin
                       if(m_ready) begin
                         accum_src <= 1;
                         m_valid <= 0;
                         if(addr_W >= (M*N)) begin
                           accum_src <= 0;
                           addr_W <= 0;
                           addr_X <= 0;
                           s_ready <= 0;
                           next_state <= Initial;
                         end
                         else begin
                            next_state <= Multiply;
                         end
                       end
                       else begin
                         next_state <= Data_output;
                       end
                     end
        endcase
      end//end of !reset
   end//end of always_ff

   always_comb begin 

     en=en_r; 
     case(next_state) 
     Data_output: begin 
                    if(m_ready) 
                      en=1; 
                    else
                      en=0;
                    end

     endcase 

   end

endmodule
