


#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <assert.h>
#include <math.h>

using namespace std;


void printUsage();
void genLayer(int M, int N, int P, int bits, vector<int>& constvector, string modName, ofstream &os);
void genAllLayers(int N, int M1, int M2, int M3, int mult_budget, int bits, vector<int>& constVector, string modName, ofstream &os);
void readConstants(ifstream &constStream, vector<int>& constvector);
void genROM(vector<int>& constVector, int bits, string modName, ofstream &os);
void genMux(int bits, ofstream &os);
void genFF(int bits, ofstream &os);
void genAdder(int bits, ofstream &os);
void genMemory(int N, int bits, ofstream &os);
void genMult(int bits, ofstream &os);
void genDatapath(int M, int N,int P, int bits, ofstream &os, string romModName_W, string romModName_B,string modName);
void genControlPath(int M, int N,int P, int bits, ofstream &os);
void genMac(int bits, ofstream &os);



int main(int argc, char* argv[]) {


   // If the user runs the program without enough parameters, print a helpful message
   // and quit.
   if (argc < 7) {
      printUsage();
      return 1;
   }


   int mode = atoi(argv[1]);


   ifstream const_file;
   ofstream os;
   vector<int> constVector;


   //----------------------------------------------------------------------
   // Look here for Part 1 and 2
   if ((mode == 1) && (argc == 7)) {
      // Mode 1: Generate one layer with given dimensions and one testbench


      // --------------- read parameters, etc. ---------------
      int M = atoi(argv[2]);
      int N = atoi(argv[3]);
      int P = atoi(argv[4]);
      int bits = atoi(argv[5]);
      const_file.open(argv[6]);
      if (const_file.is_open() != true) {
         cout << "ERROR reading constant file " << argv[6] << endl;
         return 1;
      }

	   if (N <= 1) {
         cout << "ERROR: Enter a value greater than 1 for N" << endl;
         return 1;
      }

      if (bits <= 1) {
         cout << "ERROR: Enter a value greater than 1 for bits" << endl;
         return 1;
      }

      // Read the constants out of the provided file and place them in the constVector vector
      readConstants(const_file, constVector);


      string out_file = "layer_" + to_string(M) + "_" + to_string(N) + "_" + to_string(P) + "_" + to_string(bits) + ".sv";


      os.open(out_file);
      if (os.is_open() != true) {
         cout << "ERROR opening " << out_file << " for write." << endl;
         return 1;
      }
      // -------------------------------------------------------------


      // call the genLayer function you will write to generate this layer
      string modName = "layer_" + to_string(M) + "_" + to_string(N) + "_" + to_string(P) + "_" + to_string(bits);
      genLayer(M, N, P, bits, constVector, modName, os); 


   }
   //--------------------------------------------------------------------




   // ----------------------------------------------------------------
   // Look here for Part 3
   else if ((mode == 2) && (argc == 9)) {
      // Mode 2: Generate three layer with given dimensions and interconnect them


      // --------------- read parameters, etc. ---------------
      int N  = atoi(argv[2]);
      int M1 = atoi(argv[3]);
      int M2 = atoi(argv[4]);
      int M3 = atoi(argv[5]);
      int mult_budget = atoi(argv[6]);
      int bits = atoi(argv[7]);
      const_file.open(argv[8]);
      if (const_file.is_open() != true) {
         cout << "ERROR reading constant file " << argv[8] << endl;
         return 1;
      }
      readConstants(const_file, constVector);


      string out_file = "network_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(mult_budget) + "_" + to_string(bits) + ".sv";




      os.open(out_file);
      if (os.is_open() != true) {
         cout << "ERROR opening " << out_file << " for write." << endl;
         return 1;
      }
      // -------------------------------------------------------------


      string mod_name = "network_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(mult_budget) + "_" + to_string(bits);


      // call the genAllLayers function
      genAllLayers(N, M1, M2, M3, mult_budget, bits, constVector, mod_name, os);


   }
   //-------------------------------------------------------


   else {
      printUsage();
      return 1;
   }


   // close the output stream
   os.close();


}


