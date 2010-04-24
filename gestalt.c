#include "glknew.h"

glui32 glk_gestalt(glui32 sel, glui32 val) {
  return glk_gestalt_ext(sel, val, NULL, 0);
}

glui32 glk_gestalt_ext(glui32 sel, glui32 val, glui32 *arr,
                       glui32 arrlen) {
  switch (sel) {
  case gestalt_Version:
    return 0x00000700;
  case gestalt_Unicode:
    return 1;
  default:
    printf("Unhandled gestalt sel=%u, val=%u, arr=%p, arrlen=%u\n", sel, val, arr, arrlen);
    return 0;
  }
}