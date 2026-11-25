; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-linux-gnu"

@AES_sbox = local_unnamed_addr constant [256 x i8] c"c|w{\F2ko\C50\01g+\FE\D7\ABv\CA\82\C9}\FAYG\F0\AD\D4\A2\AF\9C\A4r\C0\B7\FD\93&6?\F7\CC4\A5\E5\F1q\D81\15\04\C7#\C3\18\96\05\9A\07\12\80\E2\EB'\B2u\09\83,\1A\1BnZ\A0R;\D6\B3)\E3/\84S\D1\00\ED \FC\B1[j\CB\BE9JLX\CF\D0\EF\AA\FBCM3\85E\F9\02\7FP<\9F\A8Q\A3@\8F\92\9D8\F5\BC\B6\DA!\10\FF\F3\D2\CD\0C\13\EC_\97D\17\C4\A7~=d]\19s`\81O\DC\22*\90\88F\EE\B8\14\DE^\0B\DB\E02:\0AI\06$\\\C2\D3\ACb\91\95\E4y\E7\C87m\8D\D5N\A9lV\F4\EAez\AE\08\BAx%.\1C\A6\B4\C6\E8\DDt\1FK\BD\8B\8Ap>\B5fH\03\F6\0Ea5W\B9\86\C1\1D\9E\E1\F8\98\11i\D9\8E\94\9B\1E\87\E9\CEU(\DF\8C\A1\89\0D\BF\E6BhA\99-\0F\B0T\BB\16", align 1
@AES_isbox = local_unnamed_addr constant [256 x i8] c"R\09j\D506\A58\BF@\A3\9E\81\F3\D7\FB|\E39\82\9B/\FF\874\8ECD\C4\DE\E9\CBT{\942\A6\C2#=\EEL\95\0BB\FA\C3N\08.\A1f(\D9$\B2v[\A2Im\8B\D1%r\F8\F6d\86h\98\16\D4\A4\\\CC]e\B6\92lpHP\FD\ED\B9\DA^\15FW\A7\8D\9D\84\90\D8\AB\00\8C\BC\D3\0A\F7\E4X\05\B8\B3E\06\D0,\1E\8F\CA?\0F\02\C1\AF\BD\03\01\13\8Ak:\91\11AOg\DC\EA\97\F2\CF\CE\F0\B4\E6s\96\ACt\22\E7\AD5\85\E2\F97\E8\1Cu\DFnG\F1\1Aq\1D)\C5\89o\B7b\0E\AA\18\BE\1B\FCV>K\C6\D2y \9A\DB\C0\FEx\CDZ\F4\1F\DD\A83\88\07\C71\B1\12\10Y'\80\EC_`Q\7F\A9\19\B5J\0D-\E5z\9F\93\C9\9C\EF\A0\E0;M\AE*\F5\B0\C8\EB\BB<\83S\99a\17+\04~\BAw\D6&\E1i\14cU!\0C}", align 1
@AES_Te0 = local_unnamed_addr constant [256 x i32] [i32 -966564955, i32 -126059388, i32 -294160487, i32 -159679603, i32 -855539, i32 -697603139, i32 -563122255, i32 -1849309868, i32 1613770832, i32 33620227, i32 -832084055, i32 1445669757, i32 -402719207, i32 -1244145822, i32 1303096294, i32 -327780710, i32 -1882535355, i32 528646813, i32 -1983264448, i32 -92439161, i32 -268764651, i32 -1302767125, i32 -1907931191, i32 -68095989, i32 1101901292, i32 -1277897625, i32 1604494077, i32 1169141738, i32 597466303, i32 1403299063, i32 -462261610, i32 -1681866661, i32 1974974402, i32 -503448292, i32 1033081774, i32 1277568618, i32 1815492186, i32 2118074177, i32 -168298750, i32 -2083730353, i32 1748251740, i32 1369810420, i32 -773462732, i32 -101584632, i32 -495881837, i32 -1411852173, i32 1647391059, i32 706024767, i32 134480908, i32 -1782069422, i32 1176707941, i32 -1648114850, i32 806885416, i32 932615841, i32 168101135, i32 798661301, i32 235341577, i32 605164086, i32 461406363, i32 -538779075, i32 -840176858, i32 1311188841, i32 2142417613, i32 -361400929, i32 302582043, i32 495158174, i32 1479289972, i32 874125870, i32 907746093, i32 -596742478, i32 -1269146898, i32 1537253627, i32 -1538108682, i32 1983593293, i32 -1210657183, i32 2108928974, i32 1378429307, i32 -572267714, i32 1580150641, i32 327451799, i32 -1504488459, i32 -1177431704, i32 0, i32 -1041371860, i32 1075847264, i32 -469959649, i32 2041688520, i32 -1235526675, i32 -731223362, i32 -1916023994, i32 1740553945, i32 1916352843, i32 -1807070498, i32 -1739830060, i32 -1336387352, i32 -2049978550, i32 -1143943061, i32 -974131414, i32 1336584933, i32 -302253290, i32 -2042412091, i32 -1706209833, i32 1714631509, i32 293963156, i32 -1975171633, i32 -369493744, i32 67240454, i32 -25198719, i32 -1605349136, i32 2017213508, i32 631218106, i32 1269344483, i32 -1571728909, i32 1571005438, i32 -2143272768, i32 93294474, i32 1066570413, i32 563977660, i32 1882732616, i32 -235539196, i32 1673313503, i32 2008463041, i32 -1344611723, i32 1109467491, i32 537923632, i32 -436207846, i32 -34344178, i32 -1076702611, i32 -2117218996, i32 403442708, i32 638784309, i32 -1007883217, i32 -1101045791, i32 899127202, i32 -2008791860, i32 773265209, i32 -1815821225, i32 1437050866, i32 -58818942, i32 2050833735, i32 -932944724, i32 -1168286233, i32 840505643, i32 -428641387, i32 -1067425632, i32 427917720, i32 -1638969391, i32 -1545806721, i32 1143087718, i32 1412049534, i32 999329963, i32 193497219, i32 -1941551414, i32 -940642775, i32 1807268051, i32 672404540, i32 -1478566279, i32 -1134666014, i32 369822493, i32 -1378100362, i32 -606019525, i32 1681011286, i32 1949973070, i32 336202270, i32 -1840690725, i32 201721354, i32 1210328172, i32 -1201906460, i32 -1614626211, i32 -1110191250, i32 1135389935, i32 -1000185178, i32 965841320, i32 831886756, i32 -739974089, i32 -226920053, i32 -706222286, i32 -1949775805, i32 1849112409, i32 -630362697, i32 26054028, i32 -1311386268, i32 -1672589614, i32 1235855840, i32 -663982924, i32 -1403627782, i32 -202050553, i32 -806688219, i32 -899324497, i32 -193299826, i32 1202630377, i32 268961816, i32 1874508501, i32 -260540280, i32 1243948399, i32 1546530418, i32 941366308, i32 1470539505, i32 1941222599, i32 -1748580783, i32 -873928669, i32 -1579295364, i32 -395021156, i32 1042226977, i32 -1773450275, i32 1639824860, i32 227249030, i32 260737669, i32 -529502064, i32 2084453954, i32 1907733956, i32 -865704278, i32 -1874310952, i32 100860677, i32 -134810111, i32 470683154, i32 -1033805405, i32 1781871967, i32 -1370007559, i32 1773779408, i32 394692241, i32 -1715355304, i32 974986535, i32 664706745, i32 -639508168, i32 -336005101, i32 731420851, i32 571543859, i32 -764843589, i32 -1445340816, i32 126783113, i32 865375399, i32 765172662, i32 1008606754, i32 361203602, i32 -907417312, i32 -2016489911, i32 -1437248001, i32 1344809080, i32 -1512054918, i32 59542671, i32 1503764984, i32 160008576, i32 437062935, i32 1707065306, i32 -672733647, i32 -2076032314, i32 -798463816, i32 -2109652541, i32 697932208, i32 1512910199, i32 504303377, i32 2075177163, i32 -1470868228, i32 1841019862, i32 739644986], align 4
@AES_Td0 = local_unnamed_addr constant [256 x i32] [i32 1374988112, i32 2118214995, i32 437757123, i32 975658646, i32 1001089995, i32 530400753, i32 -1392879445, i32 1273168787, i32 540080725, i32 -1384747530, i32 -1999866223, i32 -184398811, i32 1340463100, i32 -987051049, i32 641025152, i32 -1251826801, i32 -558802359, i32 632953703, i32 1172967064, i32 1576976609, i32 -1020300030, i32 -2125664238, i32 -1924753501, i32 1809054150, i32 59727847, i32 361929877, i32 -1083344149, i32 -1789765158, i32 -725712083, i32 1484005843, i32 1239443753, i32 -1899378620, i32 1975683434, i32 -191989384, i32 -1722270101, i32 666464733, i32 -1092530250, i32 -259478249, i32 -920605594, i32 2110667444, i32 1675577880, i32 -451268222, i32 -1756286112, i32 1649639237, i32 -1318815776, i32 -1150570876, i32 -25059300, i32 -116905068, i32 1883793496, i32 -1891238631, i32 -1797362553, i32 1383856311, i32 -1418472669, i32 1917518562, i32 -484470953, i32 1716890410, i32 -1293211641, i32 800440835, i32 -2033878118, i32 -751368027, i32 807962610, i32 599762354, i32 33778362, i32 -317291940, i32 -1966138325, i32 -1485196142, i32 -217582864, i32 1315562145, i32 1708848333, i32 101039829, i32 -785096161, i32 -995688822, i32 875451293, i32 -1561111136, i32 92987698, i32 -1527321739, i32 193195065, i32 1080094634, i32 1584504582, i32 -1116860335, i32 1042385657, i32 -1763899843, i32 -583137874, i32 1306967366, i32 -1856729675, i32 1908694277, i32 67556463, i32 1615861247, i32 429456164, i32 -692196969, i32 -1992277044, i32 1742315127, i32 -1326955843, i32 126454664, i32 -417768648, i32 2043211483, i32 -1585706425, i32 2084704233, i32 -125559095, i32 0, i32 159417987, i32 841739592, i32 504459436, i32 1817866830, i32 -49348613, i32 260388950, i32 1034867998, i32 908933415, i32 168810852, i32 1750902305, i32 -1688513327, i32 607530554, i32 202008497, i32 -1822955761, i32 -1259432238, i32 463180190, i32 -2134850225, i32 1641816226, i32 1517767529, i32 470948374, i32 -493635062, i32 -1063245083, i32 1008918595, i32 303765277, i32 235474187, i32 -225720403, i32 766945465, i32 337553864, i32 1475418501, i32 -1351284916, i32 -291906117, i32 -1551933187, i32 -150919521, i32 1551037884, i32 1147550661, i32 1543208500, i32 -1958532746, i32 -886847780, i32 -1225917336, i32 -1192955549, i32 -684598070, i32 1113818384, i32 328671808, i32 -2067394272, i32 -2058738563, i32 -759480840, i32 -1359400431, i32 -953573011, i32 496906059, i32 -592301837, i32 226906860, i32 2009195472, i32 733156972, i32 -1452230247, i32 294930682, i32 1206477858, i32 -1459843900, i32 -1594867942, i32 1451044056, i32 573804783, i32 -2025238841, i32 -650587711, i32 -1932877058, i32 -1730933962, i32 -1493859889, i32 -1518674392, i32 -625504730, i32 1068351396, i32 742039012, i32 1350078989, i32 1784663195, i32 1417561698, i32 -158526526, i32 -1864845080, i32 775550814, i32 -2101104651, i32 -1621262146, i32 1775276924, i32 1876241833, i32 -819653965, i32 -928212677, i32 270040487, i32 -392404114, i32 -616842373, i32 -853116919, i32 1851332852, i32 -325404927, i32 -2091935064, i32 -426414491, i32 -1426069890, i32 566021896, i32 -283776794, i32 -1159226407, i32 1248802510, i32 -358676012, i32 699432150, i32 832877231, i32 708780849, i32 -962227152, i32 899835584, i32 1951317047, i32 -58537306, i32 -527380304, i32 866637845, i32 -251357110, i32 1106041591, i32 2144161806, i32 395441711, i32 1984812685, i32 1139781709, i32 -861254316, i32 -459930401, i32 -1630423581, i32 1282050075, i32 -1054072904, i32 1181045119, i32 -1654724092, i32 25965917, i32 -91786125, i32 -83148498, i32 -1285087910, i32 -1831087534, i32 -384805325, i32 1842759443, i32 -1697160820, i32 933301370, i32 1509430414, i32 -351060855, i32 -827774994, i32 -1218328267, i32 -518199827, i32 2051518780, i32 -1663901863, i32 1441952575, i32 404016761, i32 1942435775, i32 1408749034, i32 1610459739, i32 -549621996, i32 2017778566, i32 -894438527, i32 -1184316354, i32 941896748, i32 -1029488545, i32 371049330, i32 -1126030068, i32 675039627, i32 -15887039, i32 967311729, i32 135050206, i32 -659233636, i32 1683407248, i32 2076935265, i32 -718096784, i32 1215061108, i32 -793225406], align 4

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx55aa" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !7
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp5.stack = alloca ptr, align 8
  %tmp6.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] mov_i64 [t0],0xffffffffffffffe1 ========
  store i64 -31, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !10
