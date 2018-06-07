module network_4_8_12_16_36_16(clk, reset, s_valid, m_ready, data_in, m_valid, s_ready, data_out);
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

layer1_8_4_8_16 mod1(.clk(clk),.reset(reset),.data_in(data_in),.s_valid(s_valid),.s_ready(s_ready),
             .data_out(data_out_1),.m_valid(m_valid_1),.m_ready(m_ready_1));

layer2_12_8_12_16 mod2(.clk(clk),.reset(reset),.data_in(data_out_1),.s_valid(m_valid_1),.s_ready(m_ready_1),
             .data_out(data_out_2),.m_valid(m_valid_2),.m_ready(m_ready_2));

layer3_16_12_16_16 mod3(.clk(clk),.reset(reset),.data_in(data_out_2),.s_valid(m_valid_2),.s_ready(m_ready_2),
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
module layer1_8_4_8_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [2:0] sel_out;
   logic [2:0] addr_W;
   logic [-1:0] addr_B;
   logic [2:0] addr_X;
   mvm_controlpath_layer1_8_4_8_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer1_8_4_8_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer1_8_4_8_16_W_rom0(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd56;
        1: z <= -16'd60;
        2: z <= -16'd80;
        3: z <= -16'd103;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom1(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd98;
        1: z <= -16'd113;
        2: z <= -16'd69;
        3: z <= 16'd14;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom2(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd23;
        1: z <= -16'd87;
        2: z <= -16'd118;
        3: z <= -16'd103;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom3(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd75;
        1: z <= 16'd102;
        2: z <= 16'd7;
        3: z <= 16'd93;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom4(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd53;
        1: z <= 16'd83;
        2: z <= -16'd61;
        3: z <= -16'd75;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom5(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd40;
        1: z <= -16'd20;
        2: z <= 16'd51;
        3: z <= -16'd60;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom6(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd127;
        1: z <= -16'd47;
        2: z <= -16'd20;
        3: z <= 16'd53;
      endcase
   end
endmodule

module layer1_8_4_8_16_W_rom7(clk, addr, z);
   input clk;
   input [1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd19;
        1: z <= 16'd41;
        2: z <= -16'd7;
        3: z <= 16'd53;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom0(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd110;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom1(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd41;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom2(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd78;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom3(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd80;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom4(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd56;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom5(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd119;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom6(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd33;
      endcase
   end
endmodule

module layer1_8_4_8_16_B_rom7(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd94;
      endcase
   end
endmodule

module mvm_datapath_layer1_8_4_8_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [2:0] addr_W;
   input [-1:0] addr_B;
   input [2:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [2:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer1_8_4_8_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer1_8_4_8_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer1_8_4_8_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer1_8_4_8_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer1_8_4_8_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer1_8_4_8_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer1_8_4_8_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer1_8_4_8_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_4;
   logic signed [15:0] data_out4;
   layer1_8_4_8_16_W_rom4 rom_W4(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_4));

   logic signed [15:0] out_rom_B_4;
   layer1_8_4_8_16_B_rom4 rom_B4(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_4));

      mac mac4(clk,reset,out_rom_W_4,out_rom_B_4,x_data_out,en,data_out4,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_5;
   logic signed [15:0] data_out5;
   layer1_8_4_8_16_W_rom5 rom_W5(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_5));

   logic signed [15:0] out_rom_B_5;
   layer1_8_4_8_16_B_rom5 rom_B5(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_5));

      mac mac5(clk,reset,out_rom_W_5,out_rom_B_5,x_data_out,en,data_out5,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_6;
   logic signed [15:0] data_out6;
   layer1_8_4_8_16_W_rom6 rom_W6(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_6));

   logic signed [15:0] out_rom_B_6;
   layer1_8_4_8_16_B_rom6 rom_B6(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_6));

      mac mac6(clk,reset,out_rom_W_6,out_rom_B_6,x_data_out,en,data_out6,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_7;
   logic signed [15:0] data_out7;
   layer1_8_4_8_16_W_rom7 rom_W7(.clk(clk),.addr(addr_W[1:0]),.z(out_rom_W_7));

   logic signed [15:0] out_rom_B_7;
   layer1_8_4_8_16_B_rom7 rom_B7(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_7));

      mac mac7(clk,reset,out_rom_W_7,out_rom_B_7,x_data_out,en,data_out7,accum_src);

//*********************************************************************************************
  mux1layer1_8_4_8_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out4(data_out4),.data_out5(data_out5),.data_out6(data_out6),.data_out7(data_out7),.data_out(data_out));

   memory #(16,4,2 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[1:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer1_8_4_8_16(sel_line,data_out0,data_out1,data_out2,data_out3,data_out4,data_out5,data_out6,data_out7,data_out);
input[2:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
input signed [15:0]data_out4;
input signed [15:0]data_out5;
input signed [15:0]data_out6;
input signed [15:0]data_out7;
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
	else if (sel_line==4)
 			data_out = data_out4;
	else if (sel_line==5)
 			data_out = data_out5;
	else if (sel_line==6)
 			data_out = data_out6;
	else if (sel_line==7)
 			data_out = data_out7;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer1_8_4_8_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[2:0] addr_W;
   output logic[-1:0] addr_B;
   output logic [2:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [2:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=8;
   parameter N=4;
   parameter P=8;
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
module layer2_12_8_12_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [3:0] sel_out;
   logic [3:0] addr_W;
   logic [-1:0] addr_B;
   logic [3:0] addr_X;
   mvm_controlpath_layer2_12_8_12_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer2_12_8_12_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer2_12_8_12_16_W_rom0(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd77;
        1: z <= -16'd23;
        2: z <= -16'd69;
        3: z <= -16'd24;
        4: z <= -16'd49;
        5: z <= 16'd67;
        6: z <= -16'd59;
        7: z <= 16'd26;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom1(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd22;
        1: z <= 16'd9;
        2: z <= 16'd79;
        3: z <= 16'd110;
        4: z <= 16'd117;
        5: z <= 16'd2;
        6: z <= -16'd78;
        7: z <= 16'd118;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom2(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd83;
        1: z <= 16'd31;
        2: z <= 16'd43;
        3: z <= -16'd63;
        4: z <= -16'd56;
        5: z <= -16'd92;
        6: z <= 16'd118;
        7: z <= -16'd74;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom3(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd78;
        1: z <= 16'd69;
        2: z <= -16'd121;
        3: z <= 16'd6;
        4: z <= 16'd78;
        5: z <= -16'd26;
        6: z <= 16'd40;
        7: z <= -16'd127;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom4(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd79;
        1: z <= 16'd100;
        2: z <= -16'd22;
        3: z <= -16'd98;
        4: z <= 16'd39;
        5: z <= 16'd47;
        6: z <= 16'd56;
        7: z <= -16'd67;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom5(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd72;
        1: z <= 16'd7;
        2: z <= -16'd85;
        3: z <= -16'd83;
        4: z <= -16'd119;
        5: z <= -16'd34;
        6: z <= -16'd93;
        7: z <= 16'd93;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom6(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd125;
        1: z <= 16'd79;
        2: z <= -16'd98;
        3: z <= -16'd59;
        4: z <= 16'd115;
        5: z <= -16'd108;
        6: z <= -16'd4;
        7: z <= 16'd65;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom7(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd89;
        1: z <= 16'd3;
        2: z <= -16'd56;
        3: z <= 16'd40;
        4: z <= 16'd105;
        5: z <= 16'd112;
        6: z <= 16'd41;
        7: z <= 16'd56;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom8(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd84;
        1: z <= -16'd109;
        2: z <= 16'd86;
        3: z <= -16'd5;
        4: z <= 16'd67;
        5: z <= 16'd14;
        6: z <= 16'd56;
        7: z <= 16'd123;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom9(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd107;
        1: z <= 16'd100;
        2: z <= -16'd87;
        3: z <= -16'd98;
        4: z <= -16'd62;
        5: z <= -16'd52;
        6: z <= 16'd123;
        7: z <= -16'd65;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom10(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd101;
        1: z <= -16'd103;
        2: z <= 16'd4;
        3: z <= -16'd113;
        4: z <= -16'd82;
        5: z <= -16'd128;
        6: z <= 16'd80;
        7: z <= -16'd121;
      endcase
   end
endmodule

module layer2_12_8_12_16_W_rom11(clk, addr, z);
   input clk;
   input [2:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd3;
        1: z <= -16'd104;
        2: z <= 16'd47;
        3: z <= -16'd20;
        4: z <= -16'd119;
        5: z <= -16'd39;
        6: z <= -16'd92;
        7: z <= 16'd93;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom0(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd20;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom1(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd122;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom2(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd39;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom3(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd81;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom4(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd8;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom5(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd111;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom6(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd85;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom7(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd29;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom8(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd117;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom9(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd44;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom10(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd60;
      endcase
   end
endmodule

module layer2_12_8_12_16_B_rom11(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd73;
      endcase
   end
endmodule

module mvm_datapath_layer2_12_8_12_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [3:0] addr_W;
   input [-1:0] addr_B;
   input [3:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [3:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer2_12_8_12_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer2_12_8_12_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer2_12_8_12_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer2_12_8_12_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer2_12_8_12_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer2_12_8_12_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer2_12_8_12_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer2_12_8_12_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_4;
   logic signed [15:0] data_out4;
   layer2_12_8_12_16_W_rom4 rom_W4(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_4));

   logic signed [15:0] out_rom_B_4;
   layer2_12_8_12_16_B_rom4 rom_B4(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_4));

      mac mac4(clk,reset,out_rom_W_4,out_rom_B_4,x_data_out,en,data_out4,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_5;
   logic signed [15:0] data_out5;
   layer2_12_8_12_16_W_rom5 rom_W5(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_5));

   logic signed [15:0] out_rom_B_5;
   layer2_12_8_12_16_B_rom5 rom_B5(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_5));

      mac mac5(clk,reset,out_rom_W_5,out_rom_B_5,x_data_out,en,data_out5,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_6;
   logic signed [15:0] data_out6;
   layer2_12_8_12_16_W_rom6 rom_W6(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_6));

   logic signed [15:0] out_rom_B_6;
   layer2_12_8_12_16_B_rom6 rom_B6(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_6));

      mac mac6(clk,reset,out_rom_W_6,out_rom_B_6,x_data_out,en,data_out6,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_7;
   logic signed [15:0] data_out7;
   layer2_12_8_12_16_W_rom7 rom_W7(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_7));

   logic signed [15:0] out_rom_B_7;
   layer2_12_8_12_16_B_rom7 rom_B7(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_7));

      mac mac7(clk,reset,out_rom_W_7,out_rom_B_7,x_data_out,en,data_out7,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_8;
   logic signed [15:0] data_out8;
   layer2_12_8_12_16_W_rom8 rom_W8(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_8));

   logic signed [15:0] out_rom_B_8;
   layer2_12_8_12_16_B_rom8 rom_B8(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_8));

      mac mac8(clk,reset,out_rom_W_8,out_rom_B_8,x_data_out,en,data_out8,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_9;
   logic signed [15:0] data_out9;
   layer2_12_8_12_16_W_rom9 rom_W9(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_9));

   logic signed [15:0] out_rom_B_9;
   layer2_12_8_12_16_B_rom9 rom_B9(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_9));

      mac mac9(clk,reset,out_rom_W_9,out_rom_B_9,x_data_out,en,data_out9,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_10;
   logic signed [15:0] data_out10;
   layer2_12_8_12_16_W_rom10 rom_W10(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_10));

   logic signed [15:0] out_rom_B_10;
   layer2_12_8_12_16_B_rom10 rom_B10(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_10));

      mac mac10(clk,reset,out_rom_W_10,out_rom_B_10,x_data_out,en,data_out10,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_11;
   logic signed [15:0] data_out11;
   layer2_12_8_12_16_W_rom11 rom_W11(.clk(clk),.addr(addr_W[2:0]),.z(out_rom_W_11));

   logic signed [15:0] out_rom_B_11;
   layer2_12_8_12_16_B_rom11 rom_B11(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_11));

      mac mac11(clk,reset,out_rom_W_11,out_rom_B_11,x_data_out,en,data_out11,accum_src);

//*********************************************************************************************
  mux1layer2_12_8_12_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out4(data_out4),.data_out5(data_out5),.data_out6(data_out6),.data_out7(data_out7),.data_out8(data_out8),.data_out9(data_out9),.data_out10(data_out10),.data_out11(data_out11),.data_out(data_out));

   memory #(16,8,3 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[2:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer2_12_8_12_16(sel_line,data_out0,data_out1,data_out2,data_out3,data_out4,data_out5,data_out6,data_out7,data_out8,data_out9,data_out10,data_out11,data_out);
