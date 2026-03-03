dirs <- c(
  "code/data_prep",
  "code/functions",
  "code/packages",
  "data/pop_data_by_adm2"
)

for (d in dirs) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

message("Folder structure created.")