; ======== TCG [1] func_addr t5,helper_pshufd_xmm,v0,v0 ========
  store ptr @helper_pshufd_xmm_qemuaot_V0_V0, ptr %tmp5.stack, align 8, !tbaa !7, !tcg.op !11
; ======== TCG [2] func_addr t6,0x55aa,0x1 ========
  store ptr @Fx55aa_1, ptr %tmp6.stack, align 8, !tbaa !7, !tcg.op !12
; ======== TCG [3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0, ========
  %T3.loaded_fn = load ptr, ptr %tmp5.stack, align 8, !tcg.op !13
  %T3.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !13
  %T3.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !7, !tcg.op !13
  %T3.vector_insert = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T3.v0.stack, i64 0), !tcg.op !13
  %T3.vector_insert1 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm0_h, i64 0), !tcg.op !13
  %T3.vector_insert2 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm1, i64 0), !tcg.op !13
  %T3.vector_insert3 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm1_h, i64 0), !tcg.op !13
  %T3.vector_insert4 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm2, i64 0), !tcg.op !13
  %T3.vector_insert5 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm2_h, i64 0), !tcg.op !13
  %T3.vector_insert6 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm3, i64 0), !tcg.op !13
  %T3.vector_insert7 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm3_h, i64 0), !tcg.op !13
  %T3.vector_insert8 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm4, i64 0), !tcg.op !13
  %T3.vector_insert9 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm4_h, i64 0), !tcg.op !13
  %T3.vector_insert10 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm5, i64 0), !tcg.op !13
  %T3.vector_insert11 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm5_h, i64 0), !tcg.op !13
  %T3.vector_insert12 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm6, i64 0), !tcg.op !13
  %T3.vector_insert13 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm6_h, i64 0), !tcg.op !13
  %T3.vector_insert14 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm7, i64 0), !tcg.op !13
  %T3.vector_insert15 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm7_h, i64 0), !tcg.op !13
  %T3.vector_insert16 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm8, i64 0), !tcg.op !13
  %T3.vector_insert17 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm8_h, i64 0), !tcg.op !13
  %T3.vector_insert18 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm9, i64 0), !tcg.op !13
  %T3.vector_insert19 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm9_h, i64 0), !tcg.op !13
  %T3.vector_insert20 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm10, i64 0), !tcg.op !13
  %T3.vector_insert21 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm10_h, i64 0), !tcg.op !13
  %T3.vector_insert22 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm11, i64 0), !tcg.op !13
  %T3.vector_insert23 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm11_h, i64 0), !tcg.op !13
  %T3.vector_insert24 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm12, i64 0), !tcg.op !13
  %T3.vector_insert25 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm12_h, i64 0), !tcg.op !13
  %T3.vector_insert26 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %xmm13, i64 0), !tcg.op !13
  %T3.vector_insert27 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %ymm13_h, i64 0), !tcg.op !13
  %T3.tmp6 = load i64, ptr %tmp6.stack, align 8, !tbaa !7, !tcg.op !13
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T3.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %T3.vector_insert, <vscale x 1 x i64> %T3.vector_insert1, <vscale x 1 x i64> %T3.vector_insert2, <vscale x 1 x i64> %T3.vector_insert3, <vscale x 1 x i64> %T3.vector_insert4, <vscale x 1 x i64> %T3.vector_insert5, <vscale x 1 x i64> %T3.vector_insert6, <vscale x 1 x i64> %T3.vector_insert7, <vscale x 1 x i64> %T3.vector_insert8, <vscale x 1 x i64> %T3.vector_insert9, <vscale x 1 x i64> %T3.vector_insert10, <vscale x 1 x i64> %T3.vector_insert11, <vscale x 1 x i64> %T3.vector_insert12, <vscale x 1 x i64> %T3.vector_insert13, <vscale x 1 x i64> %T3.vector_insert14, <vscale x 1 x i64> %T3.vector_insert15, <vscale x 1 x i64> %T3.vector_insert16, <vscale x 1 x i64> %T3.vector_insert17, <vscale x 1 x i64> %T3.vector_insert18, <vscale x 1 x i64> %T3.vector_insert19, <vscale x 1 x i64> %T3.vector_insert20, <vscale x 1 x i64> %T3.vector_insert21, <vscale x 1 x i64> %T3.vector_insert22, <vscale x 1 x i64> %T3.vector_insert23, <vscale x 1 x i64> %T3.vector_insert24, <vscale x 1 x i64> %T3.vector_insert25, <vscale x 1 x i64> %T3.vector_insert26, <vscale x 1 x i64> %T3.vector_insert27, ptr %cpu, i32 225, i64 %T3.tmp6), !tcg.op !13
  ret void, !tcg.op !13
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot void @helper_pshufd_xmm_qemuaot_V0_V0(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef signext %qemuaot_op, i64 noundef %rip, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, ptr noundef %cpu_param, i32 noundef signext %order, i64 noundef %normal_return) local_unnamed_addr #1 {
entry:
  %xmm0 = tail call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64(<vscale x 1 x i64> %xmm0.coerce, i64 0)
  %and = and i32 %order, 3
  %shr = lshr i32 %order, 2
  %and28 = and i32 %shr, 3
  %shr31 = lshr i32 %order, 4
  %and32 = and i32 %shr31, 3
  %shr35 = lshr i32 %order, 6
  %and36 = and i32 %shr35, 3
  %0 = bitcast <2 x i64> %xmm0 to <4 x i32>
  %vecext = extractelement <4 x i32> %0, i32 %and
  %vecext30 = extractelement <4 x i32> %0, i32 %and28
  %vecext34 = extractelement <4 x i32> %0, i32 %and32
  %vecext38 = extractelement <4 x i32> %0, i32 %and36
  %vecins = insertelement <4 x i32> poison, i32 %vecext, i64 0
  %vecins41 = insertelement <4 x i32> %vecins, i32 %vecext30, i64 1
  %vecins44 = insertelement <4 x i32> %vecins41, i32 %vecext34, i64 2
  %vecins47 = insertelement <4 x i32> %vecins44, i32 %vecext38, i64 3
  %1 = bitcast <4 x i32> %vecins47 to <2 x i64>
  %2 = inttoptr i64 %normal_return to ptr
  %cast.scalable = tail call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64(<vscale x 1 x i64> poison, <2 x i64> %1, i64 0)
  tail call qemuaot void %2(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef signext %qemuaot_op, i64 noundef %rip, <vscale x 1 x i64> noundef %cast.scalable, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, ptr noundef %cpu_param) #4
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <2 x i64> @llvm.vector.extract.v2i64.nxv1i64(<vscale x 1 x i64>, i64 immarg) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64(<vscale x 1 x i64>, <2 x i64>, i64 immarg) #2

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa_1(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx55aa_1" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !7
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp4.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] add_i64 [t3],rsi,0x10 ========
  %T0.rsi = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !14
  %T0.out = add i64 %T0.rsi, 16, !tcg.op !14
  store i64 %T0.out, ptr %tmp3.stack, align 8, !tbaa !7, !tcg.op !14
