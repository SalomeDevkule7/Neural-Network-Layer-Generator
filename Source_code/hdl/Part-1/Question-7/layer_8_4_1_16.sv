module layer_8_4_1_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic accum_src, en;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic [6:0] addr_W;
   logic [4:0] addr_B;
   logic [2:0] addr_X;
   mvm_controlpath cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B);
   mvm_datapath datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,accum_src,addr_W,addr_B);
endmodule

module mux(out,in1,in2,sel);
   input signed [15:0] in1;
   input signed [15:0] in2;
   output logic signed [15:0] out;
   input sel;
   logic [15:0] fill_zero;
   assign fill_zero = 8'd0;
   always_comb begin
      if(sel)
        out = {fill_zero,in1};
      else
        out = in2;
   end
endmodule

module layer_8_4_1_16_W_rom(clk, addr, z);
   input clk;
   input [6:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd20;
        1: z <= -16'd102;
        2: z <= -16'd92;
        3: z <= 16'd52;
        4: z <= 16'd54;
        5: z <= -16'd83;
        6: z <= -16'd51;
        7: z <= 16'd101;
        8: z <= -16'd35;
        9: z <= 16'd65;
        10: z <= -16'd92;
        11: z <= 16'd126;
        12: z <= -16'd87;
        13: z <= -16'd75;
        14: z <= 16'd14;
        15: z <= 16'd107;
        16: z <= 16'd11;
        17: z <= 16'd122;
        18: z <= -16'd14;
        19: z <= -16'd2;
        20: z <= 16'd36;
        21: z <= 16'd111;
        22: z <= -16'd92;
        23: z <= -16'd37;
        24: z <= 16'd69;
        25: z <= 16'd108;
        26: z <= -16'd86;
        27: z <= 16'd94;
        28: z <= -16'd12;
        29: z <= -16'd87;
        30: z <= 16'd125;
        31: z <= 16'd97;
      endcase
   end
endmodule

module layer_8_4_1_16_B_rom(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd60;
        1: z <= -16'd95;
        2: z <= 16'd21;
        3: z <= 16'd122;
        4: z <= -16'd49;
        5: z <= 16'd98;
        6: z <= 16'd95;
        7: z <= 16'd44;
      endcase
   end
endmodule

module ff(clk,clear_acc,in,out,enable);
   input clk,clear_acc;
   input signed [15:0] in;
   output logic signed [15:0] out;
   input enable;
   always_ff @(posedge clk) begin
      if(clear_acc)
        out <= 0;
      else if(enable)
        out <= in;
   end
endmodule

module adder(out,in1,in2);
   input signed [15:0] in1;
   input signed [15:0] in2;
   output logic signed [15:0] out;
   always_comb begin
        out = in1 + in2;
   end
endmodule

module memory(clk, data_in, data_out, addr, wr_en);
   parameter WIDTH=16, SIZE=4, LOGSIZE=2;
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
   input signed [15:0] in1, in2;
   output logic signed [15:0] out;
   always_comb begin
        out = in1 * in2;
   end
endmodule

module mvm_datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,accum_src,addr_W,addr_B);
   input wr_en_x,clk,reset;
   input [6:0] addr_W;
   input [4:0] addr_B;
   input [2:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   input en;
   output logic signed [15:0] data_out;
   logic signed [15:0] adder_data_out;
   logic signed [15:0] mult_out;
   logic signed [15:0] x_data_out;
   logic signed [15:0] adder_out;
   logic signed [15:0] mux_out;
//*************************************************************
   logic signed [15:0] out_rom_W;
   logic signed [15:0] out_rom_B;
   logic signed [15:0] out_rom_r;
//****************PIPELINING***********************************
   logic signed [15:0] pipe_out;
   logic signed [15:0]data_out_r;
   logic clear_acc_pipe, enable_pipe;

//***************ROM MODULE FOR WEIGHTS*************************
   layer_8_4_1_16_W_rom rom_W(.clk(clk),.addr(addr_W),.z(out_rom_W));
//***************ROM MODULE FOR BIAS****************************
   layer_8_4_1_16_B_rom rom_B(.clk(clk),.addr(addr_B),.z(out_rom_B));

//********************Memory x**********************************
   memory #(16,4,2 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[1:0]),
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
      if(data_out_r[15]==1)
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
   output logic[6:0] addr_W;
   output logic[4:0] addr_B;
   output logic [2:0] addr_X;
   output logic en;
   logic [3:0] next_state;

   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=8;
   parameter N=4;
   logic [3:0] cntr_x;
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