input[3:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
input signed [15:0]data_out4;
input signed [15:0]data_out5;
input signed [15:0]data_out6;
input signed [15:0]data_out7;
input signed [15:0]data_out8;
input signed [15:0]data_out9;
input signed [15:0]data_out10;
input signed [15:0]data_out11;
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
	else if (sel_line==4)
 			data_out = data_out4;
	else if (sel_line==5)
 			data_out = data_out5;
	else if (sel_line==6)
 			data_out = data_out6;
	else if (sel_line==7)
 			data_out = data_out7;
	else if (sel_line==8)
 			data_out = data_out8;
	else if (sel_line==9)
 			data_out = data_out9;
	else if (sel_line==10)
 			data_out = data_out10;
	else if (sel_line==11)
 			data_out = data_out11;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer2_12_8_12_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[3:0] addr_W;
   output logic[-1:0] addr_B;
   output logic [3:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [3:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=12;
   parameter N=8;
   parameter P=12;
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
module layer3_16_12_16_16(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);
   input clk, reset,s_valid, m_ready;
   input signed [15:0] data_in;
   output logic signed [15:0] data_out;
   output logic m_valid, s_ready;
   logic wr_en_a;
   logic wr_en_m;
   logic wr_en_x;
   logic accum_src;
   logic en;
     logic [3:0] sel_out;
   logic [4:0] addr_W;
   logic [-1:0] addr_B;
   logic [4:0] addr_X;
   mvm_controlpath_layer3_16_12_16_16  cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   mvm_datapath_layer3_16_12_16_16 datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
endmodule

module layer3_16_12_16_16_W_rom0(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd32;
        1: z <= 16'd55;
        2: z <= -16'd10;
        3: z <= 16'd60;
        4: z <= 16'd81;
        5: z <= 16'd123;
        6: z <= 16'd75;
        7: z <= 16'd127;
        8: z <= 16'd123;
        9: z <= 16'd27;
        10: z <= -16'd122;
        11: z <= -16'd1;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom1(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd52;
        1: z <= 16'd54;
        2: z <= 16'd107;
        3: z <= 16'd61;
        4: z <= -16'd113;
        5: z <= -16'd112;
        6: z <= 16'd26;
        7: z <= -16'd5;
        8: z <= -16'd118;
        9: z <= 16'd115;
        10: z <= 16'd43;
        11: z <= 16'd19;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom2(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd123;
        1: z <= 16'd86;
        2: z <= -16'd80;
        3: z <= 16'd122;
        4: z <= -16'd86;
        5: z <= 16'd108;
        6: z <= -16'd78;
        7: z <= 16'd74;
        8: z <= 16'd36;
        9: z <= 16'd40;
        10: z <= 16'd6;
        11: z <= -16'd11;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom3(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd35;
        1: z <= -16'd47;
        2: z <= -16'd12;
        3: z <= 16'd31;
        4: z <= 16'd109;
        5: z <= -16'd6;
        6: z <= -16'd98;
        7: z <= 16'd33;
        8: z <= -16'd80;
        9: z <= -16'd119;
        10: z <= -16'd34;
        11: z <= -16'd65;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom4(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd103;
        1: z <= 16'd120;
        2: z <= 16'd59;
        3: z <= -16'd92;
        4: z <= 16'd108;
        5: z <= -16'd26;
        6: z <= 16'd55;
        7: z <= 16'd113;
        8: z <= -16'd68;
        9: z <= 16'd103;
        10: z <= 16'd107;
        11: z <= -16'd26;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom5(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd84;
        1: z <= -16'd99;
        2: z <= -16'd80;
        3: z <= -16'd8;
        4: z <= 16'd70;
        5: z <= 16'd55;
        6: z <= 16'd109;
        7: z <= -16'd23;
        8: z <= -16'd120;
        9: z <= -16'd31;
        10: z <= -16'd120;
        11: z <= 16'd117;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom6(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd91;
        1: z <= -16'd90;
        2: z <= 16'd22;
        3: z <= -16'd116;
        4: z <= -16'd80;
        5: z <= 16'd116;
        6: z <= -16'd53;
        7: z <= -16'd55;
        8: z <= 16'd109;
        9: z <= -16'd122;
        10: z <= -16'd19;
        11: z <= 16'd89;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom7(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd20;
        1: z <= -16'd92;
        2: z <= 16'd74;
        3: z <= 16'd40;
        4: z <= -16'd116;
        5: z <= 16'd53;
        6: z <= -16'd114;
        7: z <= 16'd96;
        8: z <= 16'd83;
        9: z <= -16'd65;
        10: z <= -16'd40;
        11: z <= 16'd25;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom8(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd118;
        1: z <= -16'd59;
        2: z <= -16'd126;
        3: z <= 16'd126;
        4: z <= 16'd38;
        5: z <= -16'd117;
        6: z <= 16'd116;
        7: z <= 16'd1;
        8: z <= -16'd79;
        9: z <= 16'd10;
        10: z <= 16'd13;
        11: z <= -16'd31;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom9(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd1;
        1: z <= 16'd89;
        2: z <= 16'd43;
        3: z <= -16'd20;
        4: z <= 16'd95;
        5: z <= -16'd104;
        6: z <= -16'd59;
        7: z <= -16'd52;
        8: z <= -16'd67;
        9: z <= -16'd113;
        10: z <= 16'd116;
        11: z <= -16'd55;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom10(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd68;
        1: z <= -16'd125;
        2: z <= -16'd87;
        3: z <= 16'd23;
        4: z <= -16'd62;
        5: z <= 16'd1;
        6: z <= -16'd80;
        7: z <= -16'd72;
        8: z <= 16'd70;
        9: z <= -16'd77;
        10: z <= -16'd74;
        11: z <= -16'd20;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom11(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd66;
        1: z <= -16'd86;
        2: z <= 16'd109;
        3: z <= -16'd17;
        4: z <= 16'd53;
        5: z <= -16'd5;
        6: z <= 16'd81;
        7: z <= -16'd76;
        8: z <= -16'd44;
        9: z <= -16'd4;
        10: z <= 16'd32;
        11: z <= -16'd77;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom12(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd20;
        1: z <= 16'd101;
        2: z <= -16'd1;
        3: z <= 16'd81;
        4: z <= 16'd116;
        5: z <= -16'd12;
        6: z <= -16'd102;
        7: z <= 16'd56;
        8: z <= -16'd9;
        9: z <= -16'd61;
        10: z <= -16'd48;
        11: z <= 16'd57;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom13(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd68;
        1: z <= 16'd0;
        2: z <= 16'd113;
        3: z <= 16'd10;
        4: z <= 16'd51;
        5: z <= -16'd89;
        6: z <= 16'd118;
        7: z <= 16'd113;
        8: z <= -16'd46;
        9: z <= 16'd100;
        10: z <= -16'd31;
        11: z <= -16'd121;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom14(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd33;
        1: z <= -16'd78;
        2: z <= -16'd69;
        3: z <= 16'd51;
        4: z <= 16'd46;
        5: z <= 16'd91;
        6: z <= 16'd102;
        7: z <= -16'd62;
        8: z <= 16'd64;
        9: z <= -16'd26;
        10: z <= -16'd108;
        11: z <= 16'd52;
      endcase
   end
endmodule

module layer3_16_12_16_16_W_rom15(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd90;
        1: z <= -16'd82;
        2: z <= -16'd20;
        3: z <= -16'd47;
        4: z <= -16'd14;
        5: z <= 16'd60;
        6: z <= -16'd118;
        7: z <= -16'd74;
        8: z <= -16'd67;
        9: z <= 16'd123;
        10: z <= 16'd65;
        11: z <= 16'd112;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom0(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd94;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom1(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd55;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom2(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd98;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom3(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd12;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom4(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd27;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom5(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd61;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom6(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd5;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom7(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd122;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom8(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd11;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom9(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd54;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom10(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd45;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom11(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd93;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom12(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd17;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom13(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd20;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom14(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd27;
      endcase
   end
endmodule

module layer3_16_12_16_16_B_rom15(clk, addr, z);
   input clk;
   input [-1:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd47;
      endcase
   end
endmodule

module mvm_datapath_layer3_16_12_16_16(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);
   input wr_en_x,clk,reset,en;
   input [4:0] addr_W;
   input [-1:0] addr_B;
   input [4:0] addr_X;
   input accum_src;
   input signed [15:0] data_in;
   logic signed [15:0] x_data_out;
   output logic signed [15:0] data_out;
   input [3:0] sel_out;

//*********************************************************************************************
   logic signed [15:0] out_rom_W_0;
   logic signed [15:0] data_out0;
   layer3_16_12_16_16_W_rom0 rom_W0(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_0));

   logic signed [15:0] out_rom_B_0;
   layer3_16_12_16_16_B_rom0 rom_B0(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_0));

      mac mac0(clk,reset,out_rom_W_0,out_rom_B_0,x_data_out,en,data_out0,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_1;
   logic signed [15:0] data_out1;
   layer3_16_12_16_16_W_rom1 rom_W1(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_1));

   logic signed [15:0] out_rom_B_1;
   layer3_16_12_16_16_B_rom1 rom_B1(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_1));

      mac mac1(clk,reset,out_rom_W_1,out_rom_B_1,x_data_out,en,data_out1,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_2;
   logic signed [15:0] data_out2;
   layer3_16_12_16_16_W_rom2 rom_W2(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_2));

   logic signed [15:0] out_rom_B_2;
   layer3_16_12_16_16_B_rom2 rom_B2(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_2));

      mac mac2(clk,reset,out_rom_W_2,out_rom_B_2,x_data_out,en,data_out2,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_3;
   logic signed [15:0] data_out3;
   layer3_16_12_16_16_W_rom3 rom_W3(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_3));

   logic signed [15:0] out_rom_B_3;
   layer3_16_12_16_16_B_rom3 rom_B3(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_3));

      mac mac3(clk,reset,out_rom_W_3,out_rom_B_3,x_data_out,en,data_out3,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_4;
   logic signed [15:0] data_out4;
   layer3_16_12_16_16_W_rom4 rom_W4(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_4));

   logic signed [15:0] out_rom_B_4;
   layer3_16_12_16_16_B_rom4 rom_B4(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_4));

      mac mac4(clk,reset,out_rom_W_4,out_rom_B_4,x_data_out,en,data_out4,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_5;
   logic signed [15:0] data_out5;
   layer3_16_12_16_16_W_rom5 rom_W5(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_5));

   logic signed [15:0] out_rom_B_5;
   layer3_16_12_16_16_B_rom5 rom_B5(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_5));

      mac mac5(clk,reset,out_rom_W_5,out_rom_B_5,x_data_out,en,data_out5,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_6;
   logic signed [15:0] data_out6;
   layer3_16_12_16_16_W_rom6 rom_W6(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_6));

   logic signed [15:0] out_rom_B_6;
   layer3_16_12_16_16_B_rom6 rom_B6(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_6));

      mac mac6(clk,reset,out_rom_W_6,out_rom_B_6,x_data_out,en,data_out6,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_7;
   logic signed [15:0] data_out7;
   layer3_16_12_16_16_W_rom7 rom_W7(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_7));

   logic signed [15:0] out_rom_B_7;
   layer3_16_12_16_16_B_rom7 rom_B7(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_7));

      mac mac7(clk,reset,out_rom_W_7,out_rom_B_7,x_data_out,en,data_out7,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_8;
   logic signed [15:0] data_out8;
   layer3_16_12_16_16_W_rom8 rom_W8(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_8));

   logic signed [15:0] out_rom_B_8;
   layer3_16_12_16_16_B_rom8 rom_B8(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_8));

      mac mac8(clk,reset,out_rom_W_8,out_rom_B_8,x_data_out,en,data_out8,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_9;
   logic signed [15:0] data_out9;
   layer3_16_12_16_16_W_rom9 rom_W9(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_9));

   logic signed [15:0] out_rom_B_9;
   layer3_16_12_16_16_B_rom9 rom_B9(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_9));

      mac mac9(clk,reset,out_rom_W_9,out_rom_B_9,x_data_out,en,data_out9,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_10;
   logic signed [15:0] data_out10;
   layer3_16_12_16_16_W_rom10 rom_W10(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_10));

   logic signed [15:0] out_rom_B_10;
   layer3_16_12_16_16_B_rom10 rom_B10(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_10));

      mac mac10(clk,reset,out_rom_W_10,out_rom_B_10,x_data_out,en,data_out10,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_11;
   logic signed [15:0] data_out11;
   layer3_16_12_16_16_W_rom11 rom_W11(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_11));

   logic signed [15:0] out_rom_B_11;
   layer3_16_12_16_16_B_rom11 rom_B11(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_11));

      mac mac11(clk,reset,out_rom_W_11,out_rom_B_11,x_data_out,en,data_out11,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_12;
   logic signed [15:0] data_out12;
   layer3_16_12_16_16_W_rom12 rom_W12(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_12));

   logic signed [15:0] out_rom_B_12;
   layer3_16_12_16_16_B_rom12 rom_B12(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_12));

      mac mac12(clk,reset,out_rom_W_12,out_rom_B_12,x_data_out,en,data_out12,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_13;
   logic signed [15:0] data_out13;
   layer3_16_12_16_16_W_rom13 rom_W13(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_13));

   logic signed [15:0] out_rom_B_13;
   layer3_16_12_16_16_B_rom13 rom_B13(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_13));

      mac mac13(clk,reset,out_rom_W_13,out_rom_B_13,x_data_out,en,data_out13,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_14;
   logic signed [15:0] data_out14;
   layer3_16_12_16_16_W_rom14 rom_W14(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_14));

   logic signed [15:0] out_rom_B_14;
   layer3_16_12_16_16_B_rom14 rom_B14(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_14));

      mac mac14(clk,reset,out_rom_W_14,out_rom_B_14,x_data_out,en,data_out14,accum_src);

