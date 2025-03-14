###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


ezMethodDeseq2 = function(input=NA, output=NA, param=NA){
  cwd <- getwd()
  setwdNew(basename(output$getColumn("Report")))
  on.exit(setwd(cwd))
  stopifnot(param$sampleGroup != param$refGroup)
  
  input = cleanupTwoGroupsInput(input, param)
  param$groupingName <- param$grouping
  param$grouping = input$getColumn(param$grouping)
  if (ezIsSpecified(param$grouping2) && length(param$grouping2) == 1){
    param$grouping2Name <- param$grouping2
    param$grouping2 = input$getColumn(param$grouping2)
  }
  
  rawData = loadCountDataset(input, param)
  if (isError(rawData)){
    writeErrorReport("00index.html", param=param, error=rawData$error)
    return("Error")
  }
  
  deResult = twoGroupCountComparison(rawData)
  if (isError(deResult)){
    writeErrorReport("00index.html", param=param, error=deResult$error)
    return("Error")
  }
  dds = metadata(deResult)$nativeResult$dds
  dataset <- data.frame(colData(deResult), check.names = FALSE)
  dataset <- dataset[rownames(dataset) %in% rownames(dds@colData), ]
  seqAnno <- data.frame(rowData(deResult),
                        row.names = rownames(deResult),
                        check.names = FALSE)
  
  makeRmdReport(output=output, param=param, deResult=deResult, rmdFile="twoGroups.Rmd", reportTitle = param$comparison)
  rmStatus <- file.remove(list.files(pattern="enrich-.*rds"))
  return("Success")
}

##' @template app-template
##' @templateVar method ezMethodDeseq2(input=NA, output=NA, param=NA, htmlFile="00index.html")
##' @description Use this reference class to run 
EzAppDeseq2 <-
  setRefClass("EzAppDeseq2",
              contains = "EzApp",
              methods = list(
                initialize = function()
                {
                  "Initializes the application using its specific defaults."
                  runMethod <<- ezMethodDeseq2
                  name <<- "EzAppDeseq2"
                  appDefaults <<- rbind(testMethod=ezFrame(Type="character",  DefaultValue="deseq2",  Description="which test method in DESeq to use: deseq2"),
                                        normMethod=ezFrame(Type="character", DefaultValue="DESeq2_MedianRatio", Description="Deseq2's default norm method; this is actually not read"),
                                        useRefGroupAsBaseline=ezFrame(Type="logical", DefaultValue=FALSE, Description="should the log-ratios be centered at the reference samples"),
                                        onlyCompGroupsHeatmap=ezFrame(Type="logical", DefaultValue=FALSE, Description="Only show the samples from comparison groups in heatmap")
                                        )
                }
              )
  )
