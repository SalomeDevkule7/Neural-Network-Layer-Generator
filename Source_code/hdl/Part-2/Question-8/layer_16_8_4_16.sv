module layer_16_8_4_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [1:0] sel_out;
   logic [5:0] addr_W;
   logic [1:0] addr_B;
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

module layer_16_8_4_16_W_rom0(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd53;
        1: z <= -16'd18;
        2: z <= 16'd117;
        3: z <= 16'd82;
        4: z <= -16'd109;
        5: z <= -16'd15;
        6: z <= 16'd117;
        7: z <= 16'd126;
        8: z <= -16'd51;
        9: z <= 16'd34;
        10: z <= -16'd35;
        11: z <= -16'd31;
        12: z <= -16'd109;
        13: z <= -16'd46;
        14: z <= -16'd33;
        15: z <= 16'd124;
        16: z <= -16'd38;
        17: z <= -16'd36;
        18: z <= -16'd63;
        19: z <= -16'd19;
        20: z <= 16'd47;
        21: z <= 16'd32;
        22: z <= -16'd23;
        23: z <= 16'd98;
        24: z <= 16'd72;
        25: z <= 16'd1;
        26: z <= 16'd52;
        27: z <= -16'd9;
        28: z <= -16'd94;
        29: z <= -16'd99;
        30: z <= -16'd39;
        31: z <= -16'd99;
      endcase
   end
endmodule

module layer_16_8_4_16_W_rom1(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd105;
        1: z <= 16'd96;
        2: z <= 16'd123;
        3: z <= 16'd53;
        4: z <= 16'd114;
        5: z <= -16'd109;
        6: z <= -16'd88;
        7: z <= -16'd59;
        8: z <= -16'd77;
        9: z <= -16'd38;
        10: z <= 16'd49;
        11: z <= -16'd91;
        12: z <= -16'd19;
        13: z <= 16'd89;
        14: z <= -16'd21;
        15: z <= 16'd123;
        16: z <= 16'd123;
        17: z <= -16'd102;
        18: z <= -16'd121;
        19: z <= -16'd24;
        20: z <= 16'd115;
        21: z <= -16'd14;
        22: z <= -16'd29;
        23: z <= -16'd50;
        24: z <= -16'd73;
        25: z <= -16'd32;
        26: z <= 16'd5;
        27: z <= -16'd86;
        28: z <= 16'd83;
        29: z <= 16'd105;
        30: z <= -16'd8;
        31: z <= -16'd128;
      endcase
   end
endmodule

module layer_16_8_4_16_W_rom2(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd13;
        1: z <= 16'd2;
        2: z <= -16'd49;
        3: z <= -16'd71;
        4: z <= -16'd121;
        5: z <= -16'd2;
        6: z <= 16'd119;
        7: z <= -16'd120;
        8: z <= -16'd37;
        9: z <= 16'd58;
        10: z <= -16'd76;
        11: z <= -16'd30;
        12: z <= -16'd71;
        13: z <= -16'd85;
        14: z <= -16'd22;
        15: z <= 16'd68;
        16: z <= -16'd83;
        17: z <= 16'd23;
        18: z <= 16'd48;
        19: z <= -16'd26;
        20: z <= 16'd66;
        21: z <= -16'd102;
        22: z <= -16'd86;
        23: z <= 16'd119;
        24: z <= 16'd0;
        25: z <= -16'd88;
        26: z <= -16'd26;
        27: z <= -16'd61;
        28: z <= -16'd61;
        29: z <= 16'd16;
        30: z <= -16'd70;
        31: z <= -16'd111;
      endcase
   end
endmodule

module layer_16_8_4_16_W_rom3(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd11;
        1: z <= -16'd118;
        2: z <= -16'd55;
        3: z <= -16'd58;
        4: z <= -16'd65;
        5: z <= 16'd95;
        6: z <= 16'd45;
        7: z <= 16'd11;
        8: z <= -16'd75;
        9: z <= 16'd51;
        10: z <= -16'd117;
        11: z <= -16'd12;
        12: z <= 16'd18;
        13: z <= 16'd56;
        14: z <= 16'd127;
        15: z <= 16'd96;
        16: z <= 16'd78;
        17: z <= -16'd75;
        18: z <= -16'd20;
        19: z <= -16'd32;
        20: z <= 16'd109;
        21: z <= -16'd21;
        22: z <= -16'd64;
        23: z <= -16'd57;
        24: z <= 16'd70;
        25: z <= 16'd38;
        26: z <= -16'd15;
        27: z <= 16'd51;
        28: z <= -16'd110;
        29: z <= 16'd50;
        30: z <= 16'd123;
        31: z <= 16'd90;
      endcase
   end
endmodule

module layer_16_8_4_16_B_rom0(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd77;
        1: z <= 16'd77;
        2: z <= -16'd118;
        3: z <= 16'd97;
      endcase
   end
endmodule

module layer_16_8_4_16_B_rom1(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd47;
        1: z <= 16'd42;
        2: z <= 16'd120;
        3: z <= 16'd39;
      endcase
   end
endmodule

module layer_16_8_4_16_B_rom2(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd47;
        1: z <= -16'd14;
        2: z <= -16'd81;
        3: z <= 16'd93;
      endcase
   end
endmodule

module layer_16_8_4_16_B_rom3(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd43;
        1: z <= -16'd124;
        2: z <= 16'd93;
        3: z <= -16'd31;
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
   input [5:0] addr_W;
   input [1:0] addr_B;
   input [3:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [1:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer_16_8_4_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer_16_8_4_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer_16_8_4_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer_16_8_4_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer_16_8_4_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer_16_8_4_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer_16_8_4_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer_16_8_4_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
  mux1  Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out(data_out));

   memory #(16,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1(sel_line,data_out0,data_out1,data_out2,data_out3,data_out);
input[1:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
;
output logic signed [15:0]data_out;
always_comb
begin
	if(sel_line==0)
  		data_out = data_out0;
	else if (sel_line==1)
 			data_out = data_out1;
	else if (sel_line==2)
 			data_out = data_out2;
	else if (sel_line==3)
 			data_out = data_out3;
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
   output logic[5:0] addr_W;
   output logic[1:0] addr_B;
   output logic [3:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [1:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=16;
   parameter N=8;
   parameter P=4;
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
