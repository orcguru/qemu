/* ============================================================ * Logical NOT * ============================================================ */
#define CREATE_NOT(OUT, IN)                                                 \
    do {                                                                    \
        BUILD_INSTR(2);                                               \
        if (is_vec) {                                                       \
            BI_OPCODE(not_vec);                                         \
            BI_VS(OPC_VECTOR_SIZE(type_out));                          \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                      \
            BI_SLOT_IN (1, IN);                                       \
        } else {                                                           \
            BI_OPCODE(type_out == LLVMInt32 ? not_i32 : not_i64);      \
            BI_SLOT_OUT(0, OUT);                                      \
            BI_SLOT_IN (1, IN);                                       \
        }                                                                  \
        BI_EXEC_DIRECT(translate_not);                              \
    } while (0)

/* ============================================================ * AND * ============================================================ */
#define CREATE_AND(OUT, IN0, IN1)                                         \
    do {                                                                   \
        BUILD_INSTR(3);                                               \
        if (is_vec) {                                                      \
            BI_OPCODE(and_vec);                                        \
            BI_VS(OPC_VECTOR_SIZE(type_out));                         \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        } else {                                                           \
            assert(OPC_OUTPUT_T != LLVMInvalidType);                       \
            BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? and_i32 : and_i64); \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        }                                                                  \
        BI_EXEC(translate_binary, LLVMBuildAnd);                  \
    } while (0)

/* ============================================================ * ANDC (vector only) * ============================================================ */
#define CREATE_ANDC_VEC(OUT, IN0, IN1)                                    \
    do {                                                                   \
        assert(is_vec);                                                    \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(andc_vec);                                          \
        BI_VS(OPC_VECTOR_SIZE(type_out));                             \
        BI_VES(OPC_VECTOR_TO_VES(type_out));                          \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_EXEC_DIRECT(translate_andc);                               \
    } while (0)

/* ============================================================ * XOR * ============================================================ */
#define CREATE_XOR(OUT, IN0, IN1)                                         \
    do {                                                                   \
        BUILD_INSTR(3);                                               \
        if (is_vec) {                                                      \
            BI_OPCODE(xor_vec);                                       \
            BI_VS(OPC_VECTOR_SIZE(type_out));                         \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        } else {                                                           \
            assert(OPC_OUTPUT_T != LLVMInvalidType);                       \
            BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? xor_i32 : xor_i64); \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        }                                                                  \
        BI_EXEC(translate_binary, LLVMBuildXor);                  \
    } while (0)

/* ============================================================ * XOR with immediate second operand * ============================================================ */
#define CREATE_XOR_IMM2(OUT, IN0, IN1)                                    \
    do {                                                                   \
        BUILD_INSTR(3);                                               \
        if (is_vec) {                                                      \
            BI_OPCODE(xor_vec);                                       \
            BI_VS(OPC_VECTOR_SIZE(type_out));                         \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_IMM     (2, (IN1));  /* IN1 is an immediate value */  \
        } else {                                                           \
            assert(OPC_OUTPUT_T != LLVMInvalidType);                       \
            BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? xor_i32 : xor_i64); \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_IMM     (2, (IN1));                                   \
        }                                                                  \
        BI_EXEC(translate_binary, LLVMBuildXor);                  \
    } while (0)

/* ============================================================ * EXTRACT (extract_i32 / extract_i64) * ============================================================ */
#define CREATE_EXTRACT(OUT, IN0, IN1, IN2)                                \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(4);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? extract_i32 : extract_i64); \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));                                       \
        BI_IMM     (3, (IN2));                                       \
        BI_EXEC_DIRECT(translate_extract);                             \
    } while (0)

/* ============================================================ * SHR (logical shift right) – scalar slot operands * ============================================================ */
#define CREATE_SHR(OUT, IN0, IN1)                                         \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? shr_i32 : shr_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));   /* immediate shift amount */        \
        BI_EXEC(translate_binary, LLVMBuildLShr);                    \
    } while (0)

