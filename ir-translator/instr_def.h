typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint64_t imm;
} Instr1B14;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
} Instr1B28;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
} Instr1B44;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
} Instr1B48;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
} Instr1B4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t xmm_idx        :7;
    uint16_t xmm_offset     :4;
} Instr1B4X;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t xmm_idx        :7;
    uint16_t xmm_offset     :4;
} Instr1BV4X;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t env_offset;
} Instr1BV4XE;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1B41I2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1B411;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t env_offset;
} Instr1B22;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
    uint16_t relop          :6;
    uint16_t label          :8;
} Instr1B21;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t relop          :6;
    uint16_t label          :8;
} Instr1B143;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t label          :8;
} Instr1B2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
} Instr1BH4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint64_t imm;
} Instr1BH42;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1BV4S2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
} Instr1BV4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
} Instr1BV42;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint16_t slot4_type     :2;
    uint16_t slot4_idx      :10;
    uint8_t relop           :6;
} Instr1BV8;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint16_t slot4_type     :2;
    uint16_t slot4_idx      :10;
} Instr1BH141;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
} Instr1BV21;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1BV212;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t attr_type      :4;
    /*
    struct {
        uint32_t atomic :1;
        uint32_t alignment :3;
        uint32_t sign_ext :1;
        uint32_t src_size :3;
    } storage_attr;
    */
    uint8_t attr_val;
} Instr1B41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
} Instr1BV4I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1B24;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t vs             :2;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint8_t relop           :6;
} Instr1BV41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
} Instr1BH2_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint64_t imm;
} Instr1BH24I_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
} Instr1B2S;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm;
} Instr1B41I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint8_t relop           :6;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
} Instr1B422;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint64_t imm;
    uint16_t xmm_idx        :7;
    uint16_t xmm_offset     :4;
} Instr1B142;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint64_t imm;
    uint16_t env_offset;
} Instr1B142E;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
} Instr1BH21_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
} Instr1BH21_ENV1;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm1;
    uint8_t relop           :6;
} Instr1B4111;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint16_t slot4_type     :2;
    uint16_t slot4_idx      :10;
    uint8_t relop           :6;
} Instr1B8;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm;
} Instr1BH4I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1BH4I1;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
    uint64_t imm2;
} Instr1BH4I11;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint64_t imm;
} Instr1BH4I_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint64_t imm;
} Instr1BH5I_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1BH5I2_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1BH4S2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
} Instr1BH4S3;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
} Instr1BH4S3_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint8_t helper_h        :3;
    uint8_t noargs          :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :10;
} Instr1BH4S4_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint8_t relop           :6;
    uint64_t imm;
} Instr1B42;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
} Instr1BH41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
} Instr1BH41_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
} Instr1BH42_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint64_t imm            :4;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
} Instr1BH21S_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1B281;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint8_t relop           :6;
} Instr1B4112;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
    uint64_t imm2;
    uint8_t relop           :6;
} Instr1B41122;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1BH412;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :10;
    uint8_t relop           :6;
} Instr1B41R;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint64_t imm0           :4;
    uint64_t imm1;
} Instr1BH24_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm;
} Instr1BH211_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm0;
    uint64_t imm1;
} Instr1BH212_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1BH4S_ENV0;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
} Instr1BH4S_ENV1;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :1;
    uint8_t instr_type_ext  :6;
    uint8_t opc;
    uint64_t imm0;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint64_t imm1;
} Instr1B1111;

typedef struct __attribute__((packed)) {
    uint32_t instr_type     :1;
    uint32_t instr_type_ext :6;
    uint8_t opc;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :10;
    uint16_t slot1_type     :2;
    uint16_t slot1_idx      :10;
    uint16_t attr_type      :4;
    /*
    union {
        struct {
            uint32_t atomic :1;
            uint32_t alignment :3;
            uint32_t sign_ext :1;
            uint32_t src_size :3;
        } storage_attr;
        uint32_t attr_val :8;
    } p;
    */
    uint8_t attr_val;
} Instr4B;
