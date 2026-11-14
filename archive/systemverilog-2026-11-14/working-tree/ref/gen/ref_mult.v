module ref_mult__mult_Bstru
  (input  clk,
   input  rst,
   input  slot,
   input  \a[wr_m1] ,
   input  [4:0] \a[command] ,
   input  \a[s] ,
   input  \a[wr_mach] ,
   input  \a[wr_macl] ,
   input  [31:0] \a[in1] ,
   input  [31:0] \a[in2] ,
   output [31:0] \y[mach] ,
   output [31:0] \y[macl] ,
   output \y[busy] );
  wire [72:0] n17;
  wire [31:0] n19;
  wire [31:0] n20;
  wire n21;
  wire [246:0] this_c;
  reg [246:0] this_r;
  wire [4:0] n38;
  wire n44;
  wire [31:0] n45;
  wire n46;
  wire n48;
  wire [31:0] n49;
  wire [31:0] n50;
  wire n52;
  wire n54;
  wire [15:0] n56;
  wire [15:0] n57;
  wire [14:0] n58;
  wire [15:0] n59;
  wire n60;
  wire n62;
  wire n64;
  wire [14:0] n65;
  wire [15:0] n67;
  wire [15:0] n68;
  wire [14:0] n69;
  wire [14:0] n70;
  wire [14:0] n71;
  wire n72;
  wire n73;
  wire n75;
  wire n77;
  wire n78;
  wire n79;
  wire n80;
  wire [17:0] n82;
  wire [14:0] n83;
  wire [32:0] n84;
  wire n85;
  wire n86;
  wire [31:0] n87;
  wire [32:0] n89;
  wire n90;
  wire n91;
  wire n92;
  wire [1:0] n94;
  wire [30:0] n95;
  wire [32:0] n96;
  wire [32:0] n97;
  wire [32:0] n98;
  wire n99;
  wire n100;
  wire n101;
  wire [30:0] n102;
  wire [31:0] n104;
  wire [31:0] n106;
  wire n108;
  wire n109;
  wire n111;
  wire n112;
  wire [14:0] n113;
  wire [31:0] n115;
  wire [31:0] n116;
  wire n117;
  wire n118;
  wire n119;
  wire [30:0] n120;
  wire [31:0] n122;
  wire [31:0] n124;
  wire n126;
  wire n127;
  wire n129;
  wire n130;
  wire [14:0] n131;
  wire [31:0] n133;
  wire [31:0] n134;
  wire n135;
  wire [31:0] n136;
  wire n138;
  wire [31:0] n141;
  wire n142;
  wire [31:0] n143;
  wire [31:0] n144;
  wire [32:0] n145;
  wire [32:0] n146;
  wire n147;
  wire [30:0] n148;
  wire [32:0] n149;
  wire [32:0] n150;
  wire [14:0] n151;
  wire [47:0] n152;
  wire [31:0] n153;
  wire [111:0] n154;
  wire [102:0] n155;
  wire [246:0] n156;
  wire n157;
  wire n158;
  wire n159;
  wire n160;
  wire n162;
  wire n163;
  wire [63:0] n165;
  wire [63:0] n167;
  wire [63:0] n168;
  wire [63:0] n170;
  wire [63:0] n171;
  wire [246:0] n172;
  wire [31:0] n173;
  wire n175;
  wire [31:0] n181;
  wire [31:0] n183;
  wire [246:0] n184;
  wire [31:0] n185;
  wire [63:0] n186;
  wire [63:0] n187;
  wire [246:0] n188;
  wire [1:0] n189;
  wire n191;
  wire n192;
  wire n193;
  wire [15:0] n194;
  wire n196;
  wire n197;
  wire n199;
  wire [15:0] n200;
  wire n202;
  wire n203;
  wire n206;
  wire n207;
  wire [246:0] n208;
  wire n209;
  wire n210;
  wire [1:0] n211;
  wire n212;
  wire n213;
  wire [2:0] n214;
  wire n216;
  wire n218;
  wire n219;
  wire n221;
  wire n222;
  wire n224;
  wire n225;
  wire n227;
  wire [1:0] n228;
  reg [63:0] n231;
  reg n234;
  wire [2:0] n235;
  wire n237;
  wire n239;
  wire n241;
  wire n242;
  wire n244;
  wire n245;
  wire n247;
  wire n248;
  wire [1:0] n249;
  reg [63:0] n252;
  reg n255;
  wire [63:0] n256;
  wire n257;
  wire n259;
  wire [246:0] n260;
  wire n261;
  wire n262;
  wire [1:0] n263;
  wire [2:0] n265;
  wire n266;
  wire n267;
  wire n269;
  reg [63:0] n271;
  reg n274;
  wire n276;
  reg [63:0] n278;
  reg n281;
  wire [63:0] n282;
  wire n283;
  wire n285;
  wire [2:0] n286;
  reg [63:0] n288;
  reg n301;
  wire [30:0] n303;
  wire [46:0] n304;
  wire [15:0] n305;
  wire [46:0] n306;
  wire [46:0] n307;
  wire [64:0] n308;
  wire [4:0] n309;
  wire n311;
  wire [31:0] n312;
  wire [4:0] n313;
  wire n315;
  wire [4:0] n316;
  wire n318;
  wire n319;
  wire [38:0] n320;
  wire [31:0] n321;
  wire [246:0] n322;
  wire [31:0] n323;
  wire [31:0] n324;
  wire [31:0] n325;
  wire [63:0] n326;
  wire [63:0] n327;
  wire [63:0] n328;
  wire n329;
  wire [31:0] n330;
  wire [31:0] n331;
  wire [31:0] n332;
  wire [95:0] n333;
  wire [95:0] n334;
  wire [95:0] n335;
  wire [6:0] n336;
  wire n337;
  wire n338;
  wire [31:0] n339;
  wire [4:0] n340;
  wire n342;
  wire [4:0] n343;
  wire n345;
  wire n346;
  wire n347;
  wire [246:0] n349;
  wire [4:0] n350;
  wire n352;
  wire n353;
  wire [246:0] n354;
  wire [31:0] n355;
  wire [31:0] n357;
  wire n358;
  wire [31:0] n359;
  wire [31:0] n360;
  wire [31:0] n361;
  wire [31:0] n362;
  wire [31:0] n363;
  wire [31:0] n364;
  wire n366;
  wire n367;
  wire [31:0] n368;
  wire [4:0] n369;
  wire n371;
  wire n372;
  wire [4:0] n373;
  wire n375;
  wire n376;
  wire [4:0] n377;
  wire n379;
  wire n380;
  wire n382;
  wire [31:0] n383;
  wire [31:0] n384;
  wire [31:0] n385;
  wire [31:0] n386;
  wire [31:0] n387;
  wire [4:0] n389;
  wire [1:0] n390;
  wire n391;
  wire n392;
  wire n393;
  wire n394;
  wire [4:0] n396;
  wire [4:0] n397;
  wire n399;
  wire n400;
  wire [1:0] n402;
  wire [4:0] n403;
  wire n405;
  wire n406;
  wire [6:0] n409;
  wire [6:0] n410;
  wire [6:0] n411;
  wire [6:0] n412;
  wire [6:0] n413;
  wire [4:0] n414;
  wire [4:0] n415;
  wire [1:0] n416;
  wire [1:0] n417;
  wire [6:0] n418;
  wire [6:0] n419;
  wire [6:0] n420;
  wire [246:0] n421;
  wire [31:0] n433;
  wire [31:0] n434;
  wire [64:0] n435;
  reg [246:0] n436;
  wire [12:0] n439; // mem_rd
  assign \y[mach]  = n19; //(module output)
  assign \y[macl]  = n20; //(module output)
  assign \y[busy]  = n21; //(module output)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:5:8 */
  assign n17 = {\a[in2] , \a[in1] , \a[wr_macl] , \a[wr_mach] , \a[s] , \a[command] , \a[wr_m1] };
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:5:8 */
  assign n19 = n435[31:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:5:8 */
  assign n20 = n435[63:32]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:5:8 */
  assign n21 = n435[64]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:13:10 */
  assign this_c = n421; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:14:10 */
  always @*
    this_r = n436; // (isignal)
  initial
    this_r = 247'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:33:28 */
  assign n38 = this_r[4:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:34:20 */
  assign n44 = n439[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:36:16 */
  assign n45 = this_r[38:7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:37:13 */
  assign n46 = n439[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:37:18 */
  assign n48 = n46 == 1'b1;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:37:39 */
  assign n49 = this_r[102:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:37:5 */
  assign n50 = n48 ? n49 : n45;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:39:13 */
  assign n52 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:39:18 */
  assign n54 = n52 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:19:12 */
  assign n56 = n50[30:15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:39:5 */
  assign n57 = n54 ? 16'b0000000000000000 : n56;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:19:12 */
  assign n58 = n50[14:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:40:18 */
  assign n59 = this_r[54:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:41:13 */
  assign n60 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:41:18 */
  assign n62 = n60 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:16 */
  assign n64 = n439[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:52 */
  assign n65 = this_r[69:55]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:43 */
  assign n67 = {1'b0, n65};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:5 */
  assign n68 = n64 ? n67 : n59;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:5 */
  assign n69 = n68[14:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:20:12 */
  assign n70 = this_r[53:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:41:5 */
  assign n71 = n62 ? n70 : n69;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:42:5 */
  assign n72 = n68[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:41:5 */
  assign n73 = n62 ? 1'b0 : n72;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:13 */
  assign n75 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:18 */
  assign n77 = n75 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:56 */
  assign n78 = n50[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:72 */
  assign n79 = this_r[54]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:61 */
  assign n80 = n78 & n79;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:51 */
  assign n82 = {17'b00000000000000000, n80};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:88 */
  assign n83 = this_r[229:215]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:78 */
  assign n84 = {n82, n83};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:45:16 */
  assign n85 = this_r[199]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:45:22 */
  assign n86 = ~n85;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:45:55 */
  assign n87 = this_r[246:215]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:45:45 */
  assign n89 = {1'b0, n87};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:27 */
  assign n90 = n50[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:43 */
  assign n91 = this_r[70]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:32 */
  assign n92 = n90 & n91;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:22 */
  assign n94 = {1'b0, n92};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:59 */
  assign n95 = this_r[245:215]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:46:49 */
  assign n96 = {n94, n95};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:45:5 */
  assign n97 = n86 ? n89 : n96;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:44:5 */
  assign n98 = n77 ? n84 : n97;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:10 */
  assign n99 = n50[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:30 */
  assign n100 = n439[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:21 */
  assign n101 = n100 & n99;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:66 */
  assign n102 = this_r[69:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:57 */
  assign n104 = {1'b0, n102};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:49:5 */
  assign n106 = n101 ? n104 : 32'b00000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:10 */
  assign n108 = n50[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:30 */
  assign n109 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:35 */
  assign n111 = n109 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:21 */
  assign n112 = n111 & n108;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:75 */
  assign n113 = this_r[53:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:66 */
  assign n115 = {17'b00000000000000000, n113};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:50:5 */
  assign n116 = n112 ? n115 : n106;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:15 */
  assign n117 = this_r[70]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:35 */
  assign n118 = n439[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:26 */
  assign n119 = n118 & n117;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:66 */
  assign n120 = n50[30:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:62 */
  assign n122 = {1'b0, n120};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:52:5 */
  assign n124 = n119 ? n122 : 32'b00000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:15 */
  assign n126 = this_r[54]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:35 */
  assign n127 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:40 */
  assign n129 = n127 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:26 */
  assign n130 = n129 & n126;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:75 */
  assign n131 = n50[14:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:71 */
  assign n133 = {17'b00000000000000000, n131};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:53:5 */
  assign n134 = n130 ? n133 : n124;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:54:13 */
  assign n135 = n439[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:54:18 */
  assign n136 = {31'b0, n135};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:54:18 */
  assign n138 = n136 == 32'b00000000000000000000000000000001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:54:5 */
  assign n141 = n138 ? 32'b11111111111111111111111111111111 : 32'b00000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:57 */
  assign n142 = n141[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:69 */
  assign n143 = this_r[134:103]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:73 */
  assign n144 = n143 ^ n141;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:61 */
  assign n145 = {n142, n144};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:43 */
  assign n146 = n98 + n145;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:90 */
  assign n147 = n439[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:83 */
  assign n148 = {30'b0, n147};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:83 */
  assign n149 = {2'b0, n148};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:83 */
  assign n150 = n146 + n149;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:106 */
  assign n151 = this_r[214:200]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:55:96 */
  assign n152 = {n150, n151};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:56:47 */
  assign n153 = n116 + n134;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n154 = this_r[246:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n155 = this_r[102:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n156 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:57:13 */
  assign n157 = n156[199]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:57:19 */
  assign n158 = ~n157;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:12 */
  assign n159 = n152[47]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:32 */
  assign n160 = n439[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:37 */
  assign n162 = n160 == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:23 */
  assign n163 = n162 & n159;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:61 */
  assign n165 = {16'b1111111111111111, n152};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:59:25 */
  assign n167 = {16'b0000000000000000, n152};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:58:7 */
  assign n168 = n163 ? n165 : n167;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:60:18 */
  assign n170 = {n152, 16'b0000000000000000};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:57:5 */
  assign n171 = n158 ? n168 : n170;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n172 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:58 */
  assign n173 = n172[166:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:79 */
  assign n175 = n439[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/mult_pkg.vhd:111:9 */
  assign n181 = {n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175, n175};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:63 */
  assign n183 = n173 & n181;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n184 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:98 */
  assign n185 = n184[198:167]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:91 */
  assign n186 = {n183, n185};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:63:41 */
  assign n187 = n171 + n186;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n188 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:66:15 */
  assign n189 = n188[6:5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:67:7 */
  assign n191 = n189 == 2'b00;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:15 */
  assign n192 = n187[63]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:20 */
  assign n193 = ~n192;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:33 */
  assign n194 = n187[62:47]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:48 */
  assign n196 = n194 != 16'b0000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:26 */
  assign n197 = n196 & n193;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:70:18 */
  assign n199 = n187[63]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:70:36 */
  assign n200 = n187[62:47]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:70:51 */
  assign n202 = n200 != 16'b1111111111111111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:70:29 */
  assign n203 = n202 & n199;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:70:9 */
  assign n206 = n203 ? 1'b1 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:69:9 */
  assign n207 = n197 ? 1'b1 : n206;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n208 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:71:40 */
  assign n209 = n208[166]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:71:50 */
  assign n210 = n187[63]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:71:45 */
  assign n211 = {n209, n210};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:72:13 */
  assign n212 = n171[63]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:72:18 */
  assign n213 = ~n212;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:28:12 */
  assign n214 = {n211, n207};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:13 */
  assign n216 = n214 == 3'b001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:24 */
  assign n218 = n214 == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:24 */
  assign n219 = n216 | n218;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:32 */
  assign n221 = n214 == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:32 */
  assign n222 = n219 | n221;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:40 */
  assign n224 = n214 == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:74:40 */
  assign n225 = n222 | n224;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:75:13 */
  assign n227 = n214 == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:73:11 */
  assign n228 = {n227, n225};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:73:11 */
  always @*
    case (n228)
      2'b10: n231 = 64'b1111111111111111100000000000000000000000000000000000000000000000;
      2'b01: n231 = 64'b0000000000000000011111111111111111111111111111111111111111111111;
      default: n231 = n187;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:73:11 */
  always @*
    case (n228)
      2'b10: n234 = 1'b1;
      2'b01: n234 = 1'b1;
      default: n234 = 1'b0;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:28:12 */
  assign n235 = {n211, n207};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:80:13 */
  assign n237 = n235 == 3'b001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:13 */
  assign n239 = n235 == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:24 */
  assign n241 = n235 == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:24 */
  assign n242 = n239 | n241;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:32 */
  assign n244 = n235 == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:32 */
  assign n245 = n242 | n244;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:40 */
  assign n247 = n235 == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:81:40 */
  assign n248 = n245 | n247;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:79:11 */
  assign n249 = {n248, n237};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:79:11 */
  always @*
    case (n249)
      2'b10: n252 = 64'b1111111111111111100000000000000000000000000000000000000000000000;
      2'b01: n252 = 64'b0000000000000000011111111111111111111111111111111111111111111111;
      default: n252 = n187;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:79:11 */
  always @*
    case (n249)
      2'b10: n255 = 1'b1;
      2'b01: n255 = 1'b1;
      default: n255 = 1'b0;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:72:9 */
  assign n256 = n213 ? n231 : n252;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:72:9 */
  assign n257 = n213 ? n234 : n255;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:68:7 */
  assign n259 = n189 == 2'b10;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n260 = {n154, n153, n155};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:86:28 */
  assign n261 = n260[198]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:86:38 */
  assign n262 = n187[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:86:33 */
  assign n263 = {n261, n262};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:86:43 */
  assign n265 = {n263, 1'b0};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:87:13 */
  assign n266 = n171[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:87:18 */
  assign n267 = ~n266;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:89:13 */
  assign n269 = n265 == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:88:11 */
  always @*
    case (n269)
      1'b1: n271 = 64'b0000000000000000000000000000000001111111111111111111111111111111;
      default: n271 = n187;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:88:11 */
  always @*
    case (n269)
      1'b1: n274 = 1'b1;
      default: n274 = 1'b0;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:94:13 */
  assign n276 = n265 == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:93:11 */
  always @*
    case (n276)
      1'b1: n278 = 64'b1111111111111111111111111111111110000000000000000000000000000000;
      default: n278 = n187;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:93:11 */
  always @*
    case (n276)
      1'b1: n281 = 1'b1;
      default: n281 = 1'b0;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:87:9 */
  assign n282 = n267 ? n271 : n278;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:87:9 */
  assign n283 = n267 ? n274 : n281;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:85:7 */
  assign n285 = n189 == 2'b01;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:66:5 */
  assign n286 = {n285, n259, n191};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:66:5 */
  always @*
    case (n286)
      3'b100: n288 = n282;
      3'b010: n288 = n256;
      3'b001: n288 = n187;
      default: n288 = 64'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:66:5 */
  always @*
    case (n286)
      3'b100: n301 = n283;
      3'b010: n301 = n257;
      3'b001: n301 = 1'b0;
      default: n301 = 1'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:19:12 */
  assign n303 = {n57, n58};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:100:47 */
  assign n304 = {16'b0, n303};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:20:12 */
  assign n305 = {n73, n71};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:100:47 */
  assign n306 = {31'b0, n305};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:100:47 */
  assign n307 = n304 * n306; // umul
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n308 = this_r[199:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:103:12 */
  assign n309 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:103:20 */
  assign n311 = n309 != 5'b00000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:104:22 */
  assign n312 = n17[72:41]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:14 */
  assign n313 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:22 */
  assign n315 = n313 == 5'b00111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:34 */
  assign n316 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:42 */
  assign n318 = n316 == 5'b01010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:29 */
  assign n319 = n315 | n318;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n320 = this_r[38:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n321 = this_r[102:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n322 = {n307, n308, n153, n321, n312, n320};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:70 */
  assign n323 = n322[38:7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n324 = this_r[102:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:105:9 */
  assign n325 = n319 ? n323 : n324;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:103:7 */
  assign n326 = {n325, n312};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n327 = this_r[102:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:103:7 */
  assign n328 = n311 ? n326 : n327;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:107:12 */
  assign n329 = n17[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:107:42 */
  assign n330 = n17[40:9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n331 = this_r[38:7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:107:7 */
  assign n332 = n329 ? n330 : n331;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:102:5 */
  assign n333 = {n328, n332};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n334 = this_r[102:7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:102:5 */
  assign n335 = slot ? n333 : n334;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n336 = this_r[6:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:109:25 */
  assign n337 = n17[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:109:19 */
  assign n338 = n337 & slot;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:109:59 */
  assign n339 = n17[40:9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:29 */
  assign n340 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:37 */
  assign n342 = n340 == 5'b00001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:51 */
  assign n343 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:59 */
  assign n345 = n343 == 5'b00100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:46 */
  assign n346 = n342 | n345;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:22 */
  assign n347 = n346 & slot;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n349 = {n307, n308, n153, n335, n336};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:16 */
  assign n350 = n349[4:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:22 */
  assign n352 = n350 == 5'b01101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:31 */
  assign n353 = n301 & n352;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n354 = {n307, n308, n153, n335, n336};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:68 */
  assign n355 = n354[166:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:73 */
  assign n357 = n355 | 32'b00000000000000000000000000000001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:112:16 */
  assign n358 = n439[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:112:51 */
  assign n359 = n288[63:32]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n360 = this_r[166:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:112:5 */
  assign n361 = n358 ? n359 : n360;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:111:5 */
  assign n362 = n353 ? n357 : n361;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:110:5 */
  assign n363 = n347 ? 32'b00000000000000000000000000000000 : n362;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:109:5 */
  assign n364 = n338 ? n339 : n363;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:114:25 */
  assign n366 = n17[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:114:19 */
  assign n367 = n366 & slot;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:114:59 */
  assign n368 = n17[72:41]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:28 */
  assign n369 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:36 */
  assign n371 = n369 != 5'b00000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:22 */
  assign n372 = n371 & slot;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:49 */
  assign n373 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:57 */
  assign n375 = n373 != 5'b00111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:43 */
  assign n376 = n375 & n372;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:71 */
  assign n377 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:79 */
  assign n379 = n377 != 5'b01010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:65 */
  assign n380 = n379 & n376;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:116:16 */
  assign n382 = n439[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:116:51 */
  assign n383 = n288[31:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n384 = this_r[198:167]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:116:5 */
  assign n385 = n382 ? n383 : n384;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:115:5 */
  assign n386 = n380 ? 32'b00000000000000000000000000000000 : n385;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:114:5 */
  assign n387 = n367 ? n368 : n386;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:119:24 */
  assign n389 = n439[4:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n390 = this_r[6:5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:120:24 */
  assign n391 = n439[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:122:13 */
  assign n392 = n439[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:122:18 */
  assign n393 = ~n392;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:122:24 */
  assign n394 = slot & n393;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:124:23 */
  assign n396 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:125:12 */
  assign n397 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:125:20 */
  assign n399 = n397 == 5'b00111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:126:14 */
  assign n400 = n17[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:126:9 */
  assign n402 = n400 ? 2'b10 : 2'b00;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:127:15 */
  assign n403 = n17[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:127:23 */
  assign n405 = n403 == 5'b01010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:128:14 */
  assign n406 = n17[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:128:9 */
  assign n409 = {2'b01, 5'b01100};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n410 = {2'b00, n396};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:128:9 */
  assign n411 = n406 ? n409 : n410;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n412 = {2'b00, n396};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:127:7 */
  assign n413 = n405 ? n411 : n412;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:127:7 */
  assign n414 = n413[4:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:125:7 */
  assign n415 = n399 ? n396 : n414;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:127:7 */
  assign n416 = n413[6:5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:125:7 */
  assign n417 = n399 ? n402 : n416;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:122:5 */
  assign n418 = {n417, n415};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n419 = {n390, n389};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:122:5 */
  assign n420 = n394 ? n418 : n419;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:17:12 */
  assign n421 = {n307, n391, n387, n364, n153, n335, n420};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:142:20 */
  assign n433 = this_r[166:135]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:143:20 */
  assign n434 = this_r[198:167]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:10:3 */
  assign n435 = {n44, n434, n433};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:137:6 */
  always @(posedge clk or posedge rst)
    if (rst)
      n436 <= 247'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    else
      n436 <= this_c;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:33:28 */
  reg [12:0] n437[20:0] ; // memory
  initial begin
    n437[20] = 13'b0100000000000;
    n437[19] = 13'b0000000110100;
    n437[18] = 13'b0100100000000;
    n437[17] = 13'b0000100110010;
    n437[16] = 13'b0101110000000;
    n437[15] = 13'b0101110110000;
    n437[14] = 13'b0001100101111;
    n437[13] = 13'b0100100000000;
    n437[12] = 13'b0000100101101;
    n437[11] = 13'b1110100000000;
    n437[10] = 13'b1000100101011;
    n437[9] = 13'b1111111000000;
    n437[8] = 13'b1111111101001;
    n437[7] = 13'b1001101101000;
    n437[6] = 13'b1111010000000;
    n437[5] = 13'b1111010100110;
    n437[4] = 13'b1001000100101;
    n437[3] = 13'b1111110000000;
    n437[2] = 13'b1111110100011;
    n437[1] = 13'b1001100100010;
    n437[0] = 13'b1000000000000;
    end
  assign n439 = n437[n38];
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/build/ref/pre/mult.vhd:33:28 */
endmodule

module ref_mult
  (input  clk,
   input  rst,
   input  slot,
   input  wr_m1,
   input  [4:0] command,
   input  s,
   input  wr_mach,
   input  wr_macl,
   input  [31:0] in1,
   input  [31:0] in2,
   output [31:0] mach,
   output [31:0] macl,
   output busy);
  wire [72:0] a;
  wire [64:0] y;
  wire [31:0] \u.y[mach] ;
  wire [31:0] \u.y[macl] ;
  wire \u.y[busy] ;
  wire n4;
  wire [4:0] n5;
  wire n6;
  wire n7;
  wire n8;
  wire [31:0] n9;
  wire [31:0] n10;
  wire [64:0] n11;
  wire [31:0] n13;
  wire [31:0] n14;
  wire n15;
  wire [72:0] n16;
  assign mach = n13; //(module output)
  assign macl = n14; //(module output)
  assign busy = n15; //(module output)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:122:10 */
  assign a = n16; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:123:10 */
  assign y = n11; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  ref_mult__mult_Bstru u (
    .clk(clk),
    .rst(rst),
    .slot(slot),
    .\a[wr_m1] (n4),
    .\a[command] (n5),
    .\a[s] (n6),
    .\a[wr_mach] (n7),
    .\a[wr_macl] (n8),
    .\a[in1] (n9),
    .\a[in2] (n10),
    .\y[mach] (\u.y[mach] ),
    .\y[macl] (\u.y[macl] ),
    .\y[busy] (\u.y[busy] ));
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n4 = a[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n5 = a[5:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n6 = a[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n7 = a[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n8 = a[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n9 = a[40:9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n10 = a[72:41]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:132:3 */
  assign n11 = {\u.y[busy] , \u.y[macl] , \u.y[mach] };
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:133:13 */
  assign n13 = y[31:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:134:13 */
  assign n14 = y[63:32]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:135:13 */
  assign n15 = y[64]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:122:10 */
  assign n16 = {in2, in1, wr_macl, wr_mach, s, command, wr_m1};
endmodule