/* SHR with a slot operand (not immediate) */
#define CREATE_SHR_SLOT(OUT, IN0, IN1)                                    \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? shr_i32 : shr_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_EXEC(translate_binary, LLVMBuildLShr);                    \
    } while (0)

/* ============================================================ * SHR for vectors (shri_vec) * ============================================================ */
#define CREATE_SHR_VEC(OUT, IN0, IN1, SPLAT)                              \
    do {                                                                   \
        assert(is_vec);                                                    \
        BUILD_INSTR(3);                                                 \
        BI_OPCODE(shri_vec);                                           \
        BI_VS(OPC_VECTOR_SIZE(type_out));                             \
        BI_VES(OPC_VECTOR_TO_VES(type_out));                          \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        if (SPLAT) {                                                  \
            BI_IMM(2, (IN1.i));   /* IN1 is an OperandType imm */    \
            translate_binary_splat_immediate(__bi_u->opc, __bi_u, LLVMBuildLShr);                                   \
        } else {                                                       \
            BI_SLOT_IN(2, IN1);                                      \
            translate_binary(__bi_u->opc, __bi_u, LLVMBuildLShr);                                   \
        }                                                              \
    } while (0)

/* ============================================================ * SHL (logical shift left) – scalar * ============================================================ */
#define CREATE_SHL(OUT, IN0, IN1)                                         \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? shl_i32 : shl_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));                                       \
        BI_EXEC(translate_binary, LLVMBuildShl);                      \
    } while (0)

#define CREATE_SHL_SLOT(OUT, IN0, IN1)                                    \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? shl_i32 : shl_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_EXEC(translate_binary, LLVMBuildShl);                      \
    } while (0)

/* ============================================================ * SHL for vectors (shli_vec) * ============================================================ */
#define CREATE_SHL_VEC(OUT, IN0, IN1, SPLAT)                              \
    do {                                                                   \
        assert(is_vec);                                                    \
        BUILD_INSTR(3);                                                 \
        BI_OPCODE(shli_vec);                                           \
        BI_VS(OPC_VECTOR_SIZE(type_out));                             \
        BI_VES(OPC_VECTOR_TO_VES(type_out));                          \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        if (SPLAT) {                                                  \
            BI_IMM(2, (IN1.i));                                      \
            translate_binary_splat_immediate(__bi_u->opc, __bi_u, LLVMBuildShl);                                   \
        } else {                                                       \
            BI_SLOT_IN(2, IN1);                                      \
            translate_binary(__bi_u->opc, __bi_u, LLVMBuildShl);                                   \
        }                                                              \
    } while (0)

/* ============================================================ * OR * ============================================================ */
#define CREATE_OR(OUT, IN0, IN1)                                          \
    do {                                                                   \
        BUILD_INSTR(3);                                               \
        if (is_vec) {                                                      \
            BI_OPCODE(or_vec);                                         \
            BI_VS(OPC_VECTOR_SIZE(type_out));                         \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        } else {                                                           \
            assert(OPC_OUTPUT_T != LLVMInvalidType);                       \
            BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? or_i32 : or_i64);   \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        }                                                                  \
        BI_EXEC(translate_binary, LLVMBuildOr);                   \
    } while (0)

/* ============================================================ * DEPOSIT (deposit_i32 / deposit_i64) * ============================================================ */
#define CREATE_DEPOSIT(OUT, IN0, IN1, OFS, LEN)                          \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(5);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? deposit_i32 : deposit_i64); \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_IMM     (3, (OFS));                                       \
        BI_IMM     (4, (LEN));   /* 5th operand – see GET_5_OPERANDS */\
        BI_EXEC_DIRECT(translate_deposit);                              \
    } while (0)

/* ============================================================ * SAR (arithmetic shift right) * ============================================================ */
#define CREATE_SAR(OUT, IN0, IN1)                                         \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? sar_i32 : sar_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));                                       \
        BI_EXEC(translate_binary, LLVMBuildAShr);                      \
    } while (0)