// Read values from the constant file into the vector
void readConstants(ifstream &constStream, vector<int>& constvector) {
   string constLineString;
   while(getline(constStream, constLineString)) {
      int val = atoi(constLineString.c_str());
      constvector.push_back(val);
   }
}


// Generate a ROM based on values constVector.
// Values should each be "bits" number of bits.
void genROM(vector<int>& constVector, int bits, string modName, ofstream &os) {


      int numWords = constVector.size();
      int addrBits = ceil(log2(numWords));


      os << "module " << modName << "(clk, addr, z);" << endl;
      os << "   input clk;" << endl;
      os << "   input [" << addrBits-1 << ":0] addr;" << endl;
      os << "   output logic signed [" << bits-1 << ":0] z;" << endl;
      os << "   always_ff @(posedge clk) begin" << endl;
      os << "      case(addr)" << endl;
      int i=0;
      for (vector<int>::iterator it = constVector.begin(); it < constVector.end(); it++, i++) {
         if (*it < 0)
            os << "        " << i << ": z <= -" << bits << "'d" << abs(*it) << ";" << endl;
         else
            os << "        " << i << ": z <= "  << bits << "'d" << *it      << ";" << endl;
      }
      os << "      endcase" << endl << "   end" << endl << "endmodule" << endl << endl;
}


// Parts 1 and 2
// Here is where you add your code to produce a neural network layer.
void genLayer(int M, int N, int P, int bits, vector<int>& constVector, string modName, ofstream &os) {


   // Make your module name: layer_M_N_P_bits, where these parameters are replaced with the
   // actual numbers
   int addrBits_W = ceil(log2(M*N/P));
   int addrBits_B = ceil(log2(M/P));
   int addrBits_X = ceil(log2(N));
   int addrBits_sel=ceil(log2(P));
   os << "module " << modName << "(clk,reset,s_valid,m_ready,data_in,m_valid,s_ready,data_out);" << endl;
   os << "   input clk, reset,s_valid, m_ready;" << endl;
   os << "   input signed [" << bits-1 << ":0] data_in;" << endl;
   os << "   output logic signed [" << bits-1 << ":0] data_out;" << endl;
   os << "   output logic m_valid, s_ready;" << endl;
   os << "   logic wr_en_a;" << endl;
   os << "   logic wr_en_m;" << endl;
   os << "   logic wr_en_x;" << endl;
    os << "   logic accum_src;" << endl;
    os << "   logic en;" << endl;
   os<<"     logic ["<<addrBits_sel-1<<":0] sel_out;"<<endl;
   os << "   logic [" << addrBits_W << ":0] addr_W;" << endl;
   os << "   logic [" << addrBits_B-1 << ":0] addr_B;" << endl;
   os << "   logic [" << addrBits_X << ":0] addr_X;" << endl;
   os << "   mvm_controlpath cp(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);" << endl;
   os << "   mvm_datapath datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);" << endl;
   os << "endmodule" << endl << endl;
   
   //Generate Multiplexer module
   genMux(bits, os);


   
   // At some point you will want to generate a ROM with values from the pre-stored constant values.
   // Here is code that demonstrates how to do this for the simple case where you want to put all of
   // the matrix values W in one ROM, and all of the bias values B into another ROM. (This is probably)
   // what you will need for P=1, but you will want to change this for P>1.


   // Check there are enough values in the constant file.
   if (M*N+M > constVector.size()) {
      cout << "ERROR: constVector does not contain enough data for the requested design" << endl;
      cout << "The design parameters requested require " << M*N+M << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
      assert(false);
   }

   /*// Generate a ROM (for W) with constants 0 through M*N-1, with "bits" number of bits
   string romModName = modName + "_W_rom";
   vector<int> wVector(&constVector[0], &constVector[M*N]);
   genROM(wVector, bits, romModName, os);*/
string romModName ="";
for(int count=0; count < P; count++)
{
	romModName = modName + "_W_rom" + to_string(count);
	vector<int> wVector_temp;
	vector<int> wVector;
   	for(int itr=0; itr<M/P; itr++)
	{
		vector<int> wVector_temp(&constVector[N*(P*itr + count)], &constVector[N*(P*itr + count +1)]);
		wVector.insert(wVector.end(), wVector_temp.begin(),wVector_temp.end()); 
   	}
	genROM(wVector, bits, romModName, os);
}
   // Generate a ROM (for B) with constants M*N through M*N+M-1 wits "bits" number of bits 
for(int count=0; count < P; count++)
{
	romModName = modName + "_B_rom" + to_string(count);
	vector<int> bVector_temp;
	vector<int> bVector;
	for(int itr=0; itr<M/P; itr++)
	{
   		vector<int> bVector_temp(&constVector[M*N + P*itr + count], &constVector[M*N + P*itr + count + 1]);
		bVector.insert(bVector.end(), bVector_temp.begin(),bVector_temp.end());
	}

   genROM(bVector, bits, romModName, os);
}
//*******************************************************************************************************
   //Generate flip-flop module
   genFF(bits, os);
   
   //Generate adder module
   genAdder(bits, os);
   
   //Generate memory module for input vector
   genMemory(N, bits, os);
   
   //Generate multiplier module
   genMult(bits, os);
   
   //Generate datapath module
   string romModName_W = modName + "_W_rom";
   string romModName_B = modName + "_B_rom";
   genDatapath(M, N,P,bits, os, romModName_W, romModName_B,modName );
  //Generate Mac module **********************
  genMac( bits,os);
 
  //Generate control path module
   genControlPath(M, N,P, bits, os);


}


