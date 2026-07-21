/*
 * Runtime covergroup for SystemVerilog functional coverage (minimal slice).
 */
# include  "vvp_covergroup.h"
# include  "vvp_cobject.h"
# include  <cassert>
# include  <cstdlib>
# include  <cstring>

using namespace std;

vvp_covergroup::vvp_covergroup(const vvp_object_t& parent,
			       const std::vector<bin_t>& bins)
: parent_(parent), bins_(bins)
{
      for (size_t i = 0 ; i < bins_.size() ; i += 1)
	    bins_[i].hit = false;
}

vvp_covergroup::~vvp_covergroup()
{
}

vvp_object* vvp_covergroup::duplicate() const
{
      return new vvp_covergroup(parent_, bins_);
}

void vvp_covergroup::sample()
{
      vvp_cobject*parent = parent_.peek<vvp_cobject>();
      if (!parent)
	    return;

      for (size_t i = 0 ; i < bins_.size() ; i += 1) {
	    if (bins_[i].hit)
		  continue;
	    vvp_vector4_t val;
	    parent->get_vec4(bins_[i].prop_idx, val);
	    if (val.has_xz())
		  continue;
	    long ival = 0;
	    unsigned bits = val.size() < 8*sizeof(long) ? val.size() : 8*sizeof(long);
	    for (unsigned b = 0 ; b < bits ; b += 1) {
		  if (val.value(b) == BIT4_1)
			ival |= (1L << b);
	    }
	    for (size_t vi = 0 ; vi < bins_[i].values.size() ; vi += 1) {
		  if (bins_[i].values[vi] == ival) {
			bins_[i].hit = true;
			break;
		  }
	    }
      }
}

double vvp_covergroup::get_inst_coverage() const
{
      if (bins_.empty())
	    return 0.0;
      size_t hits = 0;
      for (size_t i = 0 ; i < bins_.size() ; i += 1)
	    if (bins_[i].hit)
		  hits += 1;
      return (100.0 * (double)hits) / (double)bins_.size();
}

vvp_covergroup* vvp_covergroup::make(const vvp_object_t& parent, const char* desc)
{
      std::vector<bin_t> bins;
      if (!desc || !*desc)
	    return new vvp_covergroup(parent, bins);

      char*buf = strdup(desc);
      char*save = 0;
      char*tok = strtok_r(buf, ";", &save);
      if (!tok) {
	    free(buf);
	    return new vvp_covergroup(parent, bins);
      }
	/* First token is n_bins (informational); remaining are bins. */
      tok = strtok_r(0, ";", &save);
      while (tok) {
	    bin_t b;
	    b.hit = false;
	    char*p = tok;
	    b.prop_idx = (unsigned)strtoul(p, &p, 10);
	    if (*p != ':') { tok = strtok_r(0, ";", &save); continue; }
	    p += 1;
	    unsigned nvals = (unsigned)strtoul(p, &p, 10);
	    if (*p != ':') { tok = strtok_r(0, ";", &save); continue; }
	    p += 1;
	    for (unsigned i = 0 ; i < nvals ; i += 1) {
		  char*end = 0;
		  long v = strtol(p, &end, 10);
		  b.values.push_back(v);
		  p = end;
		  if (*p == ',')
			p += 1;
	    }
	    bins.push_back(b);
	    tok = strtok_r(0, ";", &save);
      }
      free(buf);
      return new vvp_covergroup(parent, bins);
}
