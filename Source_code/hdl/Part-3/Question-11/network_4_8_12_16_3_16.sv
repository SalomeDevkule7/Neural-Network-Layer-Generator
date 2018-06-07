module network_4_8_12_16_3_16(clk, reset, s_valid, m_ready, data_in, m_valid, s_ready, data_out);
   // this module should instantiate three subnetworks and wire them together
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic  signed [15:0] data_in_1;
   logic  signed [15:0] data_out_1;
    logic m_valid_1, m_ready_1;
    logic m_valid_2, m_ready_2;
    logic s_ready_2,s_ready_3;
   logic  signed [15:0] data_out_2;

layer1_8_4_1_16 mod1(.clk(clk),.reset(reset),.data_in(data_in),.s_valid(s_valid),.s_ready(s_ready),
             .data_out(data_out_1),.m_valid(m_valid_1),.m_ready(m_ready_1));

layer2_12_8_1_16 mod2(.clk(clk),.reset(reset),.data_in(data_out_1),.s_valid(m_valid_1),.s_ready(m_ready_1),
             .data_out(data_out_2),.m_valid(m_valid_2),.m_ready(m_ready_2));

layer3_16_12_1_16 mod3(.clk(clk),.reset(reset),.data_in(data_out_2),.s_valid(m_valid_2),.s_ready(m_ready_2),
             .data_out(data_out),.m_valid(m_valid),.m_ready(m_ready));

endmodule
//****************************************************************************************
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

module mux (out,in1,in2,sel);
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

module mac(clk,reset,out_rom_W,out_rom_B,x_data_out,en,data_out,accum_src);

     input signed [15:0] out_rom_W;
     input signed [15:0] out_rom_B;
     input signed [15:0] x_data_out;
     input en;
     input accum_src;
     input clk,reset; 
     output logic  signed [15:0] data_out;
     logic  signed [15:0] mult_out;
     logic  signed [15:0]adder_out;
     logic  signed [15:0]mux_out;
     logic  signed [15:0]pipe_out;
     logic  signed [15:0]data_out_r;
       logic clear_acc_pipe, enable_pipe;

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

