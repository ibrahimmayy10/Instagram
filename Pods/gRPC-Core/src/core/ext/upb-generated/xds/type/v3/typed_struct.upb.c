/* This file was generated by upbc (the upb compiler) from the input
 * file:
 *
 *     xds/type/v3/typed_struct.proto
 *
 * Do not edit -- your changes will be discarded when the file is
 * regenerated. */

#include <stddef.h>
#include "upb/msg_internal.h"
#include "xds/type/v3/typed_struct.upb.h"
#include "validate/validate.upb.h"
#include "google/protobuf/struct.upb.h"

#include "upb/port_def.inc"

static const upb_MiniTable_Sub xds_type_v3_TypedStruct_submsgs[1] = {
  {.submsg = &google_protobuf_Struct_msginit},
};

static const upb_MiniTable_Field xds_type_v3_TypedStruct__fields[2] = {
  {1, UPB_SIZE(4, 8), UPB_SIZE(0, 0), kUpb_NoSub, 9, kUpb_FieldMode_Scalar | (kUpb_FieldRep_StringView << kUpb_FieldRep_Shift)},
  {2, UPB_SIZE(12, 24), UPB_SIZE(1, 1), 0, 11, kUpb_FieldMode_Scalar | (kUpb_FieldRep_Pointer << kUpb_FieldRep_Shift)},
};

const upb_MiniTable xds_type_v3_TypedStruct_msginit = {
  &xds_type_v3_TypedStruct_submsgs[0],
  &xds_type_v3_TypedStruct__fields[0],
  UPB_SIZE(16, 32), 2, kUpb_ExtMode_NonExtendable, 2, 255, 0,
};

static const upb_MiniTable *messages_layout[1] = {
  &xds_type_v3_TypedStruct_msginit,
};

const upb_MiniTable_File xds_type_v3_typed_struct_proto_upb_file_layout = {
  messages_layout,
  NULL,
  NULL,
  1,
  0,
  0,
};

#include "upb/port_undef.inc"

