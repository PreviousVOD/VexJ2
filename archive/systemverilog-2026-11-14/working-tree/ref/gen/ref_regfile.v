module ref_regfile__register_file_Btwo_bank_5_21_32
  (input  clk,
   input  rst,
   input  ce,
   input  [4:0] addr_ra,
   output [31:0] dout_a,
   input  [4:0] addr_rb,
   output [31:0] dout_b,
   output [31:0] dout_0,
   input  we_wb,
   input  [4:0] w_addr_wb,
   input  [31:0] din_wb,
   input  we_ex,
   input  [4:0] w_addr_ex,
   input  [31:0] din_ex,
   output [31:0] wr_data_o);
  wire [31:0] reg0;
  wire [113:0] ex_pipes;
  wire [37:0] wb_pipe;
  wire [31:0] n21;
  wire n23;
  wire [4:0] n25;
  wire n40;
  wire [4:0] n41;
  wire n42;
  wire n43;
  wire [31:0] n44;
  wire n51;
  wire [4:0] n52;
  wire n53;
  wire n54;
  wire [31:0] n55;
  wire n62;
  wire [4:0] n63;
  wire n64;
  wire n65;
  wire [31:0] n66;
  wire [31:0] n67;
  wire [31:0] n68;
  wire [31:0] n69;
  wire [31:0] n79;
  wire n81;
  wire [4:0] n83;
  wire n98;
  wire [4:0] n99;
  wire n100;
  wire n101;
  wire [31:0] n102;
  wire n109;
  wire [4:0] n110;
  wire n111;
  wire n112;
  wire [31:0] n113;
  wire n120;
  wire [4:0] n121;
  wire n122;
  wire n123;
  wire [31:0] n124;
  wire [31:0] n125;
  wire [31:0] n126;
  wire [31:0] n127;
  wire n138;
  wire [4:0] n139;
  wire n141;
  wire n142;
  wire [31:0] n143;
  wire n150;
  wire [4:0] n151;
  wire n153;
  wire n154;
  wire [31:0] n155;
  wire n162;
  wire [4:0] n163;
  wire n165;
  wire n166;
  wire [31:0] n167;
  wire [31:0] n168;
  wire [31:0] n169;
  wire [31:0] n170;
  wire n178;
  wire n179;
  wire n180;
  wire n181;
  wire n183;
  wire n184;
  wire [4:0] n187;
  wire [31:0] n195;
  wire n197;
  wire [4:0] n199;
  wire [31:0] n200;
  wire [31:0] n201;
  wire n202;
  wire [4:0] n204;
  wire [31:0] n212;
  wire n214;
  wire [4:0] n216;
  wire [31:0] n217;
  wire [31:0] n218;
  wire [31:0] n219;
  wire [31:0] n220;
  wire n221;
  wire n222;
  wire n223;
  wire [4:0] n224;
  wire [4:0] n229;
  wire n235;
  wire [31:0] n238;
  wire n242;
  wire [37:0] n243;
  wire [37:0] n244;
  wire n246;
  wire n248;
  wire n250;
  wire [75:0] n252;
  wire [75:0] n266;
  wire n276;
  reg n278;
  wire [113:0] n279;
  wire [37:0] n280;
  wire [31:0] n281;
  reg [31:0] n282;
  wire n283;
  wire n284;
  wire n287;
  wire n288;
  wire [31:0] n291;
  reg [31:0] n292;
  wire [75:0] n293;
  wire [75:0] n294;
  reg [75:0] n295;
  wire [31:0] n296; // mem_rd
  wire [31:0] n298; // mem_rd
  assign dout_a = n69; //(module output)
  assign dout_b = n127; //(module output)
  assign dout_0 = n170; //(module output)
  assign wr_data_o = n282; //(module output)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:114:10 */
  assign reg0 = n292; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:116:10 */
  assign ex_pipes = n279; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:117:10 */
  assign wb_pipe = n280; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n21 = {27'b0, addr_ra};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n23 = $signed(n21) >= $signed(32'b00000000000000000000000000010101);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:6 */
  assign n25 = n23 ? 5'b00000 : addr_ra;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n40 = wb_pipe[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n41 = wb_pipe[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n42 = n41 == addr_ra;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n43 = n42 & n40;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:81:22 */
  assign n44 = wb_pipe[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n51 = ex_pipes[38]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n52 = ex_pipes[75:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n53 = n52 == addr_ra;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n54 = n53 & n51;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:87:26 */
  assign n55 = ex_pipes[70:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n62 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n63 = ex_pipes[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n64 = n63 == addr_ra;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n65 = n64 & n62;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:89:26 */
  assign n66 = ex_pipes[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:88:5 */
  assign n67 = n65 ? n66 : n296;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:86:5 */
  assign n68 = n54 ? n55 : n67;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:80:5 */
  assign n69 = n43 ? n44 : n68;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n79 = {27'b0, addr_rb};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n81 = $signed(n79) >= $signed(32'b00000000000000000000000000010101);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:6 */
  assign n83 = n81 ? 5'b00000 : addr_rb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n98 = wb_pipe[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n99 = wb_pipe[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n100 = n99 == addr_rb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n101 = n100 & n98;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:81:22 */
  assign n102 = wb_pipe[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n109 = ex_pipes[38]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n110 = ex_pipes[75:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n111 = n110 == addr_rb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n112 = n111 & n109;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:87:26 */
  assign n113 = ex_pipes[70:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n120 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n121 = ex_pipes[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n122 = n121 == addr_rb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n123 = n122 & n120;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:89:26 */
  assign n124 = ex_pipes[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:88:5 */
  assign n125 = n123 ? n124 : n298;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:86:5 */
  assign n126 = n112 ? n113 : n125;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:80:5 */
  assign n127 = n101 ? n102 : n126;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n138 = wb_pipe[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n139 = wb_pipe[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n141 = n139 == 5'b00000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n142 = n141 & n138;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:81:22 */
  assign n143 = wb_pipe[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n150 = ex_pipes[38]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n151 = ex_pipes[75:71]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n153 = n151 == 5'b00000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n154 = n153 & n150;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:87:26 */
  assign n155 = ex_pipes[70:39]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:17 */
  assign n162 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:35 */
  assign n163 = ex_pipes[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:40 */
  assign n165 = n163 == 5'b00000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:66:26 */
  assign n166 = n165 & n162;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:89:26 */
  assign n167 = ex_pipes[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:88:5 */
  assign n168 = n166 ? n167 : reg0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:86:5 */
  assign n169 = n154 ? n155 : n168;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:80:5 */
  assign n170 = n142 ? n143 : n169;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:23 */
  assign n178 = wb_pipe[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:42 */
  assign n179 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:26 */
  assign n180 = n178 & n179;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:46 */
  assign n181 = ~n180;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:7 */
  assign n183 = ~n276;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:7 */
  assign n184 = n183 | n181;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:146:7 */
  always @*
    if (!n278)
      ; // assert n185 stripped
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:149:36 */
  assign n187 = wb_pipe[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n195 = {27'b0, n187};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n197 = $signed(n195) >= $signed(32'b00000000000000000000000000010101);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:6 */
  assign n199 = n197 ? 5'b00000 : n187;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:105:6 */
  assign n200 = {27'b0, n199};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:150:23 */
  assign n201 = wb_pipe[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:151:23 */
  assign n202 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:152:42 */
  assign n204 = ex_pipes[37:33]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n212 = {27'b0, n204};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:13 */
  assign n214 = $signed(n212) >= $signed(32'b00000000000000000000000000010101);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:101:6 */
  assign n216 = n214 ? 5'b00000 : n204;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:105:6 */
  assign n217 = {27'b0, n216};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:153:29 */
  assign n218 = ex_pipes[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:151:7 */
  assign n219 = n202 ? n217 : n200;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:151:7 */
  assign n220 = n202 ? n218 : n201;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:156:20 */
  assign n221 = wb_pipe[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:156:38 */
  assign n222 = ex_pipes[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:156:23 */
  assign n223 = n221 | n222;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:158:16 */
  assign n224 = n219[4:0];  // trunc
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:159:16 */
  assign n229 = n219[4:0];  // trunc
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:160:18 */
  assign n235 = n219 == 32'b00000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:156:7 */
  assign n238 = n223 ? n220 : 32'b00000000000000000000000000000000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:156:7 */
  assign n242 = n235 & n223;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:164:30 */
  assign n243 = ex_pipes[75:38]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:165:30 */
  assign n244 = ex_pipes[113:76]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:29 */
  assign n246 = n223 & ce;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:29 */
  assign n248 = n223 & ce;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:29 */
  assign n250 = n242 & ce;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  assign n252 = {n244, n243};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:136:5 */
  assign n266 = {38'b00000000000000000000000000000000000000, 38'b00000000000000000000000000000000000000};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:132:3 */
  assign n276 = ce & 1'b1;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:132:3 */
  always @(posedge clk or posedge rst)
    if (rst)
      n278 <= 1'b1;
    else
      n278 <= n184;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:116:10 */
  assign n279 = {w_addr_ex, din_ex, we_ex, n295};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:117:10 */
  assign n280 = {w_addr_wb, din_wb, we_wb};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  assign n281 = ce ? n238 : n282;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  always @(posedge clk or posedge rst)
    if (rst)
      n282 <= 32'b00000000000000000000000000000000;
    else
      n282 <= n281;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:113:10 */
  assign n283 = ~rst;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:113:10 */
  assign n284 = n246 & n283;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:113:18 */
  assign n287 = ~rst;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:113:18 */
  assign n288 = n248 & n287;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  assign n291 = n250 ? n220 : reg0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  always @(posedge clk or posedge rst)
    if (rst)
      n292 <= 32'b00000000000000000000000000000000;
    else
      n292 <= n291;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  assign n293 = ex_pipes[75:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  assign n294 = ce ? n252 : n293;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:143:5 */
  always @(posedge clk or posedge rst)
    if (rst)
      n295 <= n266;
    else
      n295 <= n294;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:128:50 */
  reg [31:0] bank_a[20:0] ; // memory
  assign n296 = bank_a[n25];
  always @(posedge clk)
    if (n284)
      bank_a[n224] <= n220;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:128:50 */
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:158:16 */
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:129:50 */
  reg [31:0] bank_b[20:0] ; // memory
  assign n298 = bank_b[n83];
  always @(posedge clk)
    if (n288)
      bank_b[n229] <= n220;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:129:50 */
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/register_file.vhd:159:16 */
endmodule

module ref_regfile
  (input  clk,
   input  rst,
   input  ce,
   input  [4:0] addr_ra,
   output [31:0] dout_a,
   input  [4:0] addr_rb,
   output [31:0] dout_b,
   output [31:0] dout_0,
   input  we_wb,
   input  [4:0] w_addr_wb,
   input  [31:0] din_wb,
   input  we_ex,
   input  [4:0] w_addr_ex,
   input  [31:0] din_ex,
   output [31:0] wr_data_o);
  wire [31:0] \u.dout_a ;
  wire [31:0] \u.dout_b ;
  wire [31:0] \u.dout_0 ;
  wire [31:0] \u.wr_data_o ;
  assign dout_a = \u.dout_a ; //(module output)
  assign dout_b = \u.dout_b ; //(module output)
  assign dout_0 = \u.dout_0 ; //(module output)
  assign wr_data_o = \u.wr_data_o ; //(module output)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:94:3 */
  ref_regfile__register_file_Btwo_bank_5_21_32 u (
    .clk(clk),
    .rst(rst),
    .ce(ce),
    .addr_ra(addr_ra),
    .addr_rb(addr_rb),
    .we_wb(we_wb),
    .w_addr_wb(w_addr_wb),
    .din_wb(din_wb),
    .we_ex(we_ex),
    .w_addr_ex(w_addr_ex),
    .din_ex(din_ex),
    .dout_a(\u.dout_a ),
    .dout_b(\u.dout_b ),
    .dout_0(\u.dout_0 ),
    .wr_data_o(\u.wr_data_o ));
endmodule

