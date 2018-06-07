module network_4_8_12_16_10_16(clk, reset, s_valid, m_ready, data_in, m_valid, s_ready, data_out);
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

layer1_8_4_2_16 mod1(.clk(clk),.reset(reset),.data_in(data_in),.s_valid(s_valid),.s_ready(s_ready),
             .data_out(data_out_1),.m_valid(m_valid_1),.m_ready(m_ready_1));

layer2_12_8_4_16 mod2(.clk(clk),.reset(reset),.data_in(data_out_1),.s_valid(m_valid_1),.s_ready(m_ready_1),
             .data_out(data_out_2),.m_valid(m_valid_2),.m_ready(m_ready_2));

layer3_16_12_4_16 mod3(.clk(clk),.reset(reset),.data_in(data_out_2),.s_valid(m_valid_2),.s_ready(m_ready_2),
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
module layer1_8_4_2_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
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
   logic [4:0] addr_W;
   logic [1:0] addr_B;
   logic [2:0] addr_X;
   mvm_controlpath_layer1_8_4_2_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer1_8_4_2_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer1_8_4_2_16_W_rom0(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd100;
        1: z <= -16'd14;
        2: z <= -16'd17;
        3: z <= 16'd90;
        4: z <= 16'd23;
        5: z <= 16'd28;
        6: z <= 16'd81;
        7: z <= 16'd77;
        8: z <= -16'd48;
        9: z <= 16'd101;
        10: z <= -16'd50;
        11: z <= 16'd33;
        12: z <= 16'd55;
        13: z <= 16'd92;
        14: z <= -16'd32;
        15: z <= 16'd107;
      endcase
   end
endmodule

module layer1_8_4_2_16_W_rom1(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd125;
        1: z <= -16'd82;
        2: z <= -16'd51;
        3: z <= 16'd86;
        4: z <= -16'd107;
        5: z <= -16'd47;
        6: z <= -16'd65;
        7: z <= 16'd113;
        8: z <= 16'd32;
        9: z <= -16'd106;
        10: z <= 16'd76;
        11: z <= -16'd52;
        12: z <= -16'd43;
        13: z <= -16'd107;
        14: z <= 16'd92;
        15: z <= -16'd15;
      endcase
   end
endmodule

module layer1_8_4_2_16_B_rom0(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd7;
        1: z <= -16'd52;
        2: z <= -16'd6;
        3: z <= -16'd38;
      endcase
   end
endmodule

module layer1_8_4_2_16_B_rom1(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd53;
        1: z <= 16'd4;
        2: z <= 16'd25;
        3: z <= -16'd111;
      endcase
   end
endmodule

module mvm_datapath_layer1_8_4_2_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [4:0] addr_W;
   input [1:0] addr_B;
   input [2:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [0:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer1_8_4_2_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer1_8_4_2_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer1_8_4_2_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer1_8_4_2_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
  mux1layer1_8_4_2_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out(data_out));

   memory #(16,4,2 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[1:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer1_8_4_2_16(sel_line,data_out0,data_out1,data_out);
input[0:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
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
module mvm_controlpath_layer1_8_4_2_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[4:0] addr_W;
   output logic[1:0] addr_B;
   output logic [2:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [0:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=8;
   parameter N=4;
   parameter P=2;
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
module layer2_12_8_4_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
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
   mvm_controlpath_layer2_12_8_4_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer2_12_8_4_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer2_12_8_4_16_W_rom0(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd74;
        1: z <= -16'd84;
        2: z <= 16'd94;
        3: z <= -16'd53;
        4: z <= -16'd3;
        5: z <= -16'd98;
        6: z <= -16'd68;
        7: z <= 16'd77;
        8: z <= 16'd119;
        9: z <= 16'd85;
        10: z <= -16'd60;
        11: z <= -16'd12;
        12: z <= 16'd115;
        13: z <= 16'd1;
        14: z <= -16'd63;
        15: z <= 16'd118;
        16: z <= 16'd4;
        17: z <= -16'd10;
        18: z <= 16'd83;
        19: z <= -16'd9;
        20: z <= 16'd119;
        21: z <= -16'd108;
        22: z <= -16'd18;
        23: z <= -16'd125;
      endcase
   end
endmodule

module layer2_12_8_4_16_W_rom1(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd125;
        1: z <= 16'd10;
        2: z <= -16'd18;
        3: z <= 16'd36;
        4: z <= 16'd33;
        5: z <= -16'd70;
        6: z <= 16'd112;
        7: z <= -16'd40;
        8: z <= -16'd117;
        9: z <= 16'd47;
        10: z <= 16'd26;
        11: z <= 16'd44;
        12: z <= 16'd105;
        13: z <= 16'd10;
        14: z <= -16'd124;
        15: z <= -16'd128;
        16: z <= 16'd67;
        17: z <= -16'd120;
        18: z <= 16'd47;
        19: z <= 16'd45;
        20: z <= 16'd19;
        21: z <= 16'd52;
        22: z <= 16'd45;
        23: z <= -16'd18;
      endcase
   end
endmodule

module layer2_12_8_4_16_W_rom2(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd105;
        1: z <= -16'd48;
        2: z <= -16'd61;
        3: z <= -16'd20;
        4: z <= -16'd27;
        5: z <= -16'd96;
        6: z <= 16'd94;
        7: z <= 16'd108;
        8: z <= 16'd91;
        9: z <= -16'd56;
        10: z <= -16'd19;
        11: z <= -16'd64;
        12: z <= -16'd24;
        13: z <= -16'd53;
        14: z <= -16'd83;
        15: z <= 16'd83;
        16: z <= 16'd124;
        17: z <= -16'd102;
        18: z <= 16'd46;
        19: z <= -16'd28;
        20: z <= -16'd27;
        21: z <= 16'd91;
        22: z <= -16'd73;
        23: z <= 16'd90;
      endcase
   end
endmodule

module layer2_12_8_4_16_W_rom3(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd21;
        1: z <= -16'd86;
        2: z <= -16'd16;
        3: z <= 16'd101;
        4: z <= 16'd67;
        5: z <= 16'd75;
        6: z <= 16'd118;
        7: z <= 16'd121;
        8: z <= -16'd11;
        9: z <= 16'd29;
        10: z <= 16'd57;
        11: z <= -16'd72;
        12: z <= -16'd24;
        13: z <= 16'd47;
        14: z <= -16'd78;
        15: z <= -16'd33;
        16: z <= -16'd7;
        17: z <= 16'd112;
        18: z <= -16'd109;
        19: z <= 16'd97;
        20: z <= 16'd32;
        21: z <= -16'd59;
        22: z <= -16'd63;
        23: z <= -16'd92;
      endcase
   end
endmodule

module layer2_12_8_4_16_B_rom0(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd59;
        1: z <= -16'd87;
        2: z <= -16'd110;
      endcase
   end
endmodule

module layer2_12_8_4_16_B_rom1(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd108;
        1: z <= -16'd118;
        2: z <= -16'd27;
      endcase
   end
endmodule

module layer2_12_8_4_16_B_rom2(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd28;
        1: z <= 16'd54;
        2: z <= 16'd25;
      endcase
   end
endmodule

module layer2_12_8_4_16_B_rom3(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd51;
        1: z <= 16'd108;
        2: z <= 16'd37;
      endcase
   end
endmodule

module mvm_datapath_layer2_12_8_4_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
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
   layer2_12_8_4_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer2_12_8_4_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer2_12_8_4_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer2_12_8_4_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer2_12_8_4_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer2_12_8_4_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer2_12_8_4_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[4:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer2_12_8_4_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
  mux1layer2_12_8_4_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out(data_out));

   memory #(16,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer2_12_8_4_16(sel_line,data_out0,data_out1,data_out2,data_out3,data_out);
input[1:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
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
module mvm_controlpath_layer2_12_8_4_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
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
   parameter M=12;
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
//*****************************************************************************************************************
module layer3_16_12_4_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
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
   logic [6:0] addr_W;
   logic [1:0] addr_B;
   logic [4:0] addr_X;
   mvm_controlpath_layer3_16_12_4_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer3_16_12_4_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer3_16_12_4_16_W_rom0(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd103;
        1: z <= -16'd57;
        2: z <= -16'd109;
        3: z <= -16'd107;
        4: z <= -16'd31;
        5: z <= 16'd66;
        6: z <= -16'd7;
        7: z <= 16'd71;
        8: z <= 16'd29;
        9: z <= 16'd49;
        10: z <= 16'd33;
        11: z <= -16'd106;
        12: z <= -16'd2;
        13: z <= -16'd90;
        14: z <= -16'd16;
        15: z <= 16'd76;
        16: z <= -16'd88;
        17: z <= 16'd88;
        18: z <= -16'd62;
        19: z <= -16'd76;
        20: z <= 16'd118;
        21: z <= 16'd37;
        22: z <= -16'd46;
        23: z <= -16'd6;
        24: z <= -16'd101;
        25: z <= 16'd22;
        26: z <= -16'd15;
        27: z <= -16'd111;
        28: z <= 16'd12;
        29: z <= -16'd80;
        30: z <= 16'd99;
        31: z <= 16'd16;
        32: z <= -16'd68;
        33: z <= -16'd76;
        34: z <= -16'd42;
        35: z <= 16'd13;
        36: z <= 16'd124;
        37: z <= 16'd68;
        38: z <= 16'd77;
        39: z <= 16'd84;
        40: z <= -16'd77;
        41: z <= -16'd93;
        42: z <= -16'd80;
        43: z <= 16'd7;
        44: z <= 16'd51;
        45: z <= 16'd50;
        46: z <= 16'd87;
        47: z <= 16'd22;
      endcase
   end
endmodule

module layer3_16_12_4_16_W_rom1(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd33;
        1: z <= 16'd52;
        2: z <= 16'd120;
        3: z <= -16'd63;
        4: z <= 16'd121;
        5: z <= -16'd71;
        6: z <= -16'd26;
        7: z <= 16'd53;
        8: z <= -16'd51;
        9: z <= -16'd126;
        10: z <= -16'd24;
        11: z <= -16'd10;
        12: z <= 16'd34;
        13: z <= -16'd106;
        14: z <= -16'd105;
        15: z <= 16'd101;
        16: z <= 16'd110;
        17: z <= 16'd73;
        18: z <= 16'd10;
        19: z <= 16'd7;
        20: z <= 16'd117;
        21: z <= 16'd118;
        22: z <= 16'd62;
        23: z <= 16'd82;
        24: z <= -16'd59;
        25: z <= 16'd88;
        26: z <= -16'd35;
        27: z <= -16'd4;
        28: z <= 16'd74;
        29: z <= 16'd121;
        30: z <= 16'd91;
        31: z <= 16'd20;
        32: z <= 16'd88;
        33: z <= -16'd18;
        34: z <= -16'd43;
        35: z <= -16'd36;
        36: z <= -16'd65;
        37: z <= -16'd111;
        38: z <= 16'd20;
        39: z <= -16'd29;
        40: z <= 16'd60;
        41: z <= 16'd35;
        42: z <= -16'd109;
        43: z <= 16'd24;
        44: z <= 16'd21;
        45: z <= -16'd45;
        46: z <= 16'd47;
        47: z <= 16'd60;
      endcase
   end
endmodule

module layer3_16_12_4_16_W_rom2(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd116;
        1: z <= -16'd98;
        2: z <= -16'd29;
        3: z <= -16'd98;
        4: z <= 16'd3;
        5: z <= 16'd124;
        6: z <= 16'd68;
        7: z <= 16'd29;
        8: z <= -16'd61;
        9: z <= 16'd87;
        10: z <= 16'd50;
        11: z <= 16'd37;
        12: z <= -16'd124;
        13: z <= -16'd116;
        14: z <= -16'd47;
        15: z <= 16'd70;
        16: z <= -16'd47;
        17: z <= -16'd111;
        18: z <= 16'd1;
        19: z <= 16'd80;
        20: z <= -16'd73;
        21: z <= 16'd114;
        22: z <= 16'd28;
        23: z <= -16'd33;
        24: z <= -16'd44;
        25: z <= 16'd16;
        26: z <= 16'd2;
        27: z <= -16'd48;
        28: z <= 16'd98;
        29: z <= 16'd13;
        30: z <= -16'd70;
        31: z <= 16'd126;
        32: z <= -16'd93;
        33: z <= 16'd43;
        34: z <= -16'd113;
        35: z <= 16'd48;
        36: z <= 16'd106;
        37: z <= -16'd44;
        38: z <= -16'd87;
        39: z <= -16'd39;
        40: z <= -16'd41;
        41: z <= -16'd110;
        42: z <= 16'd18;
        43: z <= -16'd45;
        44: z <= 16'd86;
        45: z <= -16'd32;
        46: z <= -16'd89;
        47: z <= -16'd119;
      endcase
   end
endmodule

module layer3_16_12_4_16_W_rom3(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd25;
        1: z <= -16'd84;
        2: z <= -16'd20;
        3: z <= -16'd73;
        4: z <= 16'd93;
        5: z <= -16'd115;
        6: z <= -16'd51;
        7: z <= -16'd2;
        8: z <= 16'd66;
        9: z <= -16'd59;
        10: z <= 16'd64;
        11: z <= 16'd59;
        12: z <= 16'd74;
        13: z <= 16'd94;
        14: z <= 16'd19;
        15: z <= 16'd65;
        16: z <= 16'd4;
        17: z <= 16'd101;
        18: z <= -16'd69;
        19: z <= -16'd90;
        20: z <= 16'd124;
        21: z <= -16'd46;
        22: z <= -16'd117;
        23: z <= 16'd106;
        24: z <= 16'd91;
        25: z <= 16'd114;
        26: z <= -16'd64;
        27: z <= -16'd105;
        28: z <= -16'd89;
        29: z <= 16'd23;
        30: z <= 16'd37;
        31: z <= -16'd20;
        32: z <= -16'd17;
        33: z <= -16'd126;
        34: z <= 16'd105;
        35: z <= -16'd71;
        36: z <= 16'd3;
        37: z <= -16'd41;
        38: z <= 16'd16;
        39: z <= -16'd74;
        40: z <= -16'd119;
        41: z <= -16'd25;
        42: z <= 16'd76;
        43: z <= -16'd56;
        44: z <= -16'd8;
        45: z <= -16'd32;
        46: z <= 16'd43;
        47: z <= -16'd75;
      endcase
   end
endmodule

module layer3_16_12_4_16_B_rom0(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd125;
        1: z <= -16'd110;
        2: z <= 16'd81;
        3: z <= 16'd16;
      endcase
   end
endmodule

module layer3_16_12_4_16_B_rom1(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd62;
        1: z <= -16'd4;
        2: z <= -16'd2;
        3: z <= 16'd104;
      endcase
   end
endmodule

module layer3_16_12_4_16_B_rom2(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd77;
        1: z <= -16'd43;
        2: z <= -16'd42;
        3: z <= -16'd5;
      endcase
   end
endmodule

module layer3_16_12_4_16_B_rom3(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd25;
        1: z <= 16'd124;
        2: z <= -16'd88;
        3: z <= -16'd25;
      endcase
   end
endmodule

module mvm_datapath_layer3_16_12_4_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [6:0] addr_W;
   input [1:0] addr_B;
   input [4:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [1:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer3_16_12_4_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer3_16_12_4_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer3_16_12_4_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer3_16_12_4_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer3_16_12_4_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer3_16_12_4_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer3_16_12_4_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[5:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer3_16_12_4_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
  mux1layer3_16_12_4_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out(data_out));

   memory #(16,12,4 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[3:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer3_16_12_4_16(sel_line,data_out0,data_out1,data_out2,data_out3,data_out);
input[1:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
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
module mvm_controlpath_layer3_16_12_4_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[6:0] addr_W;
   output logic[1:0] addr_B;
   output logic [4:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [1:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=16;
   parameter N=12;
   parameter P=4;
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
