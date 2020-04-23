rule all:
    input:
        "data-plot/spag-sim-expected.pdf"

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
        "data/sim-expected.csv"
    shell:
        "Rscript data/sim.R"

rule plot_data:
    input:
        ".deps-installed",
        "data/sim-expected.csv",
        "data-plot/spag.R"
    output:
        "data-plot/spag-sim-expected.pdf"
    shell:
        "Rscript data-plot/spag.R"