// Part 3: Generate a hardware system with three layers interconnected.
// Layer 1: Input length: N, output length: M1
// Layer 2: Input length: M1, output length: M2
// Layer 3: Input length: M2, output length: M3
// mult_budget is the number of multipliers your overall design may use.
// Your goal is to build the fastest design that uses mult_budget or fewer multipliers
// constVector holds all the constants for your system (all three layers, in order)
void genAllLayers(int N, int M1, int M2, int M3, int mult_budget, int bits, vector<int>& constVector, string modName, ofstream &os) {


   // Here you will write code to figure out the best values to use for P1, P2, and P3, given
   // mult_budget. 
   int P1 = 1; // replace this with your optimized value
   int P2 = 1; // replace this with your optimized value
   int P3 = 1; // replace this with your optimized value


   // output top-level module
   // set your top-level name to "network_top"
   os << "module " << modName << "();" << endl;
   os << "   // this module should instantiate three subnetworks and wire them together" << endl;
   os << "endmodule" << endl;
   
   // -------------------------------------------------------------------------
   // Split up constVector for the three layers
   // layer 1's W matrix is M1 x N and its B vector has size M1
   int start = 0;
   int stop = M1*N+M1;
   vector<int> constVector1(&constVector[start], &constVector[stop]);


   // layer 2's W matrix is M2 x M1 and its B vector has size M2
   start = stop;
   stop = start+M2*M1+M2;
   vector<int> constVector2(&constVector[start], &constVector[stop]);


   // layer 3's W matrix is M3 x M2 and its B vector has size M3
   start = stop;
   stop = start+M3*M2+M3;
   vector<int> constVector3(&constVector[start], &constVector[stop]);


   if (stop > constVector.size()) {
      cout << "ERROR: constVector does not contain enough data for the requested design" << endl;
      cout << "The design parameters requested require " << stop << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
      assert(false);
   }
   // --------------------------------------------------------------------------




   // generate the three layer modules
   string subModName = "layer1_" + to_string(M1) + "_" + to_string(N) + "_" + to_string(P1) + "_" + to_string(bits);
   genLayer(M1, N, P1, bits, constVector1, subModName, os);


   subModName = "layer2_" + to_string(M2) + "_" + to_string(M1) + "_" + to_string(P2) + "_" + to_string(bits);
   genLayer(M2, M1, P2, bits, constVector2, subModName, os);


   subModName = "layer3_" + to_string(M3) + "_" + to_string(M2) + "_" + to_string(P3) + "_" + to_string(bits);
   genLayer(M3, M2, P3, bits, constVector3, subModName, os);


   // You will need to add code in the module at the top of this function to stitch together insantiations of these three modules


}




