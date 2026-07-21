#ifndef IVL_vvp_dpi_H
#define IVL_vvp_dpi_H
/*
 * Minimal DPI-C shared-library loader for import "DPI-C" function calls.
 */

# include  <cstdint>

/*
 * Load a DPI shared object with RTLD_GLOBAL so its symbols are visible
 * to dlsym(RTLD_DEFAULT, ...). Path may be absolute or relative.
 */
extern void vpip_load_dpi_library(const char*path);

/*
 * Resolve and call an imported C function that takes nargs int32 args
 * and returns int32. Returns the C return value, or 0 on failure.
 */
extern int32_t vpip_dpi_call_i32(const char*cname, unsigned nargs,
				 const int32_t*args);

#endif /* IVL_vvp_dpi_H */