//*********************************************************************************************
   logic signed [15:0] out_rom_W_15;
   logic signed [15:0] data_out15;
   layer3_16_12_16_16_W_rom15 rom_W15(.clk(clk),.addr(addr_W[3:0]),.z(out_rom_W_15));

   logic signed [15:0] out_rom_B_15;
   layer3_16_12_16_16_B_rom15 rom_B15(.clk(clk),.addr(addr_B[-1:0]),.z(out_rom_B_15));

      mac mac15(clk,reset,out_rom_W_15,out_rom_B_15,x_data_out,en,data_out15,accum_src);

//*********************************************************************************************
  mux1layer3_16_12_16_16 Mux(.sel_line(sel_out),.data_out0(data_out0),.data_out1(data_out1),.data_out2(data_out2),.data_out3(data_out3),.data_out4(data_out4),.data_out5(data_out5),.data_out6(data_out6),.data_out7(data_out7),.data_out8(data_out8),.data_out9(data_out9),.data_out10(data_out10),.data_out11(data_out11),.data_out12(data_out12),.data_out13(data_out13),.data_out14(data_out14),.data_out15(data_out15),.data_out(data_out));

   memory #(16,12,4 )myMemInstX(.clk(clk),
            .data_in(data_in),
            .data_out(x_data_out),
            .addr(addr_X[3:0]),
            .wr_en(wr_en_x));

 endmodule


