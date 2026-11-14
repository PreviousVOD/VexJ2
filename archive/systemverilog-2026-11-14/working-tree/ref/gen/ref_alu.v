module ref_alu
  (input  [31:0] a,
   input  [31:0] b,
   input  arith_func,
   input  ci,
   input  [7:0] sr_in,
   input  a_msb,
   input  b_msb,
   input  [2:0] arith_sr,
   input  [1:0] logic_func,
   input  logic_sr,
   input  [5:0] shift_b,
   input  shift_c,
   input  [1:0] shift_func,
   input  [2:0] manip_func,
   output [32:0] arith_o,
   output [7:0] arith_sr_o,
   output [31:0] logic_o,
   output [7:0] logic_sr_o,
   output [31:0] shift_o,
   output [31:0] manip_o);
  wire af;
  wire [2:0] asr;
  wire [1:0] lf;
  wire lsr;
  wire [1:0] sf;
  wire [2:0] mf;
  wire [32:0] ar;
  wire [31:0] lr;
  wire n23;
  wire n30;
  wire [31:0] n37;
  wire [31:0] n38;
  wire n40;
  localparam [32:0] n41 = 33'b000000000000000000000000000000000;
  wire [31:0] n42;
  wire [32:0] n44;
  wire [32:0] n46;
  wire [32:0] n47;
  wire [32:0] n48;
  wire [32:0] n49;
  wire n51;
  wire n52;
  wire [31:0] n53;
  wire [32:0] n54;
  wire [31:0] n68;
  wire n70;
  wire [31:0] n71;
  wire n73;
  wire [31:0] n74;
  wire n76;
  wire [31:0] n77;
  wire n79;
  wire [3:0] n80;
  reg [31:0] n82;
  wire n92;
  wire n95;
  wire n97;
  wire n99;
  wire [3:0] n101;
  wire [7:0] n102;
  wire n104;
  wire n109;
  wire n112;
  wire n119;
  wire n132;
  wire n134;
  wire n136;
  wire n137;
  wire n138;
  wire n139;
  wire n140;
  wire n141;
  wire n142;
  wire n143;
  wire n144;
  wire n145;
  wire n146;
  wire n147;
  wire n148;
  wire n149;
  wire n150;
  wire n151;
  wire n152;
  wire n153;
  wire n154;
  wire n155;
  wire n156;
  wire n157;
  wire n158;
  wire n159;
  wire n160;
  wire n161;
  wire n162;
  wire n163;
  wire n164;
  wire n165;
  wire n166;
  wire n167;
  wire n168;
  wire n169;
  wire n170;
  wire n171;
  wire n172;
  wire n173;
  wire n174;
  wire n175;
  wire n176;
  wire n177;
  wire n178;
  wire n179;
  wire n180;
  wire n181;
  wire n182;
  wire n183;
  wire n184;
  wire n185;
  wire n186;
  wire n187;
  wire n188;
  wire n189;
  wire n190;
  wire n191;
  wire n192;
  wire n193;
  wire n194;
  wire n195;
  wire n196;
  wire n197;
  wire n198;
  wire n202;
  wire n203;
  wire n204;
  wire n205;
  wire n206;
  wire n207;
  wire n208;
  wire n209;
  wire n210;
  wire n212;
  wire n213;
  wire n214;
  wire n216;
  wire n217;
  wire n218;
  wire n232;
  wire n234;
  wire n236;
  wire n237;
  wire n238;
  wire n239;
  wire n240;
  wire n241;
  wire n242;
  wire n243;
  wire n244;
  wire n245;
  wire n246;
  wire n247;
  wire n248;
  wire n249;
  wire n250;
  wire n251;
  wire n252;
  wire n253;
  wire n254;
  wire n255;
  wire n256;
  wire n257;
  wire n258;
  wire n259;
  wire n260;
  wire n261;
  wire n262;
  wire n263;
  wire n264;
  wire n265;
  wire n266;
  wire n267;
  wire n268;
  wire n269;
  wire n270;
  wire n271;
  wire n272;
  wire n273;
  wire n274;
  wire n275;
  wire n276;
  wire n277;
  wire n278;
  wire n279;
  wire n280;
  wire n281;
  wire n282;
  wire n283;
  wire n284;
  wire n285;
  wire n286;
  wire n287;
  wire n288;
  wire n289;
  wire n290;
  wire n291;
  wire n292;
  wire n293;
  wire n294;
  wire n295;
  wire n296;
  wire n297;
  wire n298;
  wire n300;
  wire n301;
  wire n302;
  wire n303;
  wire n304;
  wire n305;
  wire n306;
  wire n307;
  wire n308;
  wire n309;
  wire n310;
  wire n312;
  wire n313;
  wire n314;
  wire n316;
  wire n318;
  wire n319;
  wire n320;
  wire n322;
  wire n324;
  wire n325;
  wire n327;
  wire n328;
  wire n329;
  wire n330;
  wire [1:0] n331;
  wire [4:0] n332;
  wire [7:0] n333;
  wire n334;
  wire n335;
  wire n336;
  wire n337;
  wire n339;
  wire [7:0] n340;
  reg n342;
  wire n343;
  reg n345;
  wire n346;
  reg n348;
  wire n351;
  wire [3:0] n352;
  wire [7:0] n353;
  wire n358;
  wire n359;
  wire [1:0] n360;
  wire n361;
  wire [2:0] n362;
  wire n363;
  wire [3:0] n364;
  wire [3:0] n365;
  wire [7:0] n366;
  wire n375;
  wire n378;
  wire n380;
  wire n382;
  wire [3:0] n384;
  wire [7:0] n385;
  wire n402;
  wire n404;
  wire n406;
  wire n407;
  wire n408;
  wire n409;
  wire n410;
  wire n411;
  wire n412;
  wire n413;
  wire n414;
  wire n415;
  wire n416;
  wire n417;
  wire n418;
  wire n419;
  wire n420;
  wire n421;
  wire n422;
  wire n423;
  wire n424;
  wire n425;
  wire n426;
  wire n427;
  wire n428;
  wire n429;
  wire n430;
  wire n431;
  wire n432;
  wire n433;
  wire n434;
  wire n435;
  wire n436;
  wire n437;
  wire n438;
  wire n439;
  wire n440;
  wire n441;
  wire n442;
  wire n443;
  wire n444;
  wire n445;
  wire n446;
  wire n447;
  wire n448;
  wire n449;
  wire n450;
  wire n451;
  wire n452;
  wire n453;
  wire n454;
  wire n455;
  wire n456;
  wire n457;
  wire n458;
  wire n459;
  wire n460;
  wire n461;
  wire n462;
  wire n463;
  wire n464;
  wire n465;
  wire n466;
  wire n467;
  wire n468;
  wire n470;
  wire n486;
  wire n488;
  wire n490;
  wire n491;
  wire n492;
  wire n493;
  wire n494;
  wire n495;
  wire n496;
  wire n497;
  wire n498;
  wire n499;
  wire n500;
  wire n501;
  wire n502;
  wire n503;
  wire n513;
  wire n515;
  wire n517;
  wire n518;
  wire n519;
  wire n520;
  wire n521;
  wire n522;
  wire n523;
  wire n524;
  wire n525;
  wire n526;
  wire n527;
  wire n528;
  wire n529;
  wire n530;
  wire n539;
  wire n541;
  wire n543;
  wire n544;
  wire n545;
  wire n546;
  wire n547;
  wire n548;
  wire n549;
  wire n550;
  wire n551;
  wire n552;
  wire n553;
  wire n554;
  wire n555;
  wire n556;
  wire n565;
  wire n567;
  wire n569;
  wire n570;
  wire n571;
  wire n572;
  wire n573;
  wire n574;
  wire n575;
  wire n576;
  wire n577;
  wire n578;
  wire n579;
  wire n580;
  wire n581;
  wire n582;
  wire [3:0] n583;
  wire [3:0] n590;
  wire n596;
  wire n598;
  wire n600;
  wire n601;
  wire n602;
  wire n603;
  wire n604;
  wire n605;
  wire n607;
  wire [1:0] n608;
  reg n610;
  wire [6:0] n611;
  wire [7:0] n612;
  wire n617;
  wire n618;
  wire [1:0] n619;
  wire n620;
  wire [2:0] n621;
  wire n622;
  wire [3:0] n623;
  wire [3:0] n624;
  wire [7:0] n625;
  wire [4:0] n638;
  wire n640;
  wire n641;
  wire n644;
  wire n647;
  wire [30:0] n654;
  wire [31:0] n656;
  wire n658;
  wire n661;
  localparam [31:0] n662 = 32'b00000000000000000000000000000000;
  wire [31:0] n664;
  wire n666;
  wire n668;
  wire n669;
  wire [31:0] n671;
  wire n673;
  wire n675;
  wire n676;
  wire [31:0] n678;
  wire n680;
  wire n682;
  wire n683;
  wire [31:0] n685;
  wire n687;
  wire n689;
  wire n690;
  wire [31:0] n692;
  wire n694;
  wire n696;
  wire n697;
  wire [31:0] n699;
  wire n701;
  wire n703;
  wire n704;
  wire [31:0] n706;
  wire n708;
  wire n710;
  wire n711;
  wire [31:0] n713;
  wire n715;
  wire n717;
  wire n718;
  wire [31:0] n720;
  wire n722;
  wire n724;
  wire n725;
  wire [31:0] n727;
  wire n729;
  wire n731;
  wire n732;
  wire [31:0] n734;
  wire n736;
  wire n738;
  wire n739;
  wire [31:0] n741;
  wire n743;
  wire n745;
  wire n746;
  wire [31:0] n748;
  wire n750;
  wire n752;
  wire n753;
  wire [31:0] n755;
  wire n757;
  wire n759;
  wire n760;
  wire [31:0] n762;
  wire n764;
  wire n766;
  wire n767;
  wire [31:0] n769;
  wire n771;
  wire n773;
  wire n774;
  wire [31:0] n776;
  wire n778;
  wire n780;
  wire n781;
  wire [31:0] n783;
  wire n785;
  wire n787;
  wire n788;
  wire [31:0] n790;
  wire n792;
  wire n794;
  wire n795;
  wire [31:0] n797;
  wire n799;
  wire n801;
  wire n802;
  wire [31:0] n804;
  wire n806;
  wire n808;
  wire n809;
  wire [31:0] n811;
  wire n813;
  wire n815;
  wire n816;
  wire [31:0] n818;
  wire n820;
  wire n822;
  wire n823;
  wire [31:0] n825;
  wire n827;
  wire n829;
  wire n830;
  wire [31:0] n832;
  wire n834;
  wire n836;
  wire n837;
  wire [31:0] n839;
  wire n841;
  wire n843;
  wire n844;
  wire [31:0] n846;
  wire n848;
  wire n850;
  wire n851;
  wire [31:0] n853;
  wire n855;
  wire n857;
  wire n858;
  wire [31:0] n860;
  wire n862;
  wire n864;
  wire n865;
  wire [31:0] n867;
  wire n869;
  wire n871;
  wire n872;
  wire n873;
  wire [31:0] n874;
  wire n876;
  wire n878;
  wire [31:0] n879;
  wire n887;
  wire n888;
  wire n889;
  wire n892;
  wire n893;
  wire n894;
  wire n896;
  wire n897;
  wire n898;
  wire n900;
  wire n901;
  wire n902;
  wire n904;
  wire n905;
  wire n906;
  wire n908;
  wire n909;
  wire n910;
  wire n912;
  wire n913;
  wire n914;
  wire n916;
  wire n917;
  wire n918;
  wire n920;
  wire n921;
  wire n922;
  wire n924;
  wire n925;
  wire n926;
  wire n928;
  wire n929;
  wire n930;
  wire n932;
  wire n933;
  wire n934;
  wire n936;
  wire n937;
  wire n938;
  wire n940;
  wire n941;
  wire n942;
  wire n944;
  wire n945;
  wire n946;
  wire n948;
  wire n949;
  wire n950;
  wire n952;
  wire n953;
  wire n954;
  wire n956;
  wire n957;
  wire n958;
  wire n960;
  wire n961;
  wire n962;
  wire n964;
  wire n965;
  wire n966;
  wire n968;
  wire n969;
  wire n970;
  wire n972;
  wire n973;
  wire n974;
  wire n976;
  wire n977;
  wire n978;
  wire n980;
  wire n981;
  wire n982;
  wire n984;
  wire n985;
  wire n986;
  wire n988;
  wire n989;
  wire n990;
  wire n992;
  wire n993;
  wire n994;
  wire n996;
  wire n997;
  wire n998;
  wire n1000;
  wire n1001;
  wire n1002;
  wire n1004;
  wire n1005;
  wire n1006;
  wire n1008;
  wire n1009;
  wire n1010;
  wire n1012;
  wire n1013;
  wire n1014;
  wire [31:0] n1015;
  wire n1027;
  wire n1028;
  wire n1029;
  wire n1030;
  wire n1031;
  wire n1032;
  wire n1033;
  wire n1034;
  wire n1035;
  wire n1036;
  wire n1037;
  wire n1038;
  wire n1039;
  wire n1040;
  wire n1041;
  wire n1042;
  wire n1043;
  wire n1044;
  wire n1045;
  wire n1046;
  wire n1047;
  wire n1048;
  wire n1049;
  wire n1050;
  wire n1051;
  wire n1052;
  wire n1053;
  wire n1054;
  wire n1055;
  wire n1056;
  wire n1057;
  wire n1058;
  wire n1059;
  wire n1060;
  wire n1061;
  wire n1062;
  wire n1063;
  wire n1064;
  wire n1065;
  wire n1066;
  wire n1067;
  wire n1068;
  wire n1069;
  wire n1070;
  wire n1071;
  wire n1072;
  wire n1073;
  wire n1074;
  wire n1075;
  wire n1076;
  wire n1077;
  wire n1078;
  wire n1079;
  wire n1080;
  wire n1081;
  wire n1082;
  wire n1083;
  wire n1084;
  wire n1085;
  wire n1086;
  wire n1087;
  wire n1088;
  wire n1089;
  wire n1090;
  wire n1091;
  wire [31:0] n1092;
  wire [31:0] n1093;
  wire [31:0] n1094;
  wire n1100;
  wire n1101;
  wire n1102;
  wire n1103;
  wire n1104;
  wire n1105;
  wire n1106;
  wire n1107;
  wire n1108;
  wire n1109;
  wire n1110;
  wire n1111;
  wire n1112;
  wire n1113;
  wire n1114;
  wire n1115;
  wire n1116;
  wire n1117;
  wire n1118;
  wire n1119;
  wire n1120;
  wire n1121;
  wire n1122;
  wire n1123;
  wire n1124;
  wire n1125;
  wire n1126;
  wire n1127;
  wire n1128;
  wire n1129;
  wire n1130;
  wire n1131;
  wire n1132;
  wire n1133;
  wire n1134;
  wire n1135;
  wire n1136;
  wire n1137;
  wire n1138;
  wire n1139;
  wire n1140;
  wire n1141;
  wire n1142;
  wire n1143;
  wire n1144;
  wire n1145;
  wire n1146;
  wire n1147;
  wire n1148;
  wire n1149;
  wire n1150;
  wire n1151;
  wire n1152;
  wire n1153;
  wire n1154;
  wire n1155;
  wire n1156;
  wire n1157;
  wire n1158;
  wire n1159;
  wire n1160;
  wire n1161;
  wire n1162;
  wire n1163;
  wire n1164;
  wire [31:0] n1165;
  wire [31:0] n1166;
  wire [31:0] n1167;
  wire n1170;
  wire n1171;
  wire n1172;
  wire n1173;
  wire n1174;
  wire n1175;
  wire n1176;
  wire n1177;
  wire n1178;
  wire n1179;
  wire n1180;
  wire n1181;
  wire n1182;
  wire n1183;
  wire n1184;
  wire n1185;
  wire n1186;
  wire n1187;
  wire n1188;
  wire n1189;
  wire n1190;
  wire n1191;
  wire n1192;
  wire n1193;
  wire n1194;
  wire n1195;
  wire n1196;
  wire n1197;
  wire n1198;
  wire n1199;
  wire n1200;
  wire n1201;
  wire n1202;
  wire n1203;
  wire n1204;
  wire n1205;
  wire n1206;
  wire n1207;
  wire n1208;
  wire n1209;
  wire n1210;
  wire n1211;
  wire n1212;
  wire n1213;
  wire n1214;
  wire n1215;
  wire n1216;
  wire n1217;
  wire n1218;
  wire n1219;
  wire n1220;
  wire n1221;
  wire n1222;
  wire n1223;
  wire n1224;
  wire n1225;
  wire n1226;
  wire n1227;
  wire n1228;
  wire n1229;
  wire n1230;
  wire n1231;
  wire n1232;
  wire n1233;
  wire n1234;
  wire [31:0] n1235;
  wire [31:0] n1236;
  wire [31:0] n1237;
  wire n1240;
  wire n1241;
  wire n1242;
  wire n1243;
  wire n1244;
  wire n1245;
  wire n1246;
  wire n1247;
  wire n1248;
  wire n1249;
  wire n1250;
  wire n1251;
  wire n1252;
  wire n1253;
  wire n1254;
  wire n1255;
  wire n1256;
  wire n1257;
  wire n1258;
  wire n1259;
  wire n1260;
  wire n1261;
  wire n1262;
  wire n1263;
  wire n1264;
  wire n1265;
  wire n1266;
  wire n1267;
  wire n1268;
  wire n1269;
  wire n1270;
  wire n1271;
  wire n1272;
  wire n1273;
  wire n1274;
  wire n1275;
  wire n1276;
  wire n1277;
  wire n1278;
  wire n1279;
  wire n1280;
  wire n1281;
  wire n1282;
  wire n1283;
  wire n1284;
  wire n1285;
  wire n1286;
  wire n1287;
  wire n1288;
  wire n1289;
  wire n1290;
  wire n1291;
  wire n1292;
  wire n1293;
  wire n1294;
  wire n1295;
  wire n1296;
  wire n1297;
  wire n1298;
  wire n1299;
  wire n1300;
  wire n1301;
  wire n1302;
  wire n1303;
  wire n1304;
  wire [31:0] n1305;
  wire [31:0] n1306;
  wire [31:0] n1307;
  wire n1310;
  wire n1311;
  wire n1312;
  wire n1313;
  wire n1314;
  wire n1315;
  wire n1316;
  wire n1317;
  wire n1318;
  wire n1319;
  wire n1320;
  wire n1321;
  wire n1322;
  wire n1323;
  wire n1324;
  wire n1325;
  wire n1326;
  wire n1327;
  wire n1328;
  wire n1329;
  wire n1330;
  wire n1331;
  wire n1332;
  wire n1333;
  wire n1334;
  wire n1335;
  wire n1336;
  wire n1337;
  wire n1338;
  wire n1339;
  wire n1340;
  wire n1341;
  wire n1342;
  wire n1343;
  wire n1344;
  wire n1345;
  wire n1346;
  wire n1347;
  wire n1348;
  wire n1349;
  wire n1350;
  wire n1351;
  wire n1352;
  wire n1353;
  wire n1354;
  wire n1355;
  wire n1356;
  wire n1357;
  wire n1358;
  wire n1359;
  wire n1360;
  wire n1361;
  wire n1362;
  wire n1363;
  wire n1364;
  wire n1365;
  wire n1366;
  wire n1367;
  wire n1368;
  wire n1369;
  wire n1370;
  wire n1371;
  wire n1372;
  wire n1373;
  wire n1374;
  wire [31:0] n1375;
  wire [31:0] n1376;
  wire [31:0] n1377;
  wire n1382;
  wire n1390;
  wire n1391;
  wire n1392;
  wire n1394;
  wire n1396;
  wire n1397;
  wire n1399;
  wire n1400;
  wire n1401;
  wire n1402;
  wire n1405;
  wire n1406;
  wire n1407;
  wire n1409;
  wire n1410;
  wire n1411;
  wire n1412;
  wire n1414;
  wire n1415;
  wire n1416;
  wire n1418;
  wire n1419;
  wire n1420;
  wire n1422;
  wire n1423;
  wire n1424;
  wire n1426;
  wire n1427;
  wire n1428;
  wire n1430;
  wire n1431;
  wire n1432;
  wire n1434;
  wire n1435;
  wire n1436;
  wire n1438;
  wire n1439;
  wire n1440;
  wire n1442;
  wire n1443;
  wire n1444;
  wire n1446;
  wire n1447;
  wire n1448;
  wire n1450;
  wire n1451;
  wire n1452;
  wire n1454;
  wire n1455;
  wire n1456;
  wire n1458;
  wire n1459;
  wire n1460;
  wire n1462;
  wire n1463;
  wire n1464;
  wire n1466;
  wire n1467;
  wire n1468;
  wire n1470;
  wire n1471;
  wire n1472;
  wire n1474;
  wire n1475;
  wire n1476;
  wire n1478;
  wire n1479;
  wire n1480;
  wire n1482;
  wire n1483;
  wire n1484;
  wire n1486;
  wire n1487;
  wire n1488;
  wire n1490;
  wire n1491;
  wire n1492;
  wire n1494;
  wire n1495;
  wire n1496;
  wire n1498;
  wire n1499;
  wire n1500;
  wire n1502;
  wire n1503;
  wire n1504;
  wire n1506;
  wire n1507;
  wire n1508;
  wire n1510;
  wire n1511;
  wire n1512;
  wire n1514;
  wire n1515;
  wire n1516;
  wire n1518;
  wire n1519;
  wire n1520;
  wire n1522;
  wire n1523;
  wire n1524;
  wire n1526;
  wire n1527;
  wire n1528;
  wire n1530;
  wire n1531;
  wire n1532;
  wire [31:0] n1533;
  wire n1547;
  wire n1548;
  wire n1549;
  wire n1550;
  wire [7:0] n1552;
  wire [7:0] n1554;
  wire n1556;
  wire n1558;
  wire n1559;
  wire n1561;
  wire n1563;
  wire n1564;
  wire n1566;
  wire n1568;
  wire n1569;
  wire [7:0] n1570;
  wire [2:0] n1571;
  reg [7:0] n1573;
  wire [7:0] n1575;
  wire n1577;
  wire n1579;
  wire n1580;
  wire n1582;
  wire n1584;
  wire n1585;
  wire n1587;
  wire n1589;
  wire n1590;
  wire [7:0] n1591;
  wire [2:0] n1592;
  reg [7:0] n1594;
  wire [7:0] n1596;
  wire n1598;
  wire [7:0] n1599;
  wire n1601;
  wire n1603;
  wire [7:0] n1604;
  wire n1606;
  wire n1608;
  wire n1609;
  wire n1611;
  wire n1612;
  wire n1614;
  wire [7:0] n1615;
  wire [4:0] n1616;
  reg [7:0] n1618;
  wire [7:0] n1620;
  wire n1622;
  wire [7:0] n1623;
  wire n1625;
  wire [7:0] n1626;
  wire n1628;
  wire n1630;
  wire n1631;
  wire n1633;
  wire n1634;
  wire n1636;
  wire n1637;
  wire [6:0] n1638;
  wire [7:0] n1640;
  wire n1642;
  wire [7:0] n1643;
  wire [3:0] n1644;
  reg [7:0] n1645;
  wire [15:0] n1647;
  wire [23:0] n1648;
  wire [31:0] n1649;
  assign arith_o = ar; //(module output)
  assign arith_sr_o = n366; //(module output)
  assign logic_o = lr; //(module output)
  assign logic_sr_o = n625; //(module output)
  assign shift_o = n1533; //(module output)
  assign manip_o = n1649; //(module output)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:45:10 */
  assign af = arith_func; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:46:10 */
  assign asr = arith_sr; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:47:10 */
  assign lf = logic_func; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:48:10 */
  assign lsr = logic_sr; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:49:10 */
  assign sf = shift_func; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:50:10 */
  assign mf = manip_func; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:51:10 */
  assign ar = n54; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:52:10 */
  assign lr = n82; // (signal)
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:218:25 */
  assign n23 = af == 1'b1;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:190:3 */
  assign n30 = n23 ? 1'b1 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:183:60 */
  assign n37 = {n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30, n30};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:185:13 */
  assign n38 = b ^ n37;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:230:25 */
  assign n40 = n30 ^ ci;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:209:12 */
  assign n42 = n41[32:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:232:15 */
  assign n44 = {1'b0, a};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:232:38 */
  assign n46 = {1'b0, n38};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:232:31 */
  assign n47 = n44 + n46;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:209:12 */
  assign n48 = {n42, n40};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:232:54 */
  assign n49 = n47 + n48;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:235:23 */
  assign n51 = n49[32]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:235:34 */
  assign n52 = n51 ^ n30;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:208:12 */
  assign n53 = n49[31:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:208:12 */
  assign n54 = {n52, n53};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:185:13 */
  assign n68 = b ^ 32'b11111111111111111111111111111111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:256:5 */
  assign n70 = lf == 2'b00;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:259:15 */
  assign n71 = a & b;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:258:5 */
  assign n73 = lf == 2'b01;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:261:15 */
  assign n74 = a | b;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:260:5 */
  assign n76 = lf == 2'b10;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:263:15 */
  assign n77 = a ^ b;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:262:5 */
  assign n79 = lf == 2'b11;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:255:3 */
  assign n80 = {n79, n76, n73, n70};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:255:3 */
  always @*
    case (n80)
      4'b1000: n82 = n77;
      4'b0100: n82 = n74;
      4'b0010: n82 = n71;
      4'b0001: n82 = n68;
      default: n82 = 32'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:13 */
  assign n92 = sr_in[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:26 */
  assign n95 = sr_in[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:39 */
  assign n97 = sr_in[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:52 */
  assign n99 = sr_in[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:72 */
  assign n101 = sr_in[3:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:36:14 */
  assign n102 = {n101, n99, n97, n95, n92};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:64:88 */
  assign n104 = ar[32]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:279:34 */
  assign n109 = ar[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:280:51 */
  assign n112 = af == 1'b1;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:190:3 */
  assign n119 = n112 ? 1'b1 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n132 = ar[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n134 = 1'b0 | n132;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n136 = ar[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n137 = n134 | n136;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n138 = ar[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n139 = n137 | n138;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n140 = ar[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n141 = n139 | n140;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n142 = ar[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n143 = n141 | n142;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n144 = ar[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n145 = n143 | n144;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n146 = ar[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n147 = n145 | n146;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n148 = ar[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n149 = n147 | n148;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n150 = ar[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n151 = n149 | n150;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n152 = ar[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n153 = n151 | n152;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n154 = ar[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n155 = n153 | n154;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n156 = ar[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n157 = n155 | n156;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n158 = ar[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n159 = n157 | n158;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n160 = ar[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n161 = n159 | n160;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n162 = ar[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n163 = n161 | n162;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n164 = ar[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n165 = n163 | n164;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n166 = ar[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n167 = n165 | n166;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n168 = ar[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n169 = n167 | n168;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n170 = ar[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n171 = n169 | n170;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n172 = ar[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n173 = n171 | n172;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n174 = ar[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n175 = n173 | n174;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n176 = ar[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n177 = n175 | n176;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n178 = ar[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n179 = n177 | n178;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n180 = ar[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n181 = n179 | n180;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n182 = ar[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n183 = n181 | n182;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n184 = ar[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n185 = n183 | n184;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n186 = ar[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n187 = n185 | n186;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n188 = ar[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n189 = n187 | n188;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n190 = ar[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n191 = n189 | n190;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n192 = ar[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n193 = n191 | n192;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n194 = ar[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n195 = n193 | n194;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n196 = ar[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n197 = n195 | n196;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:177:10 */
  assign n198 = ~n197;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:20 */
  assign n202 = ~a_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:35 */
  assign n203 = ~b_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:31 */
  assign n204 = n202 & n203;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:50 */
  assign n205 = ~n109;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:46 */
  assign n206 = n204 & n205;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:287:26 */
  assign n207 = a_msb & b_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:287:40 */
  assign n208 = ~n109;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:287:36 */
  assign n209 = n207 & n208;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:286:62 */
  assign n210 = n206 | n209;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:288:34 */
  assign n212 = ~a_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:288:45 */
  assign n213 = n212 & b_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:288:30 */
  assign n214 = n210 | n213;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:289:46 */
  assign n216 = ~b_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:289:42 */
  assign n217 = a_msb & n216;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:289:32 */
  assign n218 = n210 | n217;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n232 = ar[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n234 = 1'b0 | n232;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n236 = ar[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n237 = n234 | n236;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n238 = ar[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n239 = n237 | n238;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n240 = ar[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n241 = n239 | n240;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n242 = ar[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n243 = n241 | n242;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n244 = ar[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n245 = n243 | n244;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n246 = ar[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n247 = n245 | n246;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n248 = ar[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n249 = n247 | n248;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n250 = ar[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n251 = n249 | n250;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n252 = ar[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n253 = n251 | n252;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n254 = ar[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n255 = n253 | n254;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n256 = ar[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n257 = n255 | n256;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n258 = ar[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n259 = n257 | n258;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n260 = ar[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n261 = n259 | n260;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n262 = ar[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n263 = n261 | n262;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n264 = ar[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n265 = n263 | n264;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n266 = ar[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n267 = n265 | n266;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n268 = ar[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n269 = n267 | n268;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n270 = ar[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n271 = n269 | n270;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n272 = ar[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n273 = n271 | n272;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n274 = ar[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n275 = n273 | n274;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n276 = ar[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n277 = n275 | n276;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n278 = ar[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n279 = n277 | n278;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n280 = ar[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n281 = n279 | n280;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n282 = ar[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n283 = n281 | n282;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n284 = ar[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n285 = n283 | n284;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n286 = ar[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n287 = n285 | n286;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n288 = ar[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n289 = n287 | n288;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n290 = ar[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n291 = n289 | n290;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n292 = ar[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n293 = n291 | n292;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n294 = ar[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n295 = n293 | n294;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n296 = ar[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n297 = n295 | n296;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:177:10 */
  assign n298 = ~n297;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:291:5 */
  assign n300 = asr == 3'b000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:20 */
  assign n301 = ~a_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:45 */
  assign n302 = b_msb ^ n119;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:35 */
  assign n303 = ~n302;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:31 */
  assign n304 = n301 & n303;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:57 */
  assign n305 = n304 & n109;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:295:37 */
  assign n306 = b_msb ^ n119;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:295:26 */
  assign n307 = a_msb & n306;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:295:53 */
  assign n308 = ~n109;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:295:49 */
  assign n309 = n307 & n308;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:294:68 */
  assign n310 = n305 | n309;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:293:5 */
  assign n312 = asr == 3'b001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:297:36 */
  assign n313 = ~n198;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:297:32 */
  assign n314 = n218 & n313;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:296:5 */
  assign n316 = asr == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:298:5 */
  assign n318 = asr == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:301:34 */
  assign n319 = ~n198;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:301:30 */
  assign n320 = n214 & n319;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:300:5 */
  assign n322 = asr == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:302:5 */
  assign n324 = asr == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:307:25 */
  assign n325 = a_msb ^ b_msb;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:304:5 */
  assign n327 = asr == 3'b110;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:309:35 */
  assign n328 = n102[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:309:25 */
  assign n329 = a_msb ^ n328;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:309:37 */
  assign n330 = n329 ^ n104;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n331 = n102[1:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n332 = n102[7:3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n333 = {n332, n330, n331};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:310:31 */
  assign n334 = n333[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:310:43 */
  assign n335 = n102[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:310:33 */
  assign n336 = n334 ^ n335;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:310:19 */
  assign n337 = ~n336;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:308:5 */
  assign n339 = asr == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:290:3 */
  assign n340 = {n339, n327, n324, n322, n318, n316, n312, n300};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:290:3 */
  always @*
    case (n340)
      8'b10000000: n342 = n337;
      8'b01000000: n342 = n325;
      8'b00100000: n342 = n214;
      8'b00010000: n342 = n320;
      8'b00001000: n342 = n218;
      8'b00000100: n342 = n314;
      8'b00000010: n342 = n310;
      8'b00000001: n342 = n298;
      default: n342 = 1'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n343 = n102[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:290:3 */
  always @*
    case (n340)
      8'b10000000: n345 = n330;
      8'b01000000: n345 = a_msb;
      8'b00100000: n345 = n343;
      8'b00010000: n345 = n343;
      8'b00001000: n345 = n343;
      8'b00000100: n345 = n343;
      8'b00000010: n345 = n343;
      8'b00000001: n345 = n343;
      default: n345 = 1'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n346 = n102[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:290:3 */
  always @*
    case (n340)
      8'b10000000: n348 = n346;
      8'b01000000: n348 = b_msb;
      8'b00100000: n348 = n346;
      8'b00010000: n348 = n346;
      8'b00001000: n348 = n346;
      8'b00000100: n348 = n346;
      8'b00000010: n348 = n346;
      8'b00000001: n348 = n346;
      default: n348 = 1'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n351 = n102[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n352 = n102[7:4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:278:12 */
  assign n353 = {n352, n348, n345, n351, n342};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:14 */
  assign n358 = n353[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:20 */
  assign n359 = n353[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:16 */
  assign n360 = {n358, n359};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:26 */
  assign n361 = n353[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:22 */
  assign n362 = {n360, n361};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:32 */
  assign n363 = n353[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:28 */
  assign n364 = {n362, n363};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:38 */
  assign n365 = n353[7:4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:34 */
  assign n366 = {n364, n365};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:13 */
  assign n375 = sr_in[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:26 */
  assign n378 = sr_in[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:39 */
  assign n380 = sr_in[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:52 */
  assign n382 = sr_in[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:38:72 */
  assign n384 = sr_in[3:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:36:14 */
  assign n385 = {n384, n382, n380, n378, n375};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n402 = lr[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n404 = 1'b0 | n402;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n406 = lr[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n407 = n404 | n406;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n408 = lr[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n409 = n407 | n408;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n410 = lr[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n411 = n409 | n410;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n412 = lr[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n413 = n411 | n412;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n414 = lr[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n415 = n413 | n414;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n416 = lr[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n417 = n415 | n416;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n418 = lr[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n419 = n417 | n418;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n420 = lr[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n421 = n419 | n420;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n422 = lr[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n423 = n421 | n422;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n424 = lr[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n425 = n423 | n424;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n426 = lr[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n427 = n425 | n426;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n428 = lr[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n429 = n427 | n428;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n430 = lr[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n431 = n429 | n430;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n432 = lr[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n433 = n431 | n432;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n434 = lr[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n435 = n433 | n434;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n436 = lr[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n437 = n435 | n436;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n438 = lr[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n439 = n437 | n438;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n440 = lr[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n441 = n439 | n440;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n442 = lr[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n443 = n441 | n442;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n444 = lr[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n445 = n443 | n444;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n446 = lr[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n447 = n445 | n446;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n448 = lr[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n449 = n447 | n448;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n450 = lr[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n451 = n449 | n450;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n452 = lr[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n453 = n451 | n452;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n454 = lr[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n455 = n453 | n454;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n456 = lr[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n457 = n455 | n456;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n458 = lr[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n459 = n457 | n458;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n460 = lr[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n461 = n459 | n460;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n462 = lr[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n463 = n461 | n462;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n464 = lr[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n465 = n463 | n464;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n466 = lr[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n467 = n465 | n466;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:177:10 */
  assign n468 = ~n467;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:325:5 */
  assign n470 = lsr == 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n486 = lr[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n488 = 1'b0 | n486;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n490 = lr[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n491 = n488 | n490;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n492 = lr[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n493 = n491 | n492;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n494 = lr[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n495 = n493 | n494;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n496 = lr[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n497 = n495 | n496;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n498 = lr[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n499 = n497 | n498;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n500 = lr[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n501 = n499 | n500;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n502 = lr[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n503 = n501 | n502;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n513 = lr[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n515 = 1'b0 | n513;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n517 = lr[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n518 = n515 | n517;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n519 = lr[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n520 = n518 | n519;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n521 = lr[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n522 = n520 | n521;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n523 = lr[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n524 = n522 | n523;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n525 = lr[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n526 = n524 | n525;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n527 = lr[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n528 = n526 | n527;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n529 = lr[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n530 = n528 | n529;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n539 = lr[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n541 = 1'b0 | n539;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n543 = lr[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n544 = n541 | n543;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n545 = lr[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n546 = n544 | n545;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n547 = lr[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n548 = n546 | n547;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n549 = lr[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n550 = n548 | n549;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n551 = lr[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n552 = n550 | n551;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n553 = lr[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n554 = n552 | n553;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n555 = lr[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n556 = n554 | n555;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n565 = lr[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n567 = 1'b0 | n565;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n569 = lr[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n570 = n567 | n569;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n571 = lr[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n572 = n570 | n571;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n573 = lr[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n574 = n572 | n573;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n575 = lr[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n576 = n574 | n575;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n577 = lr[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n578 = n576 | n577;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n579 = lr[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n580 = n578 | n579;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n581 = lr[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n582 = n580 | n581;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:166:12 */
  assign n583 = {n503, n530, n556, n582};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:185:13 */
  assign n590 = n583 ^ 4'b1111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n596 = n590[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n598 = 1'b0 | n596;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n600 = n590[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n601 = n598 | n600;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n602 = n590[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n603 = n601 | n602;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:16 */
  assign n604 = n590[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:156:12 */
  assign n605 = n603 | n604;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:327:5 */
  assign n607 = lsr == 1'b1;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:324:3 */
  assign n608 = {n607, n470};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:324:3 */
  always @*
    case (n608)
      2'b10: n610 = n605;
      2'b01: n610 = n468;
      default: n610 = 1'bX;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:322:12 */
  assign n611 = n385[7:1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:322:12 */
  assign n612 = {n611, n610};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:14 */
  assign n617 = n612[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:20 */
  assign n618 = n612[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:16 */
  assign n619 = {n617, n618};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:26 */
  assign n620 = n612[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:22 */
  assign n621 = {n619, n620};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:32 */
  assign n622 = n612[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:28 */
  assign n623 = {n621, n622};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:38 */
  assign n624 = n612[7:4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/ref/ref_core_units.vhd:43:34 */
  assign n625 = {n623, n624};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:433:15 */
  assign n638 = shift_b[4:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:434:18 */
  assign n640 = shift_b[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:434:12 */
  assign n641 = ~n640;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:436:11 */
  assign n644 = sf == 2'b10;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:436:4 */
  assign n647 = n644 ? 1'b1 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:369:29 */
  assign n654 = {26'b0, n638};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n656 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n658 = $signed(32'b00000000000000000000000000011111) < $signed(n656);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n661 = n658 ? 1'b1 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n664 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n666 = $signed(32'b00000000000000000000000000011110) < $signed(n664);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n668 = n662[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n669 = n666 ? 1'b1 : n668;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n671 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n673 = $signed(32'b00000000000000000000000000011101) < $signed(n671);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n675 = n662[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n676 = n673 ? 1'b1 : n675;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n678 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n680 = $signed(32'b00000000000000000000000000011100) < $signed(n678);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n682 = n662[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n683 = n680 ? 1'b1 : n682;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n685 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n687 = $signed(32'b00000000000000000000000000011011) < $signed(n685);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n689 = n662[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n690 = n687 ? 1'b1 : n689;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n692 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n694 = $signed(32'b00000000000000000000000000011010) < $signed(n692);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n696 = n662[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n697 = n694 ? 1'b1 : n696;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n699 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n701 = $signed(32'b00000000000000000000000000011001) < $signed(n699);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n703 = n662[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n704 = n701 ? 1'b1 : n703;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n706 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n708 = $signed(32'b00000000000000000000000000011000) < $signed(n706);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n710 = n662[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n711 = n708 ? 1'b1 : n710;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n713 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n715 = $signed(32'b00000000000000000000000000010111) < $signed(n713);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n717 = n662[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n718 = n715 ? 1'b1 : n717;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n720 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n722 = $signed(32'b00000000000000000000000000010110) < $signed(n720);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n724 = n662[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n725 = n722 ? 1'b1 : n724;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n727 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n729 = $signed(32'b00000000000000000000000000010101) < $signed(n727);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n731 = n662[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n732 = n729 ? 1'b1 : n731;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n734 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n736 = $signed(32'b00000000000000000000000000010100) < $signed(n734);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n738 = n662[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n739 = n736 ? 1'b1 : n738;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n741 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n743 = $signed(32'b00000000000000000000000000010011) < $signed(n741);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n745 = n662[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n746 = n743 ? 1'b1 : n745;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n748 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n750 = $signed(32'b00000000000000000000000000010010) < $signed(n748);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n752 = n662[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n753 = n750 ? 1'b1 : n752;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n755 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n757 = $signed(32'b00000000000000000000000000010001) < $signed(n755);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n759 = n662[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n760 = n757 ? 1'b1 : n759;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n762 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n764 = $signed(32'b00000000000000000000000000010000) < $signed(n762);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n766 = n662[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n767 = n764 ? 1'b1 : n766;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n769 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n771 = $signed(32'b00000000000000000000000000001111) < $signed(n769);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n773 = n662[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n774 = n771 ? 1'b1 : n773;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n776 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n778 = $signed(32'b00000000000000000000000000001110) < $signed(n776);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n780 = n662[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n781 = n778 ? 1'b1 : n780;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n783 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n785 = $signed(32'b00000000000000000000000000001101) < $signed(n783);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n787 = n662[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n788 = n785 ? 1'b1 : n787;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n790 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n792 = $signed(32'b00000000000000000000000000001100) < $signed(n790);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n794 = n662[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n795 = n792 ? 1'b1 : n794;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n797 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n799 = $signed(32'b00000000000000000000000000001011) < $signed(n797);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n801 = n662[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n802 = n799 ? 1'b1 : n801;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n804 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n806 = $signed(32'b00000000000000000000000000001010) < $signed(n804);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n808 = n662[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n809 = n806 ? 1'b1 : n808;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n811 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n813 = $signed(32'b00000000000000000000000000001001) < $signed(n811);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n815 = n662[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n816 = n813 ? 1'b1 : n815;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n818 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n820 = $signed(32'b00000000000000000000000000001000) < $signed(n818);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n822 = n662[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n823 = n820 ? 1'b1 : n822;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n825 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n827 = $signed(32'b00000000000000000000000000000111) < $signed(n825);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n829 = n662[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n830 = n827 ? 1'b1 : n829;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n832 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n834 = $signed(32'b00000000000000000000000000000110) < $signed(n832);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n836 = n662[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n837 = n834 ? 1'b1 : n836;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n839 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n841 = $signed(32'b00000000000000000000000000000101) < $signed(n839);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n843 = n662[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n844 = n841 ? 1'b1 : n843;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n846 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n848 = $signed(32'b00000000000000000000000000000100) < $signed(n846);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n850 = n662[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n851 = n848 ? 1'b1 : n850;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n853 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n855 = $signed(32'b00000000000000000000000000000011) < $signed(n853);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n857 = n662[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n858 = n855 ? 1'b1 : n857;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n860 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n862 = $signed(32'b00000000000000000000000000000010) < $signed(n860);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n864 = n662[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n865 = n862 ? 1'b1 : n864;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n867 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n869 = $signed(32'b00000000000000000000000000000001) < $signed(n867);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n871 = n662[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n872 = n869 ? 1'b1 : n871;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n873 = n662[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n874 = {1'b0, n654};  // uext
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:12 */
  assign n876 = $signed(32'b00000000000000000000000000000000) < $signed(n874);
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:374:7 */
  assign n878 = n876 ? 1'b1 : n873;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:370:13 */
  assign n879 = {n661, n669, n676, n683, n690, n697, n704, n711, n718, n725, n732, n739, n746, n753, n760, n767, n774, n781, n788, n795, n802, n809, n816, n823, n830, n837, n844, n851, n858, n865, n872, n878};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n887 = n879[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n888 = n887 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n889 = n888 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n892 = n879[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n893 = n892 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n894 = n893 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n896 = n879[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n897 = n896 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n898 = n897 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n900 = n879[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n901 = n900 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n902 = n901 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n904 = n879[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n905 = n904 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n906 = n905 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n908 = n879[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n909 = n908 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n910 = n909 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n912 = n879[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n913 = n912 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n914 = n913 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n916 = n879[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n917 = n916 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n918 = n917 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n920 = n879[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n921 = n920 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n922 = n921 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n924 = n879[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n925 = n924 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n926 = n925 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n928 = n879[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n929 = n928 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n930 = n929 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n932 = n879[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n933 = n932 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n934 = n933 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n936 = n879[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n937 = n936 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n938 = n937 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n940 = n879[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n941 = n940 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n942 = n941 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n944 = n879[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n945 = n944 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n946 = n945 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n948 = n879[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n949 = n948 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n950 = n949 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n952 = n879[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n953 = n952 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n954 = n953 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n956 = n879[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n957 = n956 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n958 = n957 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n960 = n879[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n961 = n960 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n962 = n961 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n964 = n879[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n965 = n964 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n966 = n965 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n968 = n879[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n969 = n968 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n970 = n969 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n972 = n879[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n973 = n972 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n974 = n973 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n976 = n879[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n977 = n976 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n978 = n977 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n980 = n879[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n981 = n980 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n982 = n981 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n984 = n879[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n985 = n984 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n986 = n985 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n988 = n879[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n989 = n988 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n990 = n989 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n992 = n879[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n993 = n992 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n994 = n993 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n996 = n879[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n997 = n996 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n998 = n997 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n1000 = n879[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n1001 = n1000 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n1002 = n1001 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n1004 = n879[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n1005 = n1004 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n1006 = n1005 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n1008 = n879[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n1009 = n1008 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n1010 = n1009 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:17 */
  assign n1012 = n879[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:21 */
  assign n1013 = n1012 ^ n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:384:31 */
  assign n1014 = n1013 | n647;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:380:13 */
  assign n1015 = {n889, n894, n898, n902, n906, n910, n914, n918, n922, n926, n930, n934, n938, n942, n946, n950, n954, n958, n962, n966, n970, n974, n978, n982, n986, n990, n994, n998, n1002, n1006, n1010, n1014};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:11 */
  assign n1027 = shift_b[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1028 = a[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1029 = a[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1030 = a[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1031 = a[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1032 = a[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1033 = a[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1034 = a[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1035 = a[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1036 = a[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1037 = a[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1038 = a[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1039 = a[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1040 = a[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1041 = a[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1042 = a[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1043 = a[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1044 = a[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1045 = a[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1046 = a[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1047 = a[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1048 = a[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1049 = a[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1050 = a[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1051 = a[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1052 = a[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1053 = a[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1054 = a[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1055 = a[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1056 = a[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1057 = a[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1058 = a[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1059 = a[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1060 = a[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1061 = a[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1062 = a[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1063 = a[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1064 = a[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1065 = a[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1066 = a[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1067 = a[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1068 = a[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1069 = a[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1070 = a[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1071 = a[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1072 = a[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1073 = a[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1074 = a[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1075 = a[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1076 = a[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1077 = a[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1078 = a[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1079 = a[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1080 = a[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1081 = a[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1082 = a[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1083 = a[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1084 = a[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1085 = a[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1086 = a[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1087 = a[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1088 = a[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1089 = a[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1090 = a[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1091 = a[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1092 = {n1060, n1061, n1062, n1063, n1064, n1065, n1066, n1067, n1068, n1069, n1070, n1071, n1072, n1073, n1074, n1075, n1076, n1077, n1078, n1079, n1080, n1081, n1082, n1083, n1084, n1085, n1086, n1087, n1088, n1089, n1090, n1091};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1093 = {n1044, n1045, n1046, n1047, n1048, n1049, n1050, n1051, n1052, n1053, n1054, n1055, n1056, n1057, n1058, n1059, n1028, n1029, n1030, n1031, n1032, n1033, n1034, n1035, n1036, n1037, n1038, n1039, n1040, n1041, n1042, n1043};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1094 = n1027 ? n1093 : n1092;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:11 */
  assign n1100 = shift_b[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1101 = n1094[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1102 = n1094[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1103 = n1094[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1104 = n1094[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1105 = n1094[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1106 = n1094[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1107 = n1094[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1108 = n1094[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1109 = n1094[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1110 = n1094[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1111 = n1094[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1112 = n1094[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1113 = n1094[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1114 = n1094[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1115 = n1094[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1116 = n1094[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1117 = n1094[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1118 = n1094[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1119 = n1094[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1120 = n1094[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1121 = n1094[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1122 = n1094[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1123 = n1094[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1124 = n1094[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1125 = n1094[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1126 = n1094[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1127 = n1094[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1128 = n1094[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1129 = n1094[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1130 = n1094[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1131 = n1094[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1132 = n1094[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1133 = n1094[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1134 = n1094[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1135 = n1094[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1136 = n1094[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1137 = n1094[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1138 = n1094[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1139 = n1094[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1140 = n1094[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1141 = n1094[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1142 = n1094[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1143 = n1094[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1144 = n1094[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1145 = n1094[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1146 = n1094[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1147 = n1094[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1148 = n1094[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1149 = n1094[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1150 = n1094[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1151 = n1094[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1152 = n1094[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1153 = n1094[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1154 = n1094[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1155 = n1094[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1156 = n1094[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1157 = n1094[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1158 = n1094[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1159 = n1094[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1160 = n1094[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1161 = n1094[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1162 = n1094[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1163 = n1094[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1164 = n1094[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1165 = {n1133, n1134, n1135, n1136, n1137, n1138, n1139, n1140, n1141, n1142, n1143, n1144, n1145, n1146, n1147, n1148, n1149, n1150, n1151, n1152, n1153, n1154, n1155, n1156, n1157, n1158, n1159, n1160, n1161, n1162, n1163, n1164};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1166 = {n1109, n1110, n1111, n1112, n1113, n1114, n1115, n1116, n1117, n1118, n1119, n1120, n1121, n1122, n1123, n1124, n1125, n1126, n1127, n1128, n1129, n1130, n1131, n1132, n1101, n1102, n1103, n1104, n1105, n1106, n1107, n1108};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1167 = n1100 ? n1166 : n1165;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:11 */
  assign n1170 = shift_b[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1171 = n1167[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1172 = n1167[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1173 = n1167[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1174 = n1167[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1175 = n1167[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1176 = n1167[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1177 = n1167[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1178 = n1167[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1179 = n1167[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1180 = n1167[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1181 = n1167[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1182 = n1167[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1183 = n1167[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1184 = n1167[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1185 = n1167[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1186 = n1167[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1187 = n1167[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1188 = n1167[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1189 = n1167[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1190 = n1167[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1191 = n1167[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1192 = n1167[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1193 = n1167[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1194 = n1167[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1195 = n1167[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1196 = n1167[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1197 = n1167[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1198 = n1167[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1199 = n1167[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1200 = n1167[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1201 = n1167[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1202 = n1167[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1203 = n1167[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1204 = n1167[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1205 = n1167[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1206 = n1167[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1207 = n1167[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1208 = n1167[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1209 = n1167[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1210 = n1167[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1211 = n1167[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1212 = n1167[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1213 = n1167[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1214 = n1167[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1215 = n1167[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1216 = n1167[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1217 = n1167[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1218 = n1167[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1219 = n1167[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1220 = n1167[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1221 = n1167[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1222 = n1167[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1223 = n1167[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1224 = n1167[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1225 = n1167[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1226 = n1167[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1227 = n1167[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1228 = n1167[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1229 = n1167[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1230 = n1167[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1231 = n1167[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1232 = n1167[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1233 = n1167[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1234 = n1167[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1235 = {n1203, n1204, n1205, n1206, n1207, n1208, n1209, n1210, n1211, n1212, n1213, n1214, n1215, n1216, n1217, n1218, n1219, n1220, n1221, n1222, n1223, n1224, n1225, n1226, n1227, n1228, n1229, n1230, n1231, n1232, n1233, n1234};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1236 = {n1175, n1176, n1177, n1178, n1179, n1180, n1181, n1182, n1183, n1184, n1185, n1186, n1187, n1188, n1189, n1190, n1191, n1192, n1193, n1194, n1195, n1196, n1197, n1198, n1199, n1200, n1201, n1202, n1171, n1172, n1173, n1174};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1237 = n1170 ? n1236 : n1235;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:11 */
  assign n1240 = shift_b[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1241 = n1237[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1242 = n1237[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1243 = n1237[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1244 = n1237[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1245 = n1237[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1246 = n1237[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1247 = n1237[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1248 = n1237[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1249 = n1237[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1250 = n1237[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1251 = n1237[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1252 = n1237[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1253 = n1237[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1254 = n1237[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1255 = n1237[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1256 = n1237[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1257 = n1237[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1258 = n1237[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1259 = n1237[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1260 = n1237[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1261 = n1237[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1262 = n1237[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1263 = n1237[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1264 = n1237[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1265 = n1237[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1266 = n1237[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1267 = n1237[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1268 = n1237[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1269 = n1237[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1270 = n1237[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1271 = n1237[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1272 = n1237[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1273 = n1237[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1274 = n1237[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1275 = n1237[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1276 = n1237[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1277 = n1237[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1278 = n1237[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1279 = n1237[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1280 = n1237[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1281 = n1237[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1282 = n1237[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1283 = n1237[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1284 = n1237[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1285 = n1237[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1286 = n1237[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1287 = n1237[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1288 = n1237[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1289 = n1237[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1290 = n1237[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1291 = n1237[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1292 = n1237[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1293 = n1237[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1294 = n1237[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1295 = n1237[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1296 = n1237[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1297 = n1237[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1298 = n1237[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1299 = n1237[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1300 = n1237[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1301 = n1237[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1302 = n1237[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1303 = n1237[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1304 = n1237[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1305 = {n1273, n1274, n1275, n1276, n1277, n1278, n1279, n1280, n1281, n1282, n1283, n1284, n1285, n1286, n1287, n1288, n1289, n1290, n1291, n1292, n1293, n1294, n1295, n1296, n1297, n1298, n1299, n1300, n1301, n1302, n1303, n1304};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1306 = {n1243, n1244, n1245, n1246, n1247, n1248, n1249, n1250, n1251, n1252, n1253, n1254, n1255, n1256, n1257, n1258, n1259, n1260, n1261, n1262, n1263, n1264, n1265, n1266, n1267, n1268, n1269, n1270, n1271, n1272, n1241, n1242};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1307 = n1240 ? n1306 : n1305;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:11 */
  assign n1310 = shift_b[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1311 = n1307[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1312 = n1307[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1313 = n1307[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1314 = n1307[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1315 = n1307[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1316 = n1307[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1317 = n1307[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1318 = n1307[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1319 = n1307[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1320 = n1307[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1321 = n1307[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1322 = n1307[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1323 = n1307[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1324 = n1307[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1325 = n1307[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1326 = n1307[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1327 = n1307[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1328 = n1307[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1329 = n1307[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1330 = n1307[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1331 = n1307[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1332 = n1307[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1333 = n1307[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1334 = n1307[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1335 = n1307[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1336 = n1307[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1337 = n1307[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1338 = n1307[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1339 = n1307[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1340 = n1307[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1341 = n1307[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:350:24 */
  assign n1342 = n1307[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1343 = n1307[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1344 = n1307[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1345 = n1307[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1346 = n1307[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1347 = n1307[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1348 = n1307[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1349 = n1307[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1350 = n1307[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1351 = n1307[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1352 = n1307[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1353 = n1307[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1354 = n1307[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1355 = n1307[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1356 = n1307[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1357 = n1307[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1358 = n1307[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1359 = n1307[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1360 = n1307[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1361 = n1307[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1362 = n1307[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1363 = n1307[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1364 = n1307[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1365 = n1307[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1366 = n1307[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1367 = n1307[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1368 = n1307[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1369 = n1307[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1370 = n1307[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1371 = n1307[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1372 = n1307[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1373 = n1307[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:354:24 */
  assign n1374 = n1307[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1375 = {n1343, n1344, n1345, n1346, n1347, n1348, n1349, n1350, n1351, n1352, n1353, n1354, n1355, n1356, n1357, n1358, n1359, n1360, n1361, n1362, n1363, n1364, n1365, n1366, n1367, n1368, n1369, n1370, n1371, n1372, n1373, n1374};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1376 = {n1312, n1313, n1314, n1315, n1316, n1317, n1318, n1319, n1320, n1321, n1322, n1323, n1324, n1325, n1326, n1327, n1328, n1329, n1330, n1331, n1332, n1333, n1334, n1335, n1336, n1337, n1338, n1339, n1340, n1341, n1342, n1311};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:345:7 */
  assign n1377 = n1310 ? n1376 : n1375;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:442:42 */
  assign n1382 = a[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:396:11 */
  assign n1390 = sf == 2'b01;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:396:28 */
  assign n1391 = ~n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:396:19 */
  assign n1392 = n1391 & n1390;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:396:4 */
  assign n1394 = n1392 ? n1382 : 1'b0;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:398:8 */
  assign n1396 = n1015[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:398:50 */
  assign n1397 = n1377[0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:399:29 */
  assign n1399 = sf == 2'b11;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:399:21 */
  assign n1400 = n1399 & n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:399:4 */
  assign n1401 = n1400 ? shift_c : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:398:4 */
  assign n1402 = n1396 ? n1397 : n1401;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:402:8 */
  assign n1405 = n1015[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:402:59 */
  assign n1406 = n1377[31]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:403:15 */
  assign n1407 = ~n641;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:403:29 */
  assign n1409 = sf == 2'b11;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:403:21 */
  assign n1410 = n1409 & n1407;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:403:4 */
  assign n1411 = n1410 ? shift_c : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:402:4 */
  assign n1412 = n1405 ? n1406 : n1411;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1414 = n1015[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1415 = n1377[1]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1416 = n1414 ? n1415 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1418 = n1015[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1419 = n1377[2]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1420 = n1418 ? n1419 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1422 = n1015[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1423 = n1377[3]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1424 = n1422 ? n1423 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1426 = n1015[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1427 = n1377[4]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1428 = n1426 ? n1427 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1430 = n1015[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1431 = n1377[5]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1432 = n1430 ? n1431 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1434 = n1015[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1435 = n1377[6]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1436 = n1434 ? n1435 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1438 = n1015[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1439 = n1377[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1440 = n1438 ? n1439 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1442 = n1015[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1443 = n1377[8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1444 = n1442 ? n1443 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1446 = n1015[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1447 = n1377[9]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1448 = n1446 ? n1447 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1450 = n1015[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1451 = n1377[10]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1452 = n1450 ? n1451 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1454 = n1015[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1455 = n1377[11]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1456 = n1454 ? n1455 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1458 = n1015[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1459 = n1377[12]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1460 = n1458 ? n1459 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1462 = n1015[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1463 = n1377[13]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1464 = n1462 ? n1463 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1466 = n1015[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1467 = n1377[14]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1468 = n1466 ? n1467 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1470 = n1015[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1471 = n1377[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1472 = n1470 ? n1471 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1474 = n1015[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1475 = n1377[16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1476 = n1474 ? n1475 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1478 = n1015[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1479 = n1377[17]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1480 = n1478 ? n1479 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1482 = n1015[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1483 = n1377[18]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1484 = n1482 ? n1483 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1486 = n1015[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1487 = n1377[19]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1488 = n1486 ? n1487 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1490 = n1015[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1491 = n1377[20]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1492 = n1490 ? n1491 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1494 = n1015[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1495 = n1377[21]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1496 = n1494 ? n1495 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1498 = n1015[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1499 = n1377[22]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1500 = n1498 ? n1499 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1502 = n1015[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1503 = n1377[23]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1504 = n1502 ? n1503 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1506 = n1015[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1507 = n1377[24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1508 = n1506 ? n1507 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1510 = n1015[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1511 = n1377[25]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1512 = n1510 ? n1511 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1514 = n1015[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1515 = n1377[26]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1516 = n1514 ? n1515 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1518 = n1015[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1519 = n1377[27]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1520 = n1518 ? n1519 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1522 = n1015[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1523 = n1377[28]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1524 = n1522 ? n1523 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1526 = n1015[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1527 = n1377[29]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1528 = n1526 ? n1527 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:11 */
  assign n1530 = n1015[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:35 */
  assign n1531 = n1377[30]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:407:7 */
  assign n1532 = n1530 ? n1531 : n1394;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:390:13 */
  assign n1533 = {n1412, n1532, n1528, n1524, n1520, n1516, n1512, n1508, n1504, n1500, n1496, n1492, n1488, n1484, n1480, n1476, n1472, n1468, n1464, n1460, n1456, n1452, n1448, n1444, n1440, n1436, n1432, n1428, n1424, n1420, n1416, n1402};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:452:11 */
  assign n1547 = mf == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:453:18 */
  assign n1548 = b[7]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:455:18 */
  assign n1549 = b[15]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:452:3 */
  assign n1550 = n1547 ? n1548 : n1549;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:457:16 */
  assign n1552 = {n1550, n1550, n1550, n1550, n1550, n1550, n1550, n1550};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:462:33 */
  assign n1554 = b[31:24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:461:5 */
  assign n1556 = mf == 3'b000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:462:8 */
  assign n1558 = mf == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:462:8 */
  assign n1559 = n1556 | n1558;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:463:5 */
  assign n1561 = mf == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:464:8 */
  assign n1563 = mf == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:464:8 */
  assign n1564 = n1561 | n1563;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:465:5 */
  assign n1566 = mf == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:466:8 */
  assign n1568 = mf == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:466:8 */
  assign n1569 = n1566 | n1568;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:468:33 */
  assign n1570 = b[15:8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:460:3 */
  assign n1571 = {n1569, n1564, n1559};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:460:3 */
  always @*
    case (n1571)
      3'b100: n1573 = n1552;
      3'b010: n1573 = 8'b00000000;
      3'b001: n1573 = n1554;
      default: n1573 = n1570;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:472:33 */
  assign n1575 = b[23:16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:471:5 */
  assign n1577 = mf == 3'b000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:472:8 */
  assign n1579 = mf == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:472:8 */
  assign n1580 = n1577 | n1579;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:473:5 */
  assign n1582 = mf == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:474:8 */
  assign n1584 = mf == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:474:8 */
  assign n1585 = n1582 | n1584;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:475:5 */
  assign n1587 = mf == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:476:8 */
  assign n1589 = mf == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:476:8 */
  assign n1590 = n1587 | n1589;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:478:33 */
  assign n1591 = b[7:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:470:3 */
  assign n1592 = {n1590, n1585, n1580};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:470:3 */
  always @*
    case (n1592)
      3'b100: n1594 = n1552;
      3'b010: n1594 = 8'b00000000;
      3'b001: n1594 = n1575;
      default: n1594 = n1591;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:481:33 */
  assign n1596 = b[7:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:481:5 */
  assign n1598 = mf == 3'b000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:482:33 */
  assign n1599 = b[31:24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:482:5 */
  assign n1601 = mf == 3'b001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:483:5 */
  assign n1603 = mf == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:486:33 */
  assign n1604 = b[15:8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:484:5 */
  assign n1606 = mf == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:485:8 */
  assign n1608 = mf == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:485:8 */
  assign n1609 = n1606 | n1608;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:486:8 */
  assign n1611 = mf == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:486:8 */
  assign n1612 = n1609 | n1611;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:487:5 */
  assign n1614 = mf == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:489:33 */
  assign n1615 = a[31:24]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:480:3 */
  assign n1616 = {n1614, n1612, n1603, n1601, n1598};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:480:3 */
  always @*
    case (n1616)
      5'b10000: n1618 = n1552;
      5'b01000: n1618 = n1604;
      5'b00100: n1618 = 8'b00000000;
      5'b00010: n1618 = n1599;
      5'b00001: n1618 = n1596;
      default: n1618 = n1615;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:492:33 */
  assign n1620 = b[15:8]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:492:5 */
  assign n1622 = mf == 3'b000;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:493:33 */
  assign n1623 = b[23:16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:493:5 */
  assign n1625 = mf == 3'b001;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:497:33 */
  assign n1626 = b[7:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:494:5 */
  assign n1628 = mf == 3'b010;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:495:8 */
  assign n1630 = mf == 3'b011;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:495:8 */
  assign n1631 = n1628 | n1630;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:496:8 */
  assign n1633 = mf == 3'b100;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:496:8 */
  assign n1634 = n1631 | n1633;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:497:8 */
  assign n1636 = mf == 3'b101;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:497:8 */
  assign n1637 = n1634 | n1636;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:498:39 */
  assign n1638 = b[6:0]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:498:36 */
  assign n1640 = {1'b1, n1638};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:498:5 */
  assign n1642 = mf == 3'b111;
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:500:33 */
  assign n1643 = a[23:16]; // extract
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:491:3 */
  assign n1644 = {n1642, n1637, n1625, n1622};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:491:3 */
  always @*
    case (n1644)
      4'b1000: n1645 = n1640;
      4'b0100: n1645 = n1626;
      4'b0010: n1645 = n1623;
      4'b0001: n1645 = n1620;
      default: n1645 = n1643;
    endcase
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:502:13 */
  assign n1647 = {n1573, n1594};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:502:18 */
  assign n1648 = {n1647, n1618};
  /*# /home/imi415/Documents/Hardwares/TD_Projects/J2/reference/soc_top/components/cpu/core/components_pkg.vhd:502:23 */
  assign n1649 = {n1648, n1645};
endmodule

