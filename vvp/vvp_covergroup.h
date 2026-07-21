#ifndef VVP_COVERGROUP_H
#define VVP_COVERGROUP_H
/*
 * Runtime object for SystemVerilog covergroup (Tier A #8 minimal slice).
 */
# include  "vvp_object.h"
# include  "vvp_net.h"
# include  <vector>
# include  <string>

class vvp_covergroup : public vvp_object {
    public:
      struct bin_t {
	    unsigned prop_idx;
	    std::vector<long> values;
	    bool hit;
      };

      vvp_covergroup(const vvp_object_t& parent, const std::vector<bin_t>& bins);
      ~vvp_covergroup() override;

      vvp_object* duplicate() const override;
      void shallow_copy(const vvp_object*) override {}

	/* Read parent properties and mark matching bins. */
      void sample();
	/* Percentage of bins hit (0..100). */
      double get_inst_coverage() const;

	/* Parse descriptor "nbins;prop:n:v0,v1;..." and build object. */
      static vvp_covergroup* make(const vvp_object_t& parent, const char* desc);

    private:
      vvp_object_t parent_;
      std::vector<bin_t> bins_;
};

#endif /* VVP_COVERGROUP_H */