void printUsage() {
  cout << "Usage: ./gen MODE ARGS" << endl << endl;


  cout << "   Mode 1: Produce one neural network layer and testbench (Part 1 and Part 2)" << endl;
  cout << "      ./gen 1 M N P bits const_file" << endl;
  cout << "      Example: produce a neural network layer with a 4 by 5 matrix, with parallelism 1" << endl;
  cout << "               and 16 bit words, with constants stored in file const.txt" << endl;
  cout << "                   ./gen 1 4 5 1 16 const.txt" << endl << endl;


  cout << "   Mode 2: Produce a system with three interconnected layers with four testbenches (Part 3)" << endl;
  cout << "      Arguments: N, M1, M2, M3, mult_budget, bits, const_file" << endl;
  cout << "         Layer 1: M1 x N matrix" << endl;
  cout << "         Layer 2: M2 x M1 matrix" << endl;
  cout << "         Layer 3: M3 x M2 matrix" << endl;
  cout << "              e.g.: ./gen 2 4 5 6 7 15 16 const.txt" << endl << endl;
}




void genMux(int bits, ofstream &os) {


      os << "module mux(out,in1,in2,sel);" << endl;
      os << "   input signed [" << bits-1 << ":0] in1;" << endl;
      os << "   input signed [" << bits-1 << ":0] in2;" << endl;
      os << "   output logic signed [" << bits-1 << ":0] out;" << endl;
      os << "   input sel;" << endl;
      os << "   logic [" << bits-1 << ":0] fill_zero;" << endl;
      os << "   assign fill_zero = 8'd0;" << endl;
      os << "   always_comb begin" << endl;
      os << "      if(sel)" << endl;
      os << "        out = {fill_zero,in1};" << endl;
      os << "      else" << endl;
      os << "        out = in2;" << endl;
      os << "   end" << endl << "endmodule" << endl << endl;    
}




void genFF(int bits, ofstream &os) {


      os << "module ff(clk,clear_acc,in,out,enable);" << endl;
      os << "   input clk,clear_acc;" << endl;
      os << "   input signed [" << bits-1 << ":0] in;" << endl;
      os << "   output logic signed [" << bits-1 << ":0] out;" << endl;
      os << "   input enable;" << endl;
      os << "   always_ff @(posedge clk) begin" << endl;
      os << "      if(clear_acc)" << endl;
      os << "        out <= 0;" << endl;
      os << "      else if(enable)" << endl;
      os << "        out <= in;" << endl;
      os << "   end" << endl << "endmodule" << endl << endl;
}




void genAdder(int bits, ofstream &os) {


      os << "module adder(out,in1,in2);" << endl;
      os << "   input signed [" << bits-1 << ":0] in1;" << endl;
      os << "   input signed [" << bits-1 << ":0] in2;" << endl;
      os << "   output logic signed [" << bits-1 << ":0] out;" << endl;
      os << "   always_comb begin" << endl;
      os << "        out = in1 + in2;" << endl;
      os << "   end" << endl << "endmodule" << endl << endl;    
}

void genMemory(int N, int bits, ofstream &os) {


      int addrBits = ceil(log2(N));
      os << "module memory(clk, data_in, data_out, addr, wr_en);" << endl;
      os << "   parameter WIDTH=" << bits << ", SIZE=" << N << ", LOGSIZE=" << addrBits << ";" << endl;
      os << "   input signed [WIDTH-1:0] data_in;" << endl;
      os << "   output logic signed [WIDTH-1:0] data_out;" << endl;
      os << "   input [LOGSIZE-1:0] addr;" << endl;
      os << "   input clk, wr_en;" << endl;
      os << "   logic [SIZE-1:0][WIDTH-1:0] mem;" << endl;
      os << "   always_ff @(posedge clk) begin" << endl;
      os << "        data_out <= mem[addr];" << endl;
      os << "        if(wr_en)" << endl;
      os << "          mem[addr] <= data_in;" << endl;
      os << "   end" << endl << "endmodule" << endl << endl;
}




