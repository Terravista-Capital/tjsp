#' Extrai a movimentação processual de primeira e de segunda instância
#'
#' @param arquivos se não informados, informar diretório
#' @param diretorio objeto ou diretorio  onde se encontram os htmls
#'
#' @return tibble com a movimentação processual.
#' @export
#' @examples
#' \dontrun{
#' andamento_cposg <- ler_movimentacao_cposg()
#' andamento_cpopg <- ler_movimentacao_cpopg()
#' }
#'

tjsp_ler_movimentacao <- function(arquivos = NULL,diretorio = ".") {

   if (is.null(arquivos)){
   arquivos <- list.files(
    path = diretorio, pattern = ".html",
    full.names = TRUE
  )
}


  purrr::map_dfr(arquivos, purrr::possibly(~{



    resposta <- xml2::read_html(.x)


    processo <- resposta |>
      xml2::xml_find_first("//span[contains(@class,'unj-larger')]") |>
      xml2::xml_text() |>
      stringr::str_squish() |>
      stringr::str_remove_all("[^\\d+\\s]") |>
      stringr::str_trim()

   cd_processo <- resposta |>
      xml2::xml_find_first("//script[contains(text(),'processo.codigo')]") |> 
      xml2::xml_text() |>
      stringr::str_extract("(?<=processo.codigo=)\\w+")

    texto <- resposta |>
      xml2::xml_find_first(xpath = "//table/tbody[@id='tabelaTodasMovimentacoes']")

    data <- xml2::xml_find_all(texto, ".//td[@width='120']") |>
      xml2::xml_text(trim = TRUE) |>
      lubridate::dmy()

    mov <- xml2::xml_find_all(texto, ".//td[@style='vertical-align: top; padding-bottom: 5px']") |>
      xml2::xml_text(trim = TRUE)

    tibble::tibble(processo = processo, cd_processo = cd_processo, data = data, movimentacao = mov)
  }, otherwise = NULL), .progress  = TRUE)
}
