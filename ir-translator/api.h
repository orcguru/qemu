#ifndef __API
#define __API

OperandType get_operand(void *ptr, uint32_t idx, uint32_t *is_imm);
void *move_to_next(void *ptr);
OpCodeType get_opcode(void *ptr);
HelperType get_helper(void *ptr);
VectorElemSizeType get_vector_elem_size(void *ptr);
RelopType get_relop(void *ptr);
uint8_t get_helper_noargs(void *ptr);
uint8_t get_label(void *ptr);
AttributeType get_attribute(void *ptr);

#endif
