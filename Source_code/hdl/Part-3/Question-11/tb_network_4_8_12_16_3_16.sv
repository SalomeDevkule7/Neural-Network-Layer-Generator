module tb_network_4_8_12_16_3_16();

   parameter T = 16;
   parameter NUMINPUTVALS = 10000;
   parameter NUMOUTPUTVALS = 40000;
   parameter INFILENAME = "tb_network_4_8_12_16_3_16.in";
   parameter EXPFILENAME = "tb_network_4_8_12_16_3_16.exp";

   logic clk, s_valid, s_ready, m_valid, m_ready, reset;
   logic  [T-1:0] data_in;
   logic signed [T-1:0] data_out;

   logic signed [T-1:0] inValues [NUMINPUTVALS-1:0];
   logic signed [T-1:0] expValues [NUMOUTPUTVALS-1:0];
   logic s;

   initial clk=0;
   always #5 clk = ~clk;
   
   network_4_8_12_16_3_16 dut(clk, reset, s_valid, m_ready, data_in, m_valid, s_ready, data_out);

   logic rb, rb2;
   always begin
      @(posedge clk);
      #1;
      s=std::randomize(rb, rb2);
   end

   logic [31:0] j;

   always @* begin
      if (s_valid == 1)
         data_in = inValues[j];
      else
         data_in = 'x;
   end

   always @* begin
      if ((j>=0) && (j<NUMINPUTVALS) && (rb==1'b1))
         s_valid=1;
      else
         s_valid=0;
   end

   always @(posedge clk) begin
      if (s_valid && s_ready)
         j <= #1 j+1;
   end
  
   logic [31:0] i;
   always @* begin
      if ((i>=0) && (i<NUMOUTPUTVALS) && (rb2==1'b1))
         m_ready = 1;
      else
         m_ready = 0;
   end

   integer errors = 0;

   always @(posedge clk) begin
      if (m_ready && m_valid) begin
         if (data_out !== expValues[i]) begin
            $display($time,,"ERROR: y[%d] = %x; expected value = %x", i, data_out, expValues[i]);
            errors = errors+1;
         end
         i=i+1; 
      end 
   end

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
     $readmemb(INFILENAME, inValues);
     $readmemb(EXPFILENAME, expValues);
     
      j=0; i=0;

      // Before first clock edge, initialize
      m_ready = 0; 
      reset = 0;
   
      // reset
      @(posedge clk); #1; reset = 1; 
      @(posedge clk); #1; reset = 0; 

      wait(i==NUMOUTPUTVALS);
      $display("Simulated %d outputs. Found %d errors.", NUMOUTPUTVALS, errors);
      $finish;
   end


endmodule
