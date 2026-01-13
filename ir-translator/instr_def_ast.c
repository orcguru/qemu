#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "instr_def_ast.h"
#include "instr_def_parser.tab.h"
#include "instr_def_lexer.yy.h"
#include <stdbool.h>
#include "tcg_ast.h"

extern char *lineptr;

static uint32_t fields_next_capacity = 512;
static uint32_t fields_capacity = 0;
static uint32_t fields_idx = 0;
static uint32_t *fields_is_not_slot = NULL;
static const char **fields_type_list = NULL;
static const char **fields_name_list = NULL;
static uint32_t *instr_def_field_offset = NULL;
static uint32_t *instr_def_field_cnt = NULL;
static OpCodeType *instr_def_default_opc = NULL;
static OpCodeType instr_default_opc = -1;
static uint8_t *instr_def_with_helper = NULL;
static uint8_t instr_helper_info = 0;
static uint8_t *instr_def_with_ves = NULL;
static uint8_t instr_ves_info = 0;
static uint8_t *instr_def_with_relop = NULL;
static uint8_t instr_relop_info = 0;
static uint8_t *instr_def_with_noargs = NULL;
static uint8_t instr_noargs_info = 0;
static uint8_t *instr_def_with_label = NULL;
static uint8_t instr_label_info = 0;
static const char **instr_def = NULL;
static uint32_t instr_def_idx = 0;
static uint32_t last_fields_idx = 0;

static void get_more_space() {
    fields_is_not_slot = reallocarray(fields_is_not_slot, fields_next_capacity, sizeof(uint32_t));
    assert(fields_is_not_slot);
    fields_type_list = reallocarray(fields_type_list, fields_next_capacity, sizeof(const char *));
    assert(fields_type_list);
    fields_name_list = reallocarray(fields_name_list, fields_next_capacity, sizeof(const char *));
    assert(fields_name_list);
    instr_def_field_offset = reallocarray(instr_def_field_offset, fields_next_capacity, sizeof(uint32_t));
    assert(instr_def_field_offset);
    instr_def_field_cnt = reallocarray(instr_def_field_cnt, fields_next_capacity, sizeof(uint32_t));
    assert(instr_def_field_cnt);
    instr_def_default_opc = reallocarray(instr_def_default_opc, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_default_opc);
    instr_def_with_helper = reallocarray(instr_def_with_helper, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_with_helper);
    instr_def_with_ves = reallocarray(instr_def_with_ves, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_with_ves);
    instr_def_with_relop = reallocarray(instr_def_with_relop, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_with_relop);
    instr_def_with_noargs = reallocarray(instr_def_with_noargs, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_with_noargs);
    instr_def_with_label = reallocarray(instr_def_with_label, fields_next_capacity, sizeof(OpCodeType));
    assert(instr_def_with_label);
    instr_def = reallocarray(instr_def, fields_next_capacity, sizeof(const char *));
    assert(instr_def);
    fields_capacity = fields_next_capacity;
    fields_next_capacity *= 2;
}

void insert_field(const char *type, const char *name) {
    if ((fields_idx + 1) > fields_capacity) {
        get_more_space();
    }
    if (strstr(name, "slot") && strstr(name, "_idx")) {
        fields_is_not_slot[fields_idx] = 0;
        fields_idx += 1;
    } else if (strstr(name, "imm")) {
        fields_is_not_slot[fields_idx] = 1;
        fields_type_list[fields_idx] = type;
        fields_name_list[fields_idx] = name;
        fields_idx += 1;
    } else if (strstr(name, "xmm_idx")) {
        fields_is_not_slot[fields_idx] = 2;
        fields_idx += 1;
    } else if (strstr(name, "env_offset")) {
        fields_is_not_slot[fields_idx] = 3;
        fields_idx += 1;
    } else if (strstr(name, "helper")) {
        instr_default_opc = call;
        instr_helper_info = 1;
        if (strstr(name, "helper_h")) {
            instr_helper_info = 2;
        }
    } else if (strcmp(name, "es") == 0) {
        instr_ves_info = 1;
    } else if (strcmp(name, "relop") == 0) {
        instr_relop_info = 1;
    } else if (strcmp(name, "noargs") == 0) {
        instr_noargs_info = 1;
    } else if (strcmp(name, "label") == 0) {
        instr_label_info = 1;
    }
}

