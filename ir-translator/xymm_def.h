#ifndef XYMM_DEF_H
#define XYMM_DEF_H

#if XMM_COUNT == 15
#define XMM_PARAM_DECLARE_COMMON    \
      ", v2ulong xmm0, v2ulong ymm0_h, v2ulong xmm1, v2ulong ymm1_h, v2ulong xmm2, v2ulong ymm2_h, v2ulong xmm3, v2ulong ymm3_h, v2ulong xmm4, v2ulong ymm4_h, v2ulong xmm5, v2ulong ymm5_h, v2ulong xmm6, v2ulong ymm6_h, v2ulong xmm7, v2ulong ymm7_h, v2ulong xmm8, v2ulong ymm8_h, v2ulong xmm9, v2ulong ymm9_h, v2ulong xmm10, v2ulong ymm10_h, v2ulong xmm11, v2ulong ymm11_h, v2ulong xmm12, v2ulong ymm12_h, v2ulong xmm13, v2ulong ymm13_h, v2ulong xmm14, v2ulong ymm14_h"
#define XMM_PARAM_LIST              \
      ", xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h"
#elif XMM_COUNT == 0
#define XMM_PARAM_DECLARE_COMMON    ""
#define XMM_PARAM_LIST              ""
#endif

#endif
