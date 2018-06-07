module layer_16_8_2_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [0:0] sel_out;
   logic [6:0] addr_W;
   logic [2:0] addr_B;
   logic [3:0] addr_X;
   mvm_controlpath cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
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

module layer_16_8_2_16_W_rom0(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd80;
        1: z <= 16'd83;
        2: z <= 16'd33;
        3: z <= -16'd42;
        4: z <= 16'd45;
        5: z <= 16'd62;
        6: z <= -16'd30;
        7: z <= 16'd44;
        8: z <= -16'd33;
        9: z <= -16'd52;
        10: z <= 16'd7;
        11: z <= 16'd48;
        12: z <= -16'd72;
        13: z <= -16'd104;
        14: z <= 16'd35;
        15: z <= -16'd124;
        16: z <= -16'd39;
        17: z <= -16'd62;
        18: z <= 16'd32;
        19: z <= -16'd122;
        20: z <= -16'd127;
        21: z <= -16'd126;
        22: z <= 16'd51;
        23: z <= -16'd62;
        24: z <= 16'd108;
        25: z <= 16'd88;
        26: z <= -16'd96;
        27: z <= -16'd92;
        28: z <= 16'd113;
        29: z <= 16'd68;
        30: z <= -16'd88;
        31: z <= 16'd5;
        32: z <= 16'd72;
        33: z <= -16'd33;
        34: z <= -16'd54;
        35: z <= 16'd73;
        36: z <= -16'd30;
        37: z <= 16'd125;
        38: z <= -16'd117;
        39: z <= -16'd109;
        40: z <= -16'd61;
        41: z <= -16'd72;
        42: z <= -16'd124;
        43: z <= -16'd76;
        44: z <= 16'd124;
        45: z <= -16'd83;
        46: z <= 16'd57;
        47: z <= 16'd121;
        48: z <= 16'd14;
        49: z <= -16'd120;
        50: z <= 16'd52;
        51: z <= 16'd112;
        52: z <= -16'd123;
        53: z <= 16'd64;
        54: z <= -16'd125;
        55: z <= 16'd27;
        56: z <= 16'd17;
        57: z <= 16'd109;
        58: z <= -16'd128;
        59: z <= 16'd13;
        60: z <= -16'd102;
        61: z <= 16'd57;
        62: z <= 16'd6;
        63: z <= 16'd42;
      endcase
   end
endmodule

module layer_16_8_2_16_W_rom1(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd63;
        1: z <= 16'd47;
        2: z <= 16'd102;
        3: z <= -16'd122;
        4: z <= -16'd44;
        5: z <= -16'd8;
        6: z <= -16'd42;
        7: z <= -16'd53;
        8: z <= 16'd20;
        9: z <= -16'd71;
        10: z <= -16'd69;
        11: z <= -16'd33;
        12: z <= -16'd7;
        13: z <= 16'd6;
        14: z <= 16'd33;
        15: z <= -16'd55;
        16: z <= 16'd49;
        17: z <= 16'd25;
        18: z <= -16'd55;
        19: z <= -16'd122;
        20: z <= -16'd111;
        21: z <= 16'd31;
        22: z <= -16'd47;
        23: z <= -16'd16;
        24: z <= 16'd125;
        25: z <= -16'd29;
        26: z <= 16'd100;
        27: z <= -16'd10;
        28: z <= 16'd106;
        29: z <= 16'd5;
        30: z <= 16'd63;
        31: z <= -16'd61;
        32: z <= 16'd22;
        33: z <= -16'd44;
        34: z <= -16'd103;
        35: z <= 16'd39;
        36: z <= 16'd116;
        37: z <= -16'd21;
        38: z <= -16'd105;
        39: z <= 16'd96;
        40: z <= 16'd16;
        41: z <= 16'd30;
        42: z <= -16'd17;
        43: z <= -16'd6;
        44: z <= -16'd93;
        45: z <= -16'd82;
        46: z <= 16'd62;
        47: z <= 16'd107;
        48: z <= -16'd108;
        49: z <= -16'd99;
        50: z <= -16'd62;
        51: z <= -16'd120;
        52: z <= 16'd8;
        53: z <= -16'd39;
        54: z <= 16'd104;
        55: z <= 16'd75;
        56: z <= -16'd41;
        57: z <= 16'd117;
        58: z <= -16'd91;
        59: z <= -16'd5;
        60: z <= -16'd92;
        61: z <= 16'd99;
        62: z <= -16'd26;
        63: z <= 16'd50;
      endcase
   end
endmodule

module layer_16_8_2_16_B_rom0(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd107;
        1: z <= 16'd34;
        2: z <= 16'd91;
        3: z <= 16'd11;
        4: z <= 16'd66;
        5: z <= 16'd120;
        6: z <= -16'd90;
        7: z <= -16'd106;
      endcase
   end
endmodule

module layer_16_8_2_16_B_rom1(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd101;
        1: z <= 16'd112;
        2: z <= 16'd37;
        3: z <= 16'd111;
        4: z <= 16'd77;
        5: z <= -16'd54;
        6: z <= 16'd96;
        7: z <= 16'd56;
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
   parameter WIDTH=16, SIZE=8, LOGSIZE=3;
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

module mvm_datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [6:0] addr_W;
   input [2:0] addr_B;
   input [3:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [0:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer_16_8_2_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer_16_8_2_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[2:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer_16_8_2_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer_16_8_2_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[2:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
  mux1  Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out(data_out));

   memory #(16,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1(sel_line,data_out0,data_out1,data_out);
input[0:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
;
output logic signed [15:0]data_out;
always_comb
begin
	if(sel_line==0)
  		data_out = data_out0;
	else if (sel_line==1)
 			data_out = data_out1;
	else data_out=0;
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

module mvm_controlpath(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[6:0] addr_W;
   output logic[2:0] addr_B;
   output logic [3:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [0:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=16;
   parameter N=8;
   parameter P=2;
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