void genMult(int bits, ofstream &os) {


      os << "module mult(out,in1,in2);" << endl;
      os << "   input signed [" << bits-1 << ":0] in1, in2;" << endl;
      os << "   output logic signed [" << bits-1 << ":0] out;" << endl;
      os << "   always_comb begin" << endl;
      os << "        out = in1 * in2;" << endl;
      os << "   end" << endl << "endmodule" << endl << endl;
}

void genDatapath(int M, int N,int P, int bits, ofstream &os, string romModName_W, string romModName_B,string modName) {


      int addrBits_W = ceil(log2(M*N/P));
      int addrBits_B = ceil(log2(M/P));
      int addrBits_X = ceil(log2(N));
      int addrBits_sel=ceil(log2(P));
      os << "module mvm_datapath(wr_en_x,addr_X,data_in,data_out,clk,reset,en,addr_W,addr_B,accum_src,sel_out);" << endl;
      os << "   input wr_en_x,clk,reset,en;" << endl;
	os << "   input [" << addrBits_W << ":0] addr_W;" << endl;
      os << "   input [" << addrBits_B-1 << ":0] addr_B;" << endl;
      os << "   input [" << addrBits_X << ":0] addr_X;" << endl;
      os << "   input accum_src;" << endl; 
      os << "   input signed [" << bits-1 << ":0] data_in;" << endl;
      os << "   logic signed [" << bits-1 << ":0] x_data_out;" << endl;
           
	os << "   output logic signed [" << bits-1 << ":0] data_out;" << endl;	
	os<< "   input ["<<addrBits_sel-1<<":0] sel_out;"<<endl<<endl;
      
os<<"//*********************************************************************************************"<<endl;
	string romModName ="";

//**************************LAYER ***********************************************     
	for(int count=0;count<P;count++){
	
      
	os << "   logic signed [" << bits-1 << ":0] out_rom_W_"<<count<<";" << endl;
	os << "   logic signed [" << bits-1 << ":0] data_out"<<count<<";" << endl;


	romModName_W = modName + "_W_rom" + to_string(count);
	//romModName_W=romModName_W+to_string(count);
	os << "   " << romModName_W << " rom_W"<<count<<"(.clk(clk),.addr(addr_W"<<"["<<addrBits_W-1<<":0]),.z(out_rom_W_"<<count<<"));" << 		endl<<endl;
//*****************************************************************************************************
	
	os << "   logic signed [" << bits-1 << ":0] out_rom_B_"<<count<<";" << endl;
	romModName_B = modName + "_B_rom" + to_string(count);	
	//romModName_B=romModName_B+to_string(count);
	os << "   " << romModName_B <<" rom_B"<<count<<"(.clk(clk),.addr(addr_B"<<"["<<addrBits_B-1<<":0]),.z(out_rom_B_"<<count<<"));" << 		endl<<endl;
//**********************************************************************************************
   os<<"      mac mac"<<count<<"(clk,reset,out_rom_W_"<<count<<",out_rom_B_"<<count<<",x_data_out,en,data_out"<<count<<",accum_src);"<<endl<<endl;	
os<<"//*********************************************************************************************"<<endl;
	
}
	os<<"  mux1  Mux(.sel_line(sel_out),";
	for(int count=0; count < P; count++)
	{ 
	os<< ".data_out"<<count<<"(data_out"<<count<<"),";
	}
	os<<".data_out(data_out));"<<endl<<endl;


	os << "   memory #(" << bits << "," << N << "," << addrBits_X << " )myMemInstX(.clk(clk)," << endl
            <<"            .data_in(data_in)," << endl
            <<"            .data_out(x_data_out)," << endl
            <<"            .addr(addr_X[" <<addrBits_X-1<< ":0])," << endl
            <<"            .wr_en(wr_en_x));" << endl<<endl;
       
///****************************************************
	 os<<" endmodule"<<endl<<endl<<endl;
os <<"module mux1(sel_line,";
for(int count=0; count < P; count++)
{ 
	os<< "data_out"<<count<<",";
}
os<<"data_out);"<<endl;

os << "input["<<addrBits_sel-1<<":0] sel_line;"<<endl;

for(int count=0; count < P; count++)
{ 
	os <<"input signed ["<<bits-1<<":0]data_out"<<count<<";" <<endl;
} 
os<< ";"<<endl;
os <<"output logic signed ["<<bits -1<<":0]data_out;"<<endl;

os <<"always_comb"<<endl;
	os <<"begin"<<endl;
   	os <<"	if(sel_line==0)"<<endl;
      os <<"  		data_out = data_out0;"<<endl;
for(int count=0; count < P-1; count++)
{
	os <<"	else if (sel_line=="<<count+1<<")"<<endl;
      os <<" 			data_out = data_out"<<count+1<<";"<<endl;
}
 	os <<"	else data_out=0;"<<endl;
	os <<"end"<<endl;
os <<"endmodule"<<endl;





     
}



