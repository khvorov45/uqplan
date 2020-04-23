rule all:
    input:
        "data-plot/spag-sim-norand.pdf",
        "data-plot/spag-sim-rand.pdf",
        "model-fit-plot/preds-plot-sim-norand.pdf"

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
        "data/sim-norand.csv",
        "data/sim-rand.csv"
    shell:
        "Rscript data/sim.R"

rule plot_data:
    input:
        ".deps-installed",
        "data/sim-norand.csv",
        "data-plot/spag.R"
    output:
        "data-plot/spag-sim-norand.pdf",
        "data-plot/spag-sim-rand.pdf"
    shell:
        "Rscript data-plot/spag.R"

rule model_fit:
    input:
        ".deps-installed",
        "data/sim-norand.csv",
        "model-fit/model-fit.R"
    output:
        "model-fit/preds-sim-norand.csv"
    shell:
        "Rscript model-fit/model-fit.R"

rule model_fit_plot:
    input:
        ".deps-installed",
        "model-fit-plot/model-fit-plot.R",
        "model-fit/preds-sim-norand.csv"
    output:
        "model-fit-plot/preds-plot-sim-norand.pdf"
    shell:
        "Rscript model-fit-plot/model-fit-plot.R"
