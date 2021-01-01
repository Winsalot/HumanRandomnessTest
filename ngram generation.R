pak <- c(
    "tidyverse",
    "data.table"
)

for(package in pak){
    if(!(package %in% installed.packages())){
        install.packages(package)
    }
    library(package,character.only = TRUE)
}

values <- c(0,1)

ngram5 <- expand.grid(values, values, values, values, values) %>% 
    as_tibble %>% mutate_all(as.numeric)

ngram5[1:4] %>% unique -> ngram4
ngram5[1:3] %>% unique -> ngram3
ngram5[1:2] %>% unique -> ngram2

make_gdscript <- function(x){
    var_def <- paste0("onready var ngram_", ncol(x), " = ")
    x %>% apply(X = .,
                MARGIN = 1,
                function(x){
                    # print(x)
                    x0 <- paste(x, collapse = ", ")
                    x0 <- paste0("[", x0, "]", collapse = "")
                }) %>% paste(collapse = ", ") %>% 
        paste0(var_def, "[", ., "]\n\n", collapse="") %>% cat
}

make_gdscript_dict <- function(x){
    var_def <- paste0("onready var ngram_", ncol(x), " = ")
    x %>% apply(X = .,
                MARGIN = 1,
                function(x){
                    # print(x)
                    x0 <- paste(x, collapse = ", ")
                    x0 <- paste0("[", x0, "]", collapse = "")
                }) %>% paste(collapse = ": 0, ") %>% 
        paste0(var_def, "{", ., ":0}\n\n", collapse="") %>% cat
}

# Run this code block and paste it into GDscript
{
    ngram2 %>% make_gdscript()
    ngram3 %>% make_gdscript()
    ngram4 %>% make_gdscript()
    ngram5 %>% make_gdscript()
}

# Run this code block and paste it into GDscript
{
    ngram2 %>% make_gdscript_dict()
    ngram3 %>% make_gdscript_dict()
    ngram4 %>% make_gdscript_dict()
    ngram5 %>% make_gdscript_dict()
}