void genMac(int bits, ofstream &os){

	os<<"module mac(clk,reset,out_rom_W,out_rom_B,x_data_out,en,data_out,accum_src);"<<endl<<endl;
	os<<"     input signed ["<<bits-1<<":0] out_rom_W;"<<endl;
	os<<"     input signed ["<<bits-1<<":0] out_rom_B;"<<endl;
	os<<"     input signed ["<<bits-1<<":0] x_data_out;"<<endl;
	os<<"     input en;"<<endl<<"     input accum_src;"<<endl<<"     input clk,reset; "<<endl;
 	os<<"     output logic  signed ["<<bits-1<<":0] data_out;"<<endl;
 	os<<"     logic  signed ["<<bits-1<<":0] mult_out;"<<endl;
	os<<"     logic  signed ["<<bits-1<<":0]adder_out;"<<endl;
	os<<"     logic  signed ["<<bits-1<<":0]mux_out;"<<endl;
	os<<"     logic  signed ["<<bits-1<<":0]pipe_out;"<<endl;
	os<<"     logic  signed ["<<bits-1<<":0]data_out_r;"<<endl;
	os<<"       logic clear_acc_pipe, enable_pipe;"<<endl<<endl;

	os << "   mult multiplier(.out(mult_out)," << endl
            <<"        .in1(out_rom_W)," << endl
            <<"        .in2(x_data_out));" << endl << endl;
      os << "//*************Pipelining Stage***********************************" << endl;
      os << "   ff pipe(.clk(clk)," << endl
            << "      .clear_acc(clear_acc_pipe)," << endl
            << "      .in(mult_out)," << endl
            << "      .out(pipe_out)," << endl
            << "      .enable(enable_pipe));" << endl;
      os << "   adder a1(.out(adder_out)," << endl
            << "         .in1(data_out_r)," << endl
            << "         .in2(pipe_out));" << endl;
      os << "//***************************************************************" << endl;
      os << "   mux mux1(.out(mux_out)," << endl
            << "        .in2(adder_out)," << endl
            << "        .in1(out_rom_B)," << endl
            << "        .sel(accum_src));" << endl<<endl;
      os << "//******RELU FUNCTION *********************************************" << endl;
      os << "   always @* begin" << endl;
      os << "      if(data_out_r[" << bits-1 << "]==1)" << endl;
      os << "        data_out <= 0;" << endl;
      os << "      else" << endl;
      os << "        data_out <= data_out_r;" << endl;
      
      os << "   end" << endl << endl;
      os << "   ff f1(.clk(clk)," << endl
            << "      .clear_acc(reset)," << endl
            << "      .in(mux_out)," << endl
            << "      .out(data_out_r)," << endl
            << "      .enable(en));" << endl;
      os << "   assign clear_acc_pipe = 0;" << endl;
      os << "   assign enable_pipe = 1;" << endl << endl;
      os << "endmodule" << endl << endl;


}

