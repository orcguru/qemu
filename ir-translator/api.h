#ifndef __API
#define __API

OperandType get_operand(void *ptr, uint32_t idx, uint32_t *is_imm);
void *move_to_next(void *ptr);

#endif