/* ============================================================ * ADD * ============================================================ */
#define CREATE_ADD(OUT, IN0, IN1)                                         \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? add_i32 : add_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));   /* IN1 may be immediate or slot */  \
        BI_EXEC(translate_binary, LLVMBuildAdd);                      \
    } while (0)

#define CREATE_ADD64(OUT, IN0, IN1)                                       \
    do {                                                                   \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(add_i64);                                           \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_IMM     (2, (IN1));                                       \
        BI_EXEC(translate_binary, LLVMBuildAdd);                      \
    } while (0)

/* ============================================================ * SUB * ============================================================ */
#define CREATE_SUB(OUT, IN0, IN1)                                         \
    do {                                                                   \
        BUILD_INSTR(3);                                               \
        if (is_vec) {                                                      \
            BI_OPCODE(sub_vec);                                        \
            BI_VS(OPC_VECTOR_SIZE(type_out));                         \
            BI_VES(OPC_VECTOR_TO_VES(type_out));                      \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        } else {                                                           \
            assert(OPC_OUTPUT_T != LLVMInvalidType);                       \
            BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? sub_i32 : sub_i64); \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_SLOT_IN (1, IN0);                                     \
            BI_SLOT_IN (2, IN1);                                     \
        }                                                                  \
        BI_EXEC(translate_binary, LLVMBuildSub);                   \
    } while (0)

/* ============================================================ * SETCOND (setcond_i32 / setcond_i64) * ============================================================ */
#define CREATE_SETCOND(OUT, IN0, IN1, RELOP)                              \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(4);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? setcond_i32 : setcond_i64); \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_RELOP   (3, (RELOP));                                     \
        BI_EXEC_DIRECT(translate_setcond);                              \
    } while (0)

/* ============================================================ * MOV (mov_i32 / mov_i64) * ============================================================ */
#define CREATE_MOV(OUT, IN)                                                \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(2);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? mov_i32 : mov_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN);                                          \
        BI_EXEC_DIRECT(translate_mov);                                 \
    } while (0)

/* ============================================================ * MOV vector (mov_vec) * ============================================================ */
#define CREATE_MOV_VEC(VS, VES, OUT, IN)                                  \
    do {                                                                   \
        BUILD_INSTR(2);                                                   \
        BI_OPCODE(mov_vec);                                            \
        BI_VS(VS);                                                   \
        BI_VES(VES);                                                  \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN);                                          \
        BI_EXEC_DIRECT(translate_mov);                                 \
    } while (0)

/* ============================================================ * MOVCOND vector (movcond_vec) * ============================================================ */
#define CREATE_MOVCOND_VEC(VS, VES, OUT, IN0, IN1, CMP0, CMP1, ROP)      \
    do {                                                                   \
        BUILD_INSTR(6);                                                   \
        BI_OPCODE(movcond_vec);                                        \
        BI_VS(VS);                                                   \
        BI_VES(VES);                                                  \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_SLOT_IN (3, CMP0);                                        \
        BI_SLOT_IN (4, CMP1);                                        \
        BI_RELOP   (5, (ROP));                                       \
        BI_EXEC_DIRECT(translate_movcond);                             \
    } while (0)

/* ============================================================ * CMP vector (cmp_vec) * ============================================================ */
#define CREATE_CMP_VEC(OUT, IN0, IN1, ROP)                                \
    do {                                                                   \
        BUILD_INSTR(4);                                                   \
        BI_OPCODE(cmp_vec);                                            \
        BI_VS(OPC_VECTOR_SIZE(type_out));                             \
        BI_VES(OPC_VECTOR_TO_VES(type_out));                          \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_RELOP   (3, (ROP));                                       \
        BI_EXEC_DIRECT(translate_cmp_vec);                             \
    } while (0)

/* ============================================================ * BITSEL vector (bitsel_vec) * ============================================================ */
#define CREATE_BITSEL_VEC(OUT, IN0, IN1, IN2)                             \
    do {                                                                   \
        BUILD_INSTR(4);                                                   \
        BI_OPCODE(cmp_vec);    /* underlying op for bitsel */           \
        BI_VS(OPC_VECTOR_SIZE(type_out));                             \
        BI_VES(OPC_VECTOR_TO_VES(type_out));                          \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_SLOT_IN (3, IN2);                                         \
        BI_EXEC_DIRECT(translate_bitsel_vec);                           \
    } while (0)