void handle_def(const char *instr) {
    assert((instr_def_idx + 1) < fields_capacity);
    instr_def[instr_def_idx] = instr;
    instr_def_field_offset[instr_def_idx] = last_fields_idx;
    instr_def_field_cnt[instr_def_idx] = (fields_idx - last_fields_idx);
    instr_def_default_opc[instr_def_idx] = instr_default_opc;
    instr_def_with_helper[instr_def_idx] = instr_helper_info;
    instr_def_with_ves[instr_def_idx] = instr_ves_info;
    instr_def_with_relop[instr_def_idx] = instr_relop_info;
    instr_def_with_noargs[instr_def_idx] = instr_noargs_info;
    instr_def_with_label[instr_def_idx] = instr_label_info;
    last_fields_idx = fields_idx;
    instr_def_idx += 1;
    instr_default_opc = -1;
    instr_helper_info = 0;
    instr_ves_info = 0;
    instr_relop_info = 0;
    instr_noargs_info = 0;
    instr_label_info = 0;
}

void gen_api() {
    printf("/* DO NOT EDIT: this is generated by instr_def_parser from instr_def.h */\n");
    printf("#include \"tcg_ast.h\"\n");
    printf("#include <assert.h>\n");
    printf("#include <stdio.h>\n");
    printf("#include <string.h>\n");
    printf("\n");
    /// get_operand
    printf("OperandType get_operand(void *ptr, uint32_t idx, uint32_t *is_imm) {\n");
    printf("    OperandType ret;\n");
    printf("    memset(&ret, 0, sizeof(ret));\n");
    printf("    ret.s.valid = 0;\n");
    printf("    *is_imm = 0;\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
    const char *instr = instr_def[j];
    printf("    case %s_ext:\n", instr);
    printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
    char *env = strstr(instr, "_ENV");
    int env_idx = -1;
    if (env) {
        env_idx = atoi(env+4);
    }
    uint32_t s_idx = 0;
    uint32_t env_added = 0;
    for (uint32_t i = instr_def_field_offset[j]; i < (instr_def_field_offset[j] + instr_def_field_cnt[j]); ++i) {
        if (i == instr_def_field_offset[j]) {
            printf("    if (idx == %d) {\n", (i - instr_def_field_offset[j] + env_added));
        } else {
            printf("    } else if (idx == %d) {\n", (i - instr_def_field_offset[j] + env_added));
        }
        if (instr_def_with_helper[j] != 0 && (i - instr_def_field_offset[j] + env_added) == env_idx) {
            printf("        ret.s.valid = 1;\n");
            printf("        ret.s.slot_type = SUB_SLOT_ENV;\n");
            printf("        ret.s.offset = 0;\n");
            env_added += 1;
            printf("    } else if (idx == %d) {\n", (i - instr_def_field_offset[j] + env_added));
        }
        if (fields_is_not_slot[i] == 1) {
            printf("        *is_imm = 1;\n");
            if (fields_type_list[i][0] == 'u') {
                printf("        ret.i = i_%s->%s;\n", instr, fields_name_list[i]);
            } else {
                printf("        ret.i = (uint64_t)((int64_t)i_%s->%s);\n", instr, fields_name_list[i]);
            }
        } else if (fields_is_not_slot[i] == 2) {
            printf("        ret.s.valid = 1;\n");
            printf("        ret.s.slot_type = SUB_SLOT_XMM;\n");
            printf("        ret.s.slot_idx = i_%s->xmm_idx;\n", instr);
            printf("        ret.s.offset = i_%s->xmm_offset;\n", instr);
        } else if (fields_is_not_slot[i] == 3) {
            printf("        ret.s.valid = 1;\n");
            printf("        ret.s.slot_type = SUB_SLOT_ENV;\n");
            printf("        ret.s.offset = i_%s->env_offset;\n", instr);
        } else {
            printf("        ret.s.valid = 1;\n");
            printf("        ret.s.slot_type = i_%s->slot%d_type;\n", instr, s_idx);
            printf("        ret.s.slot_idx = i_%s->slot%d_idx;\n", instr, s_idx);
            s_idx += 1;
        }
    }
    if (instr_def_with_helper[j] != 0 && instr_def_field_cnt[j] > 0 && ((instr_def_field_cnt[j] + env_added) == env_idx)) {
        printf("    } else if (idx == %d) {\n", env_idx);
        printf("        ret.s.valid = 1;\n");
        printf("        ret.s.slot_type = SUB_SLOT_ENV;\n");
        printf("        ret.s.offset = 0;\n");
    }
    if (instr_def_field_cnt[j] > 0) {
        printf("    }\n");
    } else {
        if (instr_def_with_helper[j] != 0 && env_idx == 0) {
            printf("    if (idx == 0) {\n");
            printf("        ret.s.valid = 1;\n");
            printf("        ret.s.slot_type = SUB_SLOT_ENV;\n");
            printf("        ret.s.offset = 0;\n");
            printf("    }\n");
        }
    }
    printf("    break;\n");
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return ret;\n");
    printf("}\n");
    /// move_to_next
    printf("\n");
    printf("void *move_to_next(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    if (iptr->instr_type == SIZE2B) {\n");
    printf("        ptr += 2;\n");
    printf("        return ptr;\n");
    printf("    }\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
    const char *instr = instr_def[j];
    printf("    case %s_ext:\n", instr);
    printf("    ptr += sizeof(%s);\n", instr);
    printf("    break;\n");
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return ptr;\n");
    printf("}\n");
    /// get_opcode
    printf("\n");
    printf("OpCodeType get_opcode(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_default_opc[j] != -1) {
            printf("    return %d;\n", instr_def_default_opc[j]);
        } else {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return i_%s->opc;\n", instr);
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
    /// get_helper
    printf("\n");
    printf("HelperType get_helper(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    assert(iptr->instr_type == SIZEXB);\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_with_helper[j] == 0) {
            printf("    assert(0);\n");
            printf("    return -1;\n");
        } else if (instr_def_with_helper[j] == 1) {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return i_%s->helper;\n", instr);
        } else if (instr_def_with_helper[j] == 2) {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return i_%s->helper_h << 8 | i_%s->helper_l;\n", instr, instr);
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
    /// get_vector_elem_size
    printf("\n");
    printf("LLVMType get_llvm_vector_type(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    assert(iptr->instr_type == SIZEXB);\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_with_ves[j] == 0) {
            printf("    assert(0);\n");
            printf("    return -1;\n");
        } else {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return (LLVMVector8xi8 + (i_%s->vs - VS64) * 4 + i_%s->es);\n", instr, instr);
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
    /// get_relop
    printf("\n");
    printf("RelopType get_relop(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    assert(iptr->instr_type == SIZEXB);\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_with_relop[j] == 0) {
            printf("    assert(0);\n");
            printf("    return -1;\n");
        } else {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return i_%s->relop;\n", instr);
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
    /// get_label
    printf("\n");
    printf("uint8_t get_label(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    assert(iptr->instr_type == SIZEXB);\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_with_label[j] == 0) {
            printf("    assert(0);\n");
            printf("    return -1;\n");
        } else {
            printf("    %s *i_%s = (%s *)ptr;\n", instr, instr, instr);
            printf("    return i_%s->label;\n", instr);
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
    /// get_attribute
    printf("\n");
    printf("AttributeType get_attribute(void *ptr) {\n");
    printf("    Instr4B *iptr = (Instr4B *)ptr;\n");
    printf("    assert(iptr->instr_type == SIZEXB);\n");
    printf("    if (iptr->instr_type_ext == Instr4B_ext) {\n");
    printf("        AttributeType ret;\n");
    printf("        ret.attr_type = iptr->attr_type;\n");
    printf("        ret.attr_val = iptr->attr_val;\n");
    printf("        return ret;\n");
    printf("    } else if (iptr->instr_type_ext == Instr1B41_ext) {\n");
    printf("        Instr1B41 *i_Instr1B41 = (Instr1B41 *)ptr;\n");
    printf("        AttributeType ret;\n");
    printf("        ret.attr_type = i_Instr1B41->attr_type;\n");
    printf("        ret.attr_val = i_Instr1B41->attr_val;\n");
    printf("        return ret;\n");
    printf("    }\n");
    printf("    assert(0);\n");
    printf("}\n");
    /// is_vector
    printf("\n");
    printf("uint8_t is_vector(void *ptr) {\n");
    printf("    Instr1B2 *iptr = (Instr1B2 *)ptr;\n");
    printf("    if (iptr->instr_type != SIZEXB) {\n");
    printf("        return 0;\n");
    printf("    }\n");
    printf("    switch (iptr->instr_type_ext) {\n");

    for (uint32_t j = 0; j < instr_def_idx; ++j) {
        const char *instr = instr_def[j];
        printf("    case %s_ext:\n", instr);
        if (instr_def_with_ves[j] == 0) {
            printf("    return 0;\n");
        } else {
            printf("    return 1;\n");
        }
    }

    printf("    default: assert(0);\n");
    printf("    }\n");
    printf("    return -1;\n");
    printf("}\n");
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }

    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);

    yyparse(scanner);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    return;
}

int main(int argc, const char *argv[]) {
  if (argc < 2) {
    printf("Usage: ./app <instr-def>\n");
    return -1;
  }
  parse_tcg_instructions(argv[1]);
  return 0;
}
