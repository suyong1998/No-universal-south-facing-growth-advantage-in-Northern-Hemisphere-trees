# Reproducible code for the TGAI manuscript

This archive contains the analysis code associated with the manuscript **“No Universal South-Facing Growth Advantage in Northern Hemisphere Trees.”** It reproduces the main TGAI analyses, the basal area increment (BAI) analyses, and the sensitivity analysis requiring at least five valid south-facing stem side (SFS)–north-facing stem side (NFS) core pairs per site.

## 1. Code files

- `GEB_TGAI_reproducible_code.ipynb`: main analysis requiring at least four valid SFS–NFS core pairs per site. It calculates directional TGAI and absolute TGAI (`|TGAI|`), evaluates their spatial, climatic, taxonomic, and temporal patterns, classifies mountain and non-mountain sites, and generates the associated figures and intermediate tables.
- `GEB_BAI_main_4_pairs.R`: calculates annual BAI from the original `.rwl` files for the sites retained in the main analysis.
- `GEB_TGAI_minimum_5_pairs_sensitivity.ipynb`: repeats the TGAI analyses after retaining only sites with at least five valid SFS–NFS core pairs. It generates the sensitivity results reported in Figures S8–S10 and the inputs required for Table S4.
- `GEB_BAI_minimum_5_pairs.R`: calculates annual BAI for the sites retained in the minimum-five-pair sensitivity analysis.
- `GEB_BAI_TGAI_mixed_models.ipynb`: fits the main, detrended, and minimum-five-pair mixed-effects models relating annual BAI to `|TGAI|`. It produces Figures 3c–d, S7, and S10c–d and Tables S2–S4.
- `requirements.txt`: lists the Python dependencies.

## 2. Software requirements

The Python analyses were prepared for Python 3 and Jupyter Notebook. Install the required packages from the project root with:

```bash
python -m pip install -r requirements.txt
```

The R scripts require R and the `dplR` package:

```r
install.packages("dplR")
```

The notebooks use the Natural Earth world map distributed with GeoPandas through `gpd.datasets.get_path("naturalearth_lowres")`. The supplied `requirements.txt` therefore specifies `geopandas<1.0`; no separate boundary shapefile is required.

## 3. Project directory structure

Run all notebooks and R scripts from the archive root, i.e., the directory containing this README. Arrange the input data as follows:

```text
GEB_code_archive/
├── README_GEB_code.md
├── requirements.txt
├── GEB_TGAI_reproducible_code.ipynb
├── GEB_BAI_main_4_pairs.R
├── GEB_TGAI_minimum_5_pairs_sensitivity.ipynb
├── GEB_BAI_minimum_5_pairs.R
├── GEB_BAI_TGAI_mixed_models.ipynb
├── data/
│   ├── tree_ring_width/
│   │   ├── SITE.rwl.csv
│   │   └── SITE.rwl.stats.csv
│   ├── tree_ring_raw/
│   │   └── SITE.rwl
│   ├── site_metadata/
│   │   ├── ITRDB.shp
│   │   ├── ITRDB.dbf
│   │   ├── ITRDB.shx
│   │   └── ITRDB.prj
│   ├── climate/
│   │   ├── cru_ts4.07.1901.2022.pre.dat.nc
│   │   └── cru_ts4.07.1901.2022.tmp.dat.nc
│   └── mountains/
│       └── GMBA_2021_MntnMask_EarthEnv_30s1Bit.tif
└── outputs/                         # Created automatically
```

`SITE` denotes the site identifier. The identifiers used in filenames must agree with those in the site metadata and analysis tables.

The two tree-ring directories serve different purposes:

- `data/tree_ring_width/` contains the processed paired-width CSV files used to calculate TGAI and the corresponding `.rwl.stats.csv` files.
- `data/tree_ring_raw/` contains the original Tucson-format `.rwl` files used by `dplR` to calculate BAI.

## 4. Input data

### 4.1 Tree-ring width data

Each `SITE.rwl.csv` file must contain years in the first column and paired core-width columns identified by a common tree prefix and the terminal letters `N` and `S`. For example, `TREE01N` and `TREE01S` form one NFS–SFS pair. Width values must be numeric and positive for a year to be included.

The corresponding `SITE.rwl.stats.csv` files supply site-level metadata used by the notebooks. The original Tucson-format files in `data/tree_ring_raw/` are used independently for BAI calculation.

### 4.2 Site metadata

Place the ITRDB site shapefile and all required sidecar files in `data/site_metadata/`. The code expects the main file to be named `ITRDB.shp` and uses the site identifier, coordinates, species information, and aridity-index attribute contained in this dataset.

### 4.3 Climate data

The code expects monthly CRU TS v4.07 precipitation and temperature NetCDF files for 1901–2022, with the exact filenames shown above. These data are used to derive growing-season precipitation (GSP) and growing-season temperature (GST).

### 4.4 Mountain classification

The Global Mountains K3 raster is used to classify sampling sites as mountain or non-mountain. Save the raster as `data/mountains/Global_Mountains_K3.tif`.

