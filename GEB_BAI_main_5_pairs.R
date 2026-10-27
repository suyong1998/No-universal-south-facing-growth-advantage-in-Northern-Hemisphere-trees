library(dplR)
setwd("path/to/GEB_code_archive")
project_dir <- normalizePath(".", winslash = "/", mustWork = TRUE)
site_csv <- file.path(
  project_dir,
  "outputs",
  "tables",
  "site_level_TGAI.csv"
)
rwl_dir <- file.path(project_dir, "data", "tree_ring_raw")
output_dir <- file.path(project_dir, "outputs", "bai")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

site_table <- read.csv(site_csv, stringsAsFactors = FALSE)
site_column <- intersect(c("site", "Site_ID", "Filename"), names(site_table))[1]

if (is.na(site_column)) {
  stop("The site table must contain a 'site', 'Site_ID', or 'Filename' column.")
}

sites <- site_table[[site_column]]
sites <- unique(toupper(trimws(sub("\\.rwl\\.csv$", "", sites, ignore.case = TRUE))))
sites <- sites[!is.na(sites) & nzchar(sites)]

message("Number of sites to process: ", length(sites))

for (site in sites) {
  message("Processing site: ", site)

  rwl_files <- list.files(
    rwl_dir,
    pattern = paste0("^", site, "[0-9]*\\.rwl$"),
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (length(rwl_files) == 0) {
    message("No matching RWL file found for site: ", site)
    next
  }

  for (rwl_file in rwl_files) {
    message("Reading file: ", basename(rwl_file))

    rwl <- tryCatch(
      read.rwl(rwl_file),
      error = function(e) {
        message("Failed to read ", basename(rwl_file), ": ", e$message)
        NULL
      }
    )

    if (is.null(rwl)) {
      next
    }

    bai <- bai.out(rwl = rwl)
    bai_crn <- chron(bai)
    years <- time(bai_crn)

    bai_all <- data.frame(
      Year = as.numeric(rownames(bai)),
      bai,
      check.names = FALSE
    )
    bai_mean <- data.frame(
      Year = years,
      Mean_BAI = bai_crn[, 1]
    )

    write.csv(
      bai_all,
      file.path(output_dir, paste0("BAI_", site, "_all_cores.csv")),
      row.names = FALSE
    )
    write.csv(
      bai_mean,
      file.path(output_dir, paste0("BAI_", site, "_mean.csv")),
      row.names = FALSE
    )

    png(
      file.path(output_dir, paste0("BAI_", site, ".png")),
      width = 1000,
      height = 600,
      res = 150
    )
    plot(
      years,
      bai_crn[, 1],
      type = "n",
      main = paste("Basal Area Increment (BAI) -", site),
      xlab = "Year",
      ylab = expression(BAI~(mm^2~yr^-1))
    )
    lines(years, bai_crn[, 1], col = "grey40", lty = "dashed")
    lines(years, caps(bai_crn[, 1], nyrs = 32), col = "red", lwd = 2)
    dev.off()

    message("Finished site: ", site)
  }
}

message("BAI calculation completed.")