/* ============================================================ * MUL (mul_i32 / mul_i64) * ============================================================ */
#define CREATE_MUL(OUT, IN0, IN1)                                         \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                   \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? mul_i32 : mul_i64);     \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        BI_EXEC(translate_binary, LLVMBuildMul);                      \
    } while (0)

/* ============================================================ * MULXH (mulsh_i32 / mulsh_i64) * ============================================================ */
#define CREATE_MULXH(OUT, IN0, IN1, EXT)                                  \
    do {                                                                   \
        assert(OPC_OUTPUT_T != LLVMInvalidType);                           \
        BUILD_INSTR(3);                                                 \
        BI_OPCODE(OPC_OUTPUT_T == LLVMInt32 ? mulsh_i32 : mulsh_i64); \
        BI_SLOT_OUT(0, OUT);                                         \
        BI_SLOT_IN (1, IN0);                                         \
        BI_SLOT_IN (2, IN1);                                         \
        translate_binary(__bi_u->opc, __bi_u, LLVMBuildMul);                                   \
        translate_mulxh(__bi_u->opc, __bi_u, EXT);                      \
    } while (0)

/* ============================================================ * SET_LABEL * ============================================================ */
#define CREATE_LABEL(LABEL)                                                \
    do {                                                                   \
        BUILD_INSTR(1);                                                   \
        BI_OPCODE(set_label);                                          \
        BI_LABEL(0, (LABEL));                                        \
        BI_EXEC_DIRECT(translate_set_label);                           \
    } while (0)

/* ============================================================ * LD_ENV_XMM * ============================================================ */
#define CREATE_LD_ENV_XMM(OPC, OUT, ALIAS)                                \
    do {                                                                   \
        BUILD_INSTR(2);                                               \
        if ((ALIAS).s.slot_type == SUB_SLOT_ENV) {                         \
            BI_OPCODE(OPC);                                           \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_ENV     (1, (ALIAS).s.offset);                         \
        } else {                                                           \
            BI_OPCODE(OPC);                                           \
            BI_SLOT_OUT(0, OUT);                                     \
            BI_XMM     (1, (ALIAS).s.slot_idx,                       \
                           get_xmm_offset((ALIAS).s.slot_idx/2)       \
                           + 16*((ALIAS).s.slot_idx%2)               \
                           + (ALIAS).s.offset);                       \
        }                                                                  \
        BI_EXEC_DIRECT(translate_ld_env_xmm);                     \
    } while (0)

/* ============================================================ * QEMU_LD (generic, with storage attributes) * ============================================================ */
#define CREATE_LD(L, ADDR)                                                 \
    do {                                                                   \
        BUILD_INSTR(3);                                                  \
        BI_OPCODE(qemu_ld_i64);                                      \
        BI_SLOT_OUT(0, L);                                           \
        BI_SLOT_IN (1, ADDR);                                        \
        BI_ATTR_STORAGE(2, NONATOMIC, ALIGN_MEM_SIZE, ZERO, SRC8B);  \
        BI_EXEC_DIRECT(translate_qemu_ld);                            \
    } while (0)

/* ============================================================ * QEMU_ST (generic, with storage attributes) * ============================================================ */
#define CREATE_ST(R, ADDR)                                                 \
    do {                                                                   \
        BUILD_INSTR(3);                                                  \
        BI_OPCODE(qemu_st_i64);                                      \
        BI_SLOT_OUT(0, R);                                           \
        BI_SLOT_IN (1, ADDR);                                        \
        BI_ATTR_STORAGE(2, NONATOMIC, ALIGN_MEM_SIZE, ZERO, SRC8B);  \
        BI_EXEC_DIRECT(translate_qemu_st);                            \
    } while (0)