; ======== TCG [1] func_addr t4,0xaa55,0x0 ========
  store ptr @Fxaa55, ptr %tmp4.stack, align 8, !tbaa !7, !tcg.op !15
; ======== TCG [2] tail_call_qemuaot t4 VEC_ARGS: ========
  %T2.loaded_fn = load ptr, ptr %tmp4.stack, align 8, !tcg.op !16
  %T2.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !16
  %T2.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !7, !tcg.op !16
  tail call qemuaot void %T2.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T2.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T2.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !16
  ret void, !tcg.op !16
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64>, <2 x i64>, i64 immarg) #2

; Function Attrs: nounwind
declare qemuaot void @Fxaa55(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26544)) #3 section ".text.Fxaa55"

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { alwaysinline nounwind vscale_range(2,1024) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv64" "target-features"="+64bit,+a,+d,+f,+m,+relax,+v,+zaamo,+zalrsc,+zicsr,+zmmul,+zve32f,+zve32x,+zve64d,+zve64f,+zve64x,+zvl128b,+zvl32b,+zvl64b,-b,-c,-e,-experimental-p,-experimental-smctr,-experimental-ssctr,-experimental-svukte,-experimental-xqccmp,-experimental-xqcia,-experimental-xqciac,-experimental-xqcibi,-experimental-xqcibm,-experimental-xqcicli,-experimental-xqcicm,-experimental-xqcics,-experimental-xqcicsr,-experimental-xqciint,-experimental-xqciio,-experimental-xqcilb,-experimental-xqcili,-experimental-xqcilia,-experimental-xqcilo,-experimental-xqcilsm,-experimental-xqcisim,-experimental-xqcisls,-experimental-xqcisync,-experimental-xrivosvisni,-experimental-xrivosvizip,-experimental-xsfmclic,-experimental-xsfsclic,-experimental-zalasr,-experimental-zicfilp,-experimental-zicfiss,-experimental-zvbc32e,-experimental-zvkgs,-experimental-zvqdotq,-h,-q,-sdext,-sdtrig,-sha,-shcounterenw,-shgatpa,-shlcofideleg,-shtvala,-shvsatpa,-shvstvala,-shvstvecd,-smaia,-smcdeleg,-smcntrpmf,-smcsrind,-smdbltrp,-smepmp,-smmpm,-smnpm,-smrnmi,-smstateen,-ssaia,-ssccfg,-ssccptr,-sscofpmf,-sscounterenw,-sscsrind,-ssdbltrp,-ssnpm,-sspm,-ssqosid,-ssstateen,-ssstrict,-sstc,-sstvala,-sstvecd,-ssu64xl,-supm,-svade,-svadu,-svbare,-svinval,-svnapot,-svpbmt,-svvptc,-xandesperf,-xandesvbfhcvt,-xandesvdot,-xandesvpackfph,-xandesvsintload,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xmipscbop,-xmipscmov,-xmipslsp,-xsfcease,-xsfmm128t,-xsfmm16t,-xsfmm32a16f,-xsfmm32a32f,-xsfmm32a8f,-xsfmm32a8i,-xsfmm32t,-xsfmm64a64f,-xsfmm64t,-xsfmmbase,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xsifivecdiscarddlone,-xsifivecflushdlone,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-xwchc,-za128rs,-za64rs,-zabha,-zacas,-zama16b,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zclsd,-zcmop,-zcmp,-zcmt,-zdinx,-zfa,-zfbfmin,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccamoc,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zifencei,-zihintntl,-zihintpause,-zihpm,-zilsd,-zimop,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-ztso,-zvbb,-zvbc,-zvfbfmin,-zvfbfwma,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl4096b,-zvl512b,-zvl65536b,-zvl8192b" }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #4 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3, !5, !6}

!0 = !{!"<COMPILER_VERSION>"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"target-abi", !"lp64d"}
!3 = !{i32 6, !"riscv-isa", !4}
!4 = !{!"rv64i2p1_m2p0_a2p1_f2p2_d2p2_v1p0_zicsr2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"}
!5 = !{i32 8, !"PIC Level", i32 2}
!6 = !{i32 8, !"SmallDataLimit", i32 0}
!7 = !{!8, !8, i64 0}
!8 = !{!"SpillSlo", !9}
!9 = !{!"Root"}
!10 = !{!"[0] mov_i64 [t0],0xffffffffffffffe1"}
!11 = !{!"[1] func_addr t5,helper_pshufd_xmm,v0,v0"}
!12 = !{!"[2] func_addr t6,0x55aa,0x1"}
!13 = !{!"[3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0,"}
!14 = !{!"[0] add_i64 [t3],rsi,0x10"}
!15 = !{!"[1] func_addr t4,0xaa55,0x0"}
!16 = !{!"[2] tail_call_qemuaot t4 VEC_ARGS:"}