## 5. Running the analyses

The scripts use relative paths based on the current working directory. Before running them, set the working directory to the archive root, not to `outputs/` or one of its subdirectories.

In RStudio, for example:

```r
setwd("path/to/GEB_code_archive")
getwd()
```

Run the files in the following order.

### Step 1: Main TGAI analysis

Run all cells in `GEB_TGAI_reproducible_code.ipynb`. Key tabular outputs include:

```text
outputs/tables/site_level_TGAI.csv
outputs/tables/annual_TGAI.csv
outputs/tables/site_tree_counts.csv
```

`annual_TGAI.csv` is the annual pair-level TGAI table used by the mixed-effects notebook. If the same table is additionally exported as `TGAI-ln.csv`, this is an optional duplicate for archiving; the supplied mixed-effects notebook reads `annual_TGAI.csv`.

### Step 2: Main BAI calculation

After Step 1 has generated `site_level_TGAI.csv`, run in R:

```r
source("GEB_BAI_main_4_pairs.R")
```

The script reads the original `.rwl` files from `data/tree_ring_raw/` and writes the BAI series to `outputs/bai/`.

### Step 3: Minimum-five-pair TGAI sensitivity analysis

Run all cells in `GEB_TGAI_minimum_5_pairs_sensitivity.ipynb`. Key outputs include:

```text
outputs/minimum_5_pairs/tables/site_level_TGAI_minimum_5_pairs.csv
outputs/minimum_5_pairs/tables/annual_TGAI_minimum_5_pairs.csv
```

### Step 4: Minimum-five-pair BAI calculation

After Step 3, run in R:

```r
source("GEB_BAI_minimum_5_pairs.R")
```

The resulting BAI files are written to `outputs/minimum_5_pairs/bai/`.

### Step 5: BAI–|TGAI| mixed-effects models

After Steps 1–4 are complete, run all cells in `GEB_BAI_TGAI_mixed_models.ipynb`. This notebook fits:

1. the main mixed-effects model;
2. the detrended mixed-effects model; and
3. the minimum-five-pair sensitivity model.

## 6. Output structure

The scripts create the output directories automatically:

```text
outputs/
├── figures/
│   ├── Figure_1*.jpg
│   ├── Figure_2*.jpg
│   ├── Figure_3*.jpg or .png
│   └── Figure_S*.jpg or .png
├── tables/
│   ├── site_level_TGAI.csv
│   ├── annual_TGAI.csv
│   ├── site_tree_counts.csv
│   ├── Table_S2_mixed_model_coefficients.csv
│   └── Table_S3_detrended_mixed_model_coefficients.csv
├── bai/
│   ├── BAI_SITE_all_cores.csv
│   ├── BAI_SITE_mean.csv
│   └── BAI_SITE.png
└── minimum_5_pairs/
    ├── figures/
    │   └── Figure_S8-S10 outputs
    ├── tables/
    │   ├── site_level_TGAI_minimum_5_pairs.csv
    │   ├── annual_TGAI_minimum_5_pairs.csv
    │   └── Table_S4_mixed_model_coefficients.csv
    └── bai/
        ├── BAI_SITE_all_cores.csv
        ├── BAI_SITE_mean.csv
        └── BAI_SITE.png
```

## 7. Analysis definitions

Directional tree growth asymmetry is calculated annually for each valid SFS–NFS core pair as:

```text
TGAI = ln(RW_S / RW_N)
```

where `RW_S` and `RW_N` are the annual ring widths of the south- and north-facing stem-side cores, respectively. Positive TGAI indicates greater SFS growth, negative TGAI indicates greater NFS growth, and `|TGAI|` represents asymmetry magnitude irrespective of direction.

The main analysis retains sites with at least four valid core pairs. The sensitivity analysis applies a stricter threshold of at least five valid core pairs per site. The annual TGAI records used for temporal and BAI analyses are restricted to the 1st–99th percentile range of directional TGAI, following the analysis code.

## 8. Public data sources

- International Tree-Ring Data Bank: <https://www.ncei.noaa.gov/products/paleoclimatology/tree-ring>
- CRU TS v4.07: <https://crudata.uea.ac.uk/cru/data/hrg/>
- Global Aridity Index and Potential Evapotranspiration Database v3: <https://figshare.com/articles/dataset/Global_Aridity_Index_and_Potential_Evapotranspiration_ET0_Climate_Database_v3/7504448>
- Global Mountains K3: <https://www.sciencebase.gov/catalog/item/638fbf72d34ed907bf7d3080>

Large third-party datasets are not redistributed in this archive and should be obtained from their original repositories subject to their respective terms of use.

## 9. Notes on reproducibility

- Do not replace the relative paths in the supplied code with computer-specific absolute paths.
- Run the scripts from the archive root so that `data/` and `outputs/` resolve correctly.
- Keep site identifiers consistent across the processed CSV files, raw `.rwl` files, site metadata, and generated tables.
- The code creates output folders when needed; users do not need to create them manually.
- Previously generated files may be overwritten when a notebook or script is rerun.
