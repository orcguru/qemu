typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t opc             :7;
    int32_t imm;
} Instr1B14;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint64_t imm;
} Instr1B28;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    int32_t imm;
} Instr1B44;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint64_t imm;
} Instr1B48;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
} Instr1B4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t xmm_idx        :6;
    uint32_t xmm_offset     :4;
} Instr1B4X;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t xmm_idx        :6;
    uint32_t xmm_offset     :4;
} Instr1BV4X;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t env_offset     :16;
} Instr1BV4XE;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t imm0           :8;
    uint8_t imm1;
} Instr1B41I2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint8_t imm0;
    uint8_t imm1;
} Instr1B411;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint16_t env_offset;
} Instr1B22;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint64_t imm;
    uint8_t relop           :6;
    uint8_t label           :2;
} Instr1B21;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t label          :2;
} Instr1B2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint32_t helper_h       :3;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint32_t slot3_type     :2;
    uint32_t slot3_idx      :5;
} Instr1BH4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
} Instr1BV4S2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
} Instr1BV4;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint64_t opc            :7;
    uint64_t es             :2;
    uint64_t slot0_type     :2;
    uint64_t slot0_idx      :5;
    uint64_t slot1_type     :2;
    uint64_t slot1_idx      :5;
    uint64_t slot2_type     :2;
    uint64_t slot2_idx      :5;
    uint64_t slot3_type     :2;
    uint64_t slot3_idx      :2;
    uint64_t slot4_type     :2;
    uint64_t slot4_idx      :2;
    uint64_t relop          :6;
} Instr1BV8;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint32_t helper_h       :3;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint32_t slot3_type     :2;
    uint32_t slot3_idx      :5;
    uint8_t slot4_type      :2;
    uint8_t slot4_idx       :5;
} Instr1BH141;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t es             :2;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint8_t imm;
} Instr1BV21;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint32_t attr_type      :2;
    /*
    struct {
        uint32_t atomic :1;
        uint32_t alignment :2;
        uint32_t sign_ext :1;
        uint32_t src_size :3;
    } storage_attr;
    */
    uint8_t attr_val        :7;
} Instr1B41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t imm            :8;
} Instr1BV4I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t opc             :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint16_t imm0           :8;
    int32_t imm1;
} Instr1B24;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint8_t relop           :6;
} Instr1BV41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
} Instr1BH2;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint32_t imm;
} Instr1BH24I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
} Instr1B2S;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint8_t imm;
} Instr1B41I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t es             :2;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint64_t imm;
} Instr1BV48;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t relop          :6;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint16_t imm;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :5;
    uint16_t slot3_type     :2;
    uint16_t slot3_idx      :5;
} Instr1B422;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t opc             :7;
    uint32_t imm;
    uint16_t xmm_idx        :6;
    uint16_t xmm_offset     :4;
} Instr1B142;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t opc             :7;
    uint32_t imm;
    uint16_t env_offset;
} Instr1B142E;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint8_t slot0_type      :2;
    uint8_t slot0_idx       :5;
} Instr1BH21;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint8_t imm0;
    uint8_t slot2_type      :2;
    uint8_t slot2_idx       :5;
    uint8_t imm1;
    uint8_t relop           :6;
} Instr1B4111;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint64_t opc            :7;
    uint64_t slot0_type     :2;
    uint64_t slot0_idx      :5;
    uint64_t slot1_type     :2;
    uint64_t slot1_idx      :5;
    uint64_t slot2_type     :2;
    uint64_t slot2_idx      :5;
    uint64_t slot3_type     :2;
    uint64_t slot3_idx      :5;
    uint64_t slot4_type     :2;
    uint64_t slot4_idx      :5;
    uint64_t relop          :6;
} Instr1B8;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint32_t helper_h       :3;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint32_t imm            :8;
} Instr1BH4I;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t helper_l;
    uint32_t helper_h       :3;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
} Instr1BH4S3;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t relop          :6;
    uint16_t imm;
} Instr1B42;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t helper         :11;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint8_t imm;
} Instr1BH41;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t imm            :4;
    uint8_t slot0_type      :2;
    uint8_t slot0_idx       :5;
} Instr1BH21S;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t opc            :7;
    uint16_t slot0_type     :2;
    uint16_t slot0_idx      :5;
    uint64_t imm;
    uint8_t slot1_type      :2;
    uint8_t slot1_idx       :5;
} Instr1B281;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint8_t imm0;
    uint8_t imm1;
    uint16_t slot2_type     :2;
    uint16_t slot2_idx      :5;
    uint16_t relop          :6;
} Instr1B4112;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t helper         :11;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint8_t imm0;
    uint16_t imm1;
} Instr1BH412;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t opc            :7;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
    uint32_t slot2_type     :2;
    uint32_t slot2_idx      :5;
    uint8_t relop           :6;
} Instr1B41R;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint16_t imm0           :4;
    uint32_t imm1;
} Instr1BH24;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint16_t helper         :11;
    uint16_t noargs         :1;
    uint8_t slot0_type      :2;
    uint8_t slot0_idx       :5;
    uint8_t imm;
} Instr1BH211;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint32_t helper         :11;
    uint32_t noargs         :1;
    uint32_t slot0_type     :2;
    uint32_t slot0_idx      :5;
    uint32_t slot1_type     :2;
    uint32_t slot1_idx      :5;
} Instr1BH4S;

typedef struct __attribute__((packed)) {
    uint8_t instr_type      :2;
    uint8_t instr_type_ext  :6;
    uint8_t opc             :7;
    uint8_t imm0;
    uint8_t slot0_type      :2;
    uint8_t slot0_idx       :5;
    uint8_t imm1;
} Instr1B1111;