void genControlPath(int M, int N,int P, int bits, ofstream &os) {


      int addrBits_W = ceil(log2(M*N/P));
      int addrBits_B = ceil(log2(M/P));
      int addrBits_X = ceil(log2(N));	
	int addrBits_sel=ceil(log2(P));

      os << "module mvm_controlpath(clk, s_valid, reset, m_ready, addr_W,addr_X, wr_en_x, m_valid,s_ready,accum_src,en,addr_B,sel_out);" << endl;
      os << "   input clk, s_valid, reset, m_ready;" << endl;
      os << "   output logic s_ready, m_valid;" << endl;
      os << "   output logic wr_en_x;" << endl;
      os << "   output logic[" << addrBits_W << ":0] addr_W;" << endl;
      os << "   output logic[" << addrBits_B-1 << ":0] addr_B;" << endl;
      os << "   output logic [" << addrBits_X << ":0] addr_X;" << endl;
      os << "   output logic en;" << endl;
      os << "   logic [3:0] next_state;" << endl << endl;
      os<<"	output logic ["<<addrBits_sel-1<<":0] sel_out;"<<endl;
      os << "   parameter [2:0] Initial=3'b000, Load_Vector=3'b001, Multiply=3'b010, Data_output=3'b101, Idle=3'b110, Idle_pipe2=3'b111;"  << endl << endl;
      os << " logic en_r;" <<endl;

 
      os << "   output logic accum_src;" << endl;
      os << "   parameter M="<<M<<";" << endl;
     os << "   parameter N="<<N<<";" << endl;
     os << "   parameter P="<<P<<";" << endl;
	 os << "   logic ["<<addrBits_X+1<<":0] cntr_x;" << endl;
      os << "   logic [3:0] cntr;" << endl;
      os << "   always_ff @(posedge clk) begin" << endl;
      os << "      if(reset == 1) begin" << endl;
      os << "        s_ready <= 0;" << endl;
      os << "        addr_W <= 0;" << endl;
      os << "        addr_B <= 0;" << endl;
      os << "        wr_en_x <= 0;" << endl;
      os << "        en_r <= 1;" << endl;
      os << "        addr_X <= 0;" << endl;
      os << "        accum_src <= 0; //adder_out" << endl;
      os << "        m_valid <= 0;" << endl;
      os << "        cntr_x <= 0;" << endl;
      os << "        cntr <= 0;" << endl;
      os<<"           sel_out<=0;"<<endl;
      os << "        next_state <= Initial;" << endl;
      os << "      end" << endl;
      os << "      else begin" << endl;
      os << "        case(next_state)" << endl;
      os << "        Initial: begin" << endl;
      os << "                   addr_W <= 0;" << endl;
      os << "                   addr_B <= 0;" << endl;
      os << "                   s_ready <= 0;" << endl;
      os << "                   wr_en_x <= 1;" << endl;
      os << "                   addr_X <= 0;" << endl;
      os << "                   accum_src <= 1; //amatrix_out" << endl;
      os << "                   m_valid <= 0;" << endl;
      os << "                   cntr_x <= 0;" << endl;
      os << "                   addr_X <= 0;" << endl;
      os << "                   next_state <= Load_Vector;" << endl;
      os << "                   cntr <= 0;" << endl;
      os << "                 end" << endl << endl;
      os << "        Load_Vector: begin" << endl;
      os << "                       if(s_valid == 1) begin" << endl;
      os << "                         s_ready <= 1;" << endl;
      os << "                          wr_en_x <= 1;" << endl;
      os << "                          accum_src <= 1; //amatrix_out" << endl;
      os << "                         if(addr_X == N-1) begin" << endl;
      os << "                           wr_en_x <= 0;" << endl;
      os << "                           addr_X <= 0;" << endl;
      os << "                           cntr_x <= 0;" << endl;
      os << "                           next_state <= Multiply;" << endl;
      os << "                         s_ready<=0;" << endl;
	os << "                         end" << endl;
      
      os << "                         else begin" << endl;
      os << "                           cntr_x <= cntr_x + 1;" << endl;
      os << "                            addr_X <= cntr_x;    //Increment address of the memory" << endl;
      os << "                         end" << endl;
      os << "                       end" << endl;
      os << "                       else begin" << endl;
      os << "                          next_state <= Load_Vector;" << endl;
      os << "                       end" << endl;
      os << "                     end" << endl << endl;
      os << "        Multiply: begin" << endl;
     
      os << "                    if(addr_X == 1) begin" << endl;
      os << "                      accum_src <= 0;" << endl;
      os << "                      addr_B <= addr_B + 1;" << endl;
      os << "                    end" << endl;
      os << "                    if(addr_X >= N) begin" << endl;
      os << "                      next_state <= Idle_pipe2;" << endl;
      os << "                      addr_X <= 0;" << endl;
      os << "                      addr_W <= addr_W;" << endl;
    
      os << "                    end" << endl;
      os << "                    else begin" << endl;
      os << "                      addr_X <= addr_X +1;" << endl;
      os << "                       addr_W <= addr_W + 1;" << endl;
      os << "                       m_valid<=0;" << endl;      
	os << "                    end" << endl;
      os << "                  end" << endl << endl;
      os << "        Idle_pipe2: begin" << endl;
      os << "                     m_valid<= 1;" << endl;
      os << "                      next_state <= Data_output;" << endl;
       os << "                    end" << endl << endl;
      
	os << "        Data_output: begin" << endl;
      os << "            if(m_ready) begin" << endl;
      os<<"                     if(sel_out==P-1) begin "<<endl;
      os<<"		          accum_src <= 1;"<<endl;
      os<<"                  	   m_valid<= 0;" <<endl;
      os<<"			  sel_out<=0;"<<endl;
     				
      os<<"			end" <<endl;
     
	os<<"			else begin"<<endl; 
	os<<" 				sel_out<=sel_out+1;"<<endl;
	os<<"			end"<<endl;	
      os << "                    if(addr_W >= (M*N)/P && sel_out==P-1) begin" << endl;
      os << "                           accum_src <= 0;" << endl;
      os << "                           addr_W <= 0;" << endl;
      os << "                           addr_X <= 0;" << endl;
      os << "                           s_ready <= 0;" << endl;
      os << "                           next_state <= Initial;" << endl;
      os << "                         end" << endl;
      os << "                         else begin" << endl;
      os<<"				if(m_ready && sel_out==P-1)   "<<endl;
      os << "                            next_state <= Multiply;" << endl;
      os << "                         end" << endl;
      os << "                       end" << endl;
      os << "                       else begin" << endl;
      
      os << "                         next_state <= Data_output;" << endl;
      os << "                       end" << endl;
      os << "                     end" << endl;
      os << "        endcase" << endl;
      os << "      end//end of !reset" << endl;
      os << "   end//end of always_ff" << endl<<endl;
	
	os << "always_comb begin " << endl << endl;
	os << "en=en_r; " << endl;
	os << "     case(next_state) " << endl; 
	os << "           Data_output:begin " << endl ;
	os << "             if(m_ready) " << endl ;
	os<<"			if(sel_out==P-1)begin"<<endl;
	os << "                		en=1; " << endl;
	os<<"			end else"<<endl; 
	os<<"				en=0;"<<endl;
	os<<"               else"<<endl<<"           en=0;"<<endl<<"    end"<<endl<<endl ;
	os << "       endcase " << endl<<endl <<"      end"<<endl<<endl<<"endmodule"<<endl;
}

