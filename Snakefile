rule all:
    input:
        "data-plot/spag-sim-norand.pdf"

rule install_deps:
    input:
        "renv.lock"
    output:
        ".deps-installed"
    shell:
        """Rscript -e 'renv::restore();file.create(".deps-installed")'"""

rule sim_data:
    input:
        ".deps-installed",
        "data/sim.R"
    output:
        "data/sim-norand.csv"
    shell:
        "Rscript data/sim.R"

rule plot_data:
    input:
        ".deps-installed",
        "data/sim-norand.csv",
        "data-plot/spag.R"
    output:
        "data-plot/spag-sim-norand.pdf"
    shell:
        "Rscript data-plot/spag.R"