module mux1layer3_16_12_16_16(sel_line,data_out0,data_out1,data_out2,data_out3,data_out4,data_out5,data_out6,data_out7,data_out8,data_out9,data_out10,data_out11,data_out12,data_out13,data_out14,data_out15,data_out);
input[3:0] sel_line;
input signed [15:0]data_out0;
input signed [15:0]data_out1;
input signed [15:0]data_out2;
input signed [15:0]data_out3;
input signed [15:0]data_out4;
input signed [15:0]data_out5;
input signed [15:0]data_out6;
input signed [15:0]data_out7;
input signed [15:0]data_out8;
input signed [15:0]data_out9;
input signed [15:0]data_out10;
input signed [15:0]data_out11;
input signed [15:0]data_out12;
input signed [15:0]data_out13;
input signed [15:0]data_out14;
input signed [15:0]data_out15;
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
	else if (sel_line==4)
 			data_out = data_out4;
	else if (sel_line==5)
 			data_out = data_out5;
	else if (sel_line==6)
 			data_out = data_out6;
	else if (sel_line==7)
 			data_out = data_out7;
	else if (sel_line==8)
 			data_out = data_out8;
	else if (sel_line==9)
 			data_out = data_out9;
	else if (sel_line==10)
 			data_out = data_out10;
	else if (sel_line==11)
 			data_out = data_out11;
	else if (sel_line==12)
 			data_out = data_out12;
	else if (sel_line==13)
 			data_out = data_out13;
	else if (sel_line==14)
 			data_out = data_out14;
	else if (sel_line==15)
 			data_out = data_out15;
	else data_out=0;
end
endmodule
module mvm_controlpath_layer3_16_12_16_16(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);
   input clk, s_valid, reset, m_ready;
   output logic s_ready, m_valid;
   output logic wr_en_x;
   output logic[4:0] addr_W;
   output logic[-1:0] addr_B;
   output logic [4:0] addr_X;
   output logic en;
   logic [3:0] next_state;

	output logic [3:0] sel_out;
   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;

 logic en_r;
   output logic accum_src;
   parameter M=16;
   parameter N=12;
   parameter P=16;
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
