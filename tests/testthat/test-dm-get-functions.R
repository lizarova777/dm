active_srcs <- tibble(src = names(dbplyr:::test_srcs$get()))
lookup <- tibble(
  src = c("df", "sqlite", "postgres", "mssql"),
  class_src = c("src_local", "src_SQLiteConnection", "src_PqConnection", "src_Microsoft SQL Server"),
  class_con = c(NA_character_, "SQLiteConnection", "PqConnection", "Microsoft SQL Server")
)

test_that("dm_get_src() works", {
  expect_dm_error(
    dm_get_src(1),
    class = "is_not_dm"
  )

  active_srcs_class <- semi_join(lookup, active_srcs, by = "src") %>% pull(class_src)

  walk2(
    dm_for_filter_src,
    active_srcs_class,
    ~ expect_true(inherits(dm_get_src(.x), .y))
  )
})

test_that("dm_get_con() works", {
  expect_dm_error(
    dm_get_con(1),
    class = "is_not_dm"
  )

  expect_dm_error(
    dm_get_con(dm_for_filter),
    class = "con_only_for_dbi"
  )

  active_con_class <- semi_join(lookup, filter(active_srcs, src != "df"), by = "src") %>% pull(class_con)
  dm_for_filter_src_red <- dm_for_filter_src[!(names(dm_for_filter_src) == "df")]

  walk2(
    dm_for_filter_src_red,
    active_con_class,
    ~ expect_true(inherits(dm_get_con(.x), .y))
  )
})

test_that("dm_get_filters() works", {
  expect_identical(
    dm_get_filters(dm_for_filter),
    tibble(table = character(), filter = list(), zoomed = logical())
  )

  expect_identical(
    dm_get_filters(dm_filter(dm_for_filter, t1, a > 3, a < 8)),
    tibble(table = "t1", filter = unname(exprs(a > 3, a < 8)), zoomed = FALSE)
  )
})
