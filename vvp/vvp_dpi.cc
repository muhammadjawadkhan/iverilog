/*
 * Minimal DPI-C runtime: load .so with RTLD_GLOBAL and call int32 functions.
 */
# include  "config.h"
# include  "vvp_dpi.h"
# include  "ivl_dlfcn.h"
# include  <cstdio>
# include  <cstdlib>
# include  <cstring>
# include  <vector>

using namespace std;

static vector<ivl_dll_t> dpi_dlls;

void vpip_load_dpi_library(const char*path)
{
      if (!path || !*path)
	    return;

      ivl_dll_t dll = ivl_dlopen(path, true /* RTLD_GLOBAL */);
      if (!dll) {
	    fprintf(stderr, "DPI: failed to load `%s': %s\n",
		    path, dlerror());
	    return;
      }
      dpi_dlls.push_back(dll);
}

static void* dpi_lookup(const char*cname)
{
      if (!cname || !*cname)
	    return 0;

	/* Search libraries loaded via vvp -d first. */
      for (size_t i = 0 ; i < dpi_dlls.size() ; i += 1) {
	    void*sym = ivl_dlsym(dpi_dlls[i], cname);
	    if (sym)
		  return sym;
      }

#if defined(HAVE_DLFCN_H)
	/* Also search the process (covers LD_PRELOAD). */
      static void*self_dll = 0;
      if (!self_dll)
	    self_dll = dlopen(NULL, RTLD_NOW);
      if (self_dll) {
	    void*sym = dlsym(self_dll, cname);
	    if (sym)
		  return sym;
      }
#endif

      return 0;
}

typedef int32_t (*dpi_fn0_t)(void);
typedef int32_t (*dpi_fn1_t)(int32_t);
typedef int32_t (*dpi_fn2_t)(int32_t, int32_t);
typedef int32_t (*dpi_fn3_t)(int32_t, int32_t, int32_t);
typedef int32_t (*dpi_fn4_t)(int32_t, int32_t, int32_t, int32_t);
typedef int32_t (*dpi_fn5_t)(int32_t, int32_t, int32_t, int32_t, int32_t);
typedef int32_t (*dpi_fn6_t)(int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
typedef int32_t (*dpi_fn7_t)(int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
typedef int32_t (*dpi_fn8_t)(int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);

int32_t vpip_dpi_call_i32(const char*cname, unsigned nargs, const int32_t*args)
{
      void*sym = dpi_lookup(cname);
      if (!sym) {
	    fprintf(stderr, "DPI: unresolved import \"%s\" "
		    "(load the .so with vvp -d path.so or LD_PRELOAD).\n",
		    cname ? cname : "");
	    return 0;
      }

      switch (nargs) {
	  case 0:
	    return reinterpret_cast<dpi_fn0_t>(sym)();
	  case 1:
	    return reinterpret_cast<dpi_fn1_t>(sym)(args[0]);
	  case 2:
	    return reinterpret_cast<dpi_fn2_t>(sym)(args[0], args[1]);
	  case 3:
	    return reinterpret_cast<dpi_fn3_t>(sym)(args[0], args[1], args[2]);
	  case 4:
	    return reinterpret_cast<dpi_fn4_t>(sym)(args[0], args[1], args[2], args[3]);
	  case 5:
	    return reinterpret_cast<dpi_fn5_t>(sym)(args[0], args[1], args[2], args[3], args[4]);
	  case 6:
	    return reinterpret_cast<dpi_fn6_t>(sym)(args[0], args[1], args[2], args[3], args[4], args[5]);
	  case 7:
	    return reinterpret_cast<dpi_fn7_t>(sym)(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
	  case 8:
	    return reinterpret_cast<dpi_fn8_t>(sym)(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
	  default:
	    fprintf(stderr, "DPI: import \"%s\" has %u args; "
		    "this slice supports at most 8 scalar ints.\n",
		    cname, nargs);
	    return 0;
      }
}