//*****************************************************************************************************************
module layer1_8_4_1_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [-1:0] sel_out;
   logic [5:0] addr_W;
   logic [2:0] addr_B;
   logic [2:0] addr_X;
   mvm_controlpath_layer1_8_4_1_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer1_8_4_1_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer1_8_4_1_16_W_rom0(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd4;
        1: z <= -16'd100;
        2: z <= 16'd76;
        3: z <= 16'd21;
        4: z <= 16'd39;
        5: z <= 16'd18;
        6: z <= -16'd80;
        7: z <= 16'd36;
        8: z <= -16'd116;
        9: z <= 16'd106;
        10: z <= -16'd13;
        11: z <= -16'd3;
        12: z <= 16'd78;
        13: z <= 16'd48;
        14: z <= 16'd39;
        15: z <= 16'd127;
        16: z <= 16'd110;
        17: z <= 16'd11;
        18: z <= 16'd96;
        19: z <= -16'd80;
        20: z <= 16'd111;
        21: z <= 16'd76;
        22: z <= 16'd4;
        23: z <= 16'd33;
        24: z <= 16'd43;
        25: z <= 16'd87;
        26: z <= -16'd100;
        27: z <= -16'd124;
        28: z <= 16'd61;
        29: z <= 16'd81;
        30: z <= 16'd17;
        31: z <= -16'd63;
      endcase
   end
endmodule

module layer1_8_4_1_16_B_rom0(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd110;
        1: z <= -16'd35;
        2: z <= 16'd86;
        3: z <= 16'd21;
        4: z <= 16'd111;
        5: z <= -16'd121;
        6: z <= -16'd71;
        7: z <= 16'd124;
      endcase
   end
endmodule

module mvm_datapath_layer1_8_4_1_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [5:0] addr_W;
   input [2:0] addr_B;
   input [2:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [-1:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer1_8_4_1_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer1_8_4_1_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[2:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
  mux1layer1_8_4_1_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out(data_out));

   memory #(16,4,2 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[1:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer1_8_4_1_16(sel_line,data_out0,data_out);
input[-1:0] sel_line;
input signed [15:0]data_out0;
output logic signed [15:0]data_out;
always_comb
begin
	if(sel_line==0)
  		data_out = data_out0;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer1_8_4_1_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[5:0] addr_W;
   output logic[2:0] addr_B;
   output logic [2:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [-1:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=8;
   parameter N=4;
   parameter P=1;
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
           sel_out<=0;
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
                     if(sel_out==P-1) begin 
		          accum_src <= 1;
                  	   m_valid<= 0;
			  sel_out<=0;
			end
			else begin
 				sel_out<=sel_out+1;
			end
                    if(addr_W >= (M*N)/P && sel_out==P-1) begin
                           accum_src <= 0;
                           addr_W <= 0;
                           addr_X <= 0;
                           s_ready <= 0;
                           next_state <= Initial;
                         end
                         else begin
				if(m_ready && sel_out==P-1)   
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
           Data_output:begin 
             if(m_ready) 
			if(sel_out==P-1)begin
                		en=1; 
			end else
				en=0;
               else
           en=0;
    end

       endcase 

      end

endmodule
//*****************************************************************************************************************
module layer2_12_8_1_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [-1:0] sel_out;
   logic [7:0] addr_W;
   logic [3:0] addr_B;
   logic [3:0] addr_X;
   mvm_controlpath_layer2_12_8_1_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer2_12_8_1_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer2_12_8_1_16_W_rom0(clk, addr, z);
   input clk;
   input [6:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd113;
        1: z <= 16'd44;
        2: z <= -16'd7;
        3: z <= 16'd63;
        4: z <= -16'd36;
        5: z <= -16'd95;
        6: z <= 16'd63;
        7: z <= -16'd53;
        8: z <= 16'd44;
        9: z <= 16'd31;
        10: z <= -16'd5;
        11: z <= 16'd27;
        12: z <= -16'd21;
        13: z <= 16'd127;
        14: z <= -16'd68;
        15: z <= -16'd105;
        16: z <= 16'd87;
        17: z <= -16'd40;
        18: z <= -16'd101;
        19: z <= 16'd20;
        20: z <= -16'd86;
        21: z <= 16'd44;
        22: z <= 16'd85;
        23: z <= -16'd104;
        24: z <= -16'd119;
        25: z <= 16'd43;
        26: z <= 16'd45;
        27: z <= 16'd120;
        28: z <= 16'd50;
        29: z <= 16'd102;
        30: z <= 16'd116;
        31: z <= 16'd35;
        32: z <= 16'd19;
        33: z <= -16'd18;
        34: z <= -16'd29;
        35: z <= 16'd111;
        36: z <= 16'd15;
        37: z <= -16'd94;
        38: z <= -16'd70;
        39: z <= -16'd69;
        40: z <= 16'd65;
        41: z <= 16'd54;
        42: z <= 16'd86;
        43: z <= -16'd83;
        44: z <= 16'd53;
        45: z <= -16'd110;
        46: z <= -16'd60;
        47: z <= 16'd12;
        48: z <= -16'd21;
        49: z <= -16'd33;
        50: z <= -16'd96;
        51: z <= 16'd21;
        52: z <= -16'd117;
        53: z <= 16'd117;
        54: z <= 16'd45;
        55: z <= -16'd108;
        56: z <= 16'd33;
        57: z <= -16'd38;
        58: z <= -16'd116;
        59: z <= -16'd45;
        60: z <= -16'd64;
        61: z <= -16'd127;
        62: z <= 16'd119;
        63: z <= 16'd83;
        64: z <= -16'd17;
        65: z <= -16'd38;
        66: z <= 16'd67;
        67: z <= 16'd126;
        68: z <= -16'd4;
        69: z <= 16'd125;
        70: z <= -16'd71;
        71: z <= -16'd67;
        72: z <= 16'd51;
        73: z <= -16'd113;
        74: z <= -16'd22;
        75: z <= -16'd23;
        76: z <= -16'd95;
        77: z <= 16'd46;
        78: z <= 16'd117;
        79: z <= 16'd12;
        80: z <= -16'd115;
        81: z <= -16'd106;
        82: z <= -16'd95;
        83: z <= -16'd104;
        84: z <= -16'd117;
        85: z <= 16'd78;
        86: z <= -16'd84;
        87: z <= 16'd44;
        88: z <= -16'd88;
        89: z <= -16'd71;
        90: z <= -16'd128;
        91: z <= -16'd23;
        92: z <= -16'd70;
        93: z <= 16'd119;
        94: z <= -16'd68;
        95: z <= 16'd41;
      endcase
   end
endmodule

module layer2_12_8_1_16_B_rom0(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd47;
        1: z <= 16'd127;
        2: z <= 16'd39;
        3: z <= 16'd77;
        4: z <= 16'd125;
        5: z <= 16'd96;
        6: z <= -16'd118;
        7: z <= 16'd48;
        8: z <= 16'd111;
        9: z <= -16'd11;
        10: z <= -16'd103;
        11: z <= -16'd112;
      endcase
   end
endmodule

module mvm_datapath_layer2_12_8_1_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [7:0] addr_W;
   input [3:0] addr_B;
   input [3:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [-1:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer2_12_8_1_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[6:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer2_12_8_1_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[3:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
  mux1layer2_12_8_1_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out(data_out));

   memory #(16,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer2_12_8_1_16(sel_line,data_out0,data_out);
input[-1:0] sel_line;
input signed [15:0]data_out0;
output logic signed [15:0]data_out;
always_comb
begin
	if(sel_line==0)
  		data_out = data_out0;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer2_12_8_1_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[7:0] addr_W;
   output logic[3:0] addr_B;
   output logic [3:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [-1:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=12;
   parameter N=8;
   parameter P=1;
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
           sel_out<=0;
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
                     if(sel_out==P-1) begin 
		          accum_src <= 1;
                  	   m_valid<= 0;
			  sel_out<=0;
			end
			else begin
 				sel_out<=sel_out+1;
			end
                    if(addr_W >= (M*N)/P && sel_out==P-1) begin
                           accum_src <= 0;
                           addr_W <= 0;
                           addr_X <= 0;
                           s_ready <= 0;
                           next_state <= Initial;
                         end
                         else begin
				if(m_ready && sel_out==P-1)   
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
           Data_output:begin 
             if(m_ready) 
			if(sel_out==P-1)begin
                		en=1; 
			end else
				en=0;
               else
           en=0;
    end

       endcase 

      end

endmodule
//*****************************************************************************************************************
module layer3_16_12_1_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [-1:0] sel_out;
   logic [8:0] addr_W;
   logic [3:0] addr_B;
   logic [4:0] addr_X;
   mvm_controlpath_layer3_16_12_1_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer3_16_12_1_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer3_16_12_1_16_W_rom0(clk, addr, z);
   input clk;
   input [7:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd93;
        1: z <= -16'd113;
        2: z <= 16'd29;
        3: z <= -16'd79;
        4: z <= -16'd91;
        5: z <= 16'd62;
        6: z <= -16'd55;
        7: z <= -16'd80;
        8: z <= 16'd13;
        9: z <= -16'd10;
        10: z <= 16'd93;
        11: z <= 16'd53;
        12: z <= 16'd47;
        13: z <= 16'd93;
        14: z <= -16'd98;
        15: z <= 16'd105;
        16: z <= 16'd84;
        17: z <= -16'd37;
        18: z <= 16'd18;
        19: z <= -16'd91;
        20: z <= -16'd38;
        21: z <= -16'd71;
        22: z <= 16'd114;
        23: z <= -16'd41;
        24: z <= -16'd103;
        25: z <= 16'd124;
        26: z <= -16'd120;
        27: z <= -16'd120;
        28: z <= -16'd15;
        29: z <= -16'd95;
        30: z <= -16'd104;
        31: z <= 16'd21;
        32: z <= -16'd80;
        33: z <= 16'd53;
        34: z <= 16'd70;
        35: z <= -16'd43;
        36: z <= -16'd12;
        37: z <= -16'd113;
        38: z <= 16'd6;
        39: z <= -16'd127;
        40: z <= 16'd5;
        41: z <= -16'd29;
        42: z <= 16'd54;
        43: z <= -16'd76;
        44: z <= -16'd64;
        45: z <= 16'd85;
        46: z <= -16'd99;
        47: z <= -16'd108;
        48: z <= -16'd80;
        49: z <= 16'd47;
        50: z <= -16'd71;
        51: z <= 16'd10;
        52: z <= 16'd104;
        53: z <= -16'd85;
        54: z <= 16'd98;
        55: z <= -16'd127;
        56: z <= -16'd89;
        57: z <= 16'd106;
        58: z <= -16'd119;
        59: z <= 16'd25;
        60: z <= -16'd117;
        61: z <= -16'd94;
        62: z <= -16'd82;
        63: z <= -16'd68;
        64: z <= 16'd87;
        65: z <= 16'd116;
        66: z <= 16'd17;
        67: z <= -16'd53;
        68: z <= -16'd125;
        69: z <= -16'd105;
        70: z <= -16'd52;
        71: z <= 16'd9;
        72: z <= -16'd6;
        73: z <= -16'd125;
        74: z <= 16'd61;
        75: z <= 16'd58;
        76: z <= 16'd88;
        77: z <= 16'd91;
        78: z <= 16'd78;
        79: z <= -16'd120;
        80: z <= 16'd10;
        81: z <= -16'd121;
        82: z <= 16'd18;
        83: z <= -16'd13;
        84: z <= -16'd78;
        85: z <= -16'd12;
        86: z <= -16'd12;
        87: z <= -16'd38;
        88: z <= -16'd34;
        89: z <= -16'd2;
        90: z <= 16'd115;
        91: z <= -16'd22;
        92: z <= 16'd32;
        93: z <= -16'd95;
        94: z <= 16'd38;
        95: z <= -16'd9;
        96: z <= -16'd107;
        97: z <= -16'd73;
        98: z <= 16'd67;
        99: z <= -16'd104;
        100: z <= -16'd49;
        101: z <= -16'd113;
        102: z <= 16'd33;
        103: z <= 16'd73;
        104: z <= -16'd110;
        105: z <= -16'd33;
        106: z <= 16'd4;
        107: z <= 16'd106;
        108: z <= -16'd70;
        109: z <= -16'd46;
        110: z <= 16'd114;
        111: z <= 16'd68;
        112: z <= -16'd38;
        113: z <= 16'd5;
        114: z <= -16'd73;
        115: z <= 16'd12;
        116: z <= 16'd121;
        117: z <= 16'd44;
        118: z <= 16'd102;
        119: z <= -16'd40;
        120: z <= -16'd86;
        121: z <= 16'd89;
        122: z <= 16'd66;
        123: z <= 16'd74;
        124: z <= 16'd122;
        125: z <= -16'd24;
        126: z <= -16'd63;
        127: z <= -16'd113;
        128: z <= 16'd31;
        129: z <= -16'd124;
        130: z <= -16'd88;
        131: z <= 16'd110;
        132: z <= -16'd108;
        133: z <= 16'd73;
        134: z <= 16'd56;
        135: z <= -16'd90;
        136: z <= -16'd88;
        137: z <= -16'd68;
        138: z <= -16'd111;
        139: z <= -16'd30;
        140: z <= 16'd14;
        141: z <= -16'd125;
        142: z <= -16'd89;
        143: z <= 16'd104;
        144: z <= 16'd8;
        145: z <= -16'd34;
        146: z <= -16'd11;
        147: z <= 16'd2;
        148: z <= -16'd118;
        149: z <= -16'd37;
        150: z <= 16'd90;
        151: z <= -16'd76;
        152: z <= -16'd75;
        153: z <= 16'd28;
        154: z <= 16'd126;
        155: z <= -16'd81;
        156: z <= -16'd124;
        157: z <= -16'd64;
        158: z <= -16'd65;
        159: z <= 16'd35;
        160: z <= -16'd60;
        161: z <= -16'd25;
        162: z <= 16'd18;
        163: z <= -16'd40;
        164: z <= -16'd80;
        165: z <= -16'd54;
        166: z <= -16'd1;
        167: z <= -16'd39;
        168: z <= 16'd6;
        169: z <= 16'd16;
        170: z <= 16'd59;
        171: z <= -16'd108;
        172: z <= 16'd19;
        173: z <= 16'd98;
        174: z <= 16'd125;
        175: z <= -16'd100;
        176: z <= -16'd63;
        177: z <= -16'd14;
        178: z <= 16'd30;
        179: z <= -16'd53;
        180: z <= 16'd77;
        181: z <= -16'd8;
        182: z <= 16'd0;
        183: z <= -16'd126;
        184: z <= -16'd108;
        185: z <= -16'd2;
        186: z <= -16'd78;
        187: z <= -16'd104;
        188: z <= 16'd62;
        189: z <= -16'd15;
        190: z <= 16'd59;
        191: z <= -16'd125;
      endcase
   end
endmodule

module layer3_16_12_1_16_B_rom0(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd88;
        1: z <= -16'd51;
        2: z <= -16'd37;
        3: z <= -16'd120;
        4: z <= 16'd23;
        5: z <= 16'd90;
        6: z <= -16'd31;
        7: z <= -16'd99;
        8: z <= -16'd22;
        9: z <= -16'd99;
        10: z <= -16'd78;
        11: z <= 16'd126;
        12: z <= 16'd127;
        13: z <= -16'd81;
        14: z <= -16'd102;
        15: z <= -16'd64;
      endcase
   end
endmodule

module mvm_datapath_layer3_16_12_1_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [8:0] addr_W;
   input [3:0] addr_B;
   input [4:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [-1:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer3_16_12_1_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[7:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer3_16_12_1_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[3:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
  mux1layer3_16_12_1_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out(data_out));

   memory #(16,12,4 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[3:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer3_16_12_1_16(sel_line,data_out0,data_out);
input[-1:0] sel_line;
input signed [15:0]data_out0;
output logic signed [15:0]data_out;
always_comb
begin
	if(sel_line==0)
  		data_out = data_out0;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer3_16_12_1_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[8:0] addr_W;
   output logic[3:0] addr_B;
   output logic [4:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [-1:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=16;
   parameter N=12;
   parameter P=1;
   logic [5:0] cntr_x;
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
           sel_out<=0;
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
                     if(sel_out==P-1) begin 
		          accum_src <= 1;
                  	   m_valid<= 0;
			  sel_out<=0;
			end
			else begin
 				sel_out<=sel_out+1;
			end
                    if(addr_W >= (M*N)/P && sel_out==P-1) begin
                           accum_src <= 0;
                           addr_W <= 0;
                           addr_X <= 0;
                           s_ready <= 0;
                           next_state <= Initial;
                         end
                         else begin
				if(m_ready && sel_out==P-1)   
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
           Data_output:begin 
             if(m_ready) 
			if(sel_out==P-1)begin
                		en=1; 
			end else
				en=0;
               else
           en=0;
    end

       endcase 

      end

endmodule
