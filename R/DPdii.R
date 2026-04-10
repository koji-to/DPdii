#' Data Patcher using deletion-imputation iteration.
#'
#' @param data.df target dataset
#' @param imp imputation method's name ('mice' (default setting) or 'missForest')
#' @param del_rate deletion rate to complete dataset.
#' @param iter the number of of iteration
#' @param penl calculation method of residual
#' @param patch_rates patching rate. This parameter allow vector like c(0.1, 0.2,0.3)
#' @param elim_rates elimination rate. This parameter allow vector like c(0.1, 0.2,0.3)
#'
#' @importFrom stats quantile
#' @importFrom mice mice
#' @importFrom mice complete
#' @importFrom missForest missForest
#' @importFrom missForest prodNA
#'
#' @examples
#' DPdii(iris[,-ncol(iris)], iter=1000)
#' out <- DPdii(iris[,-ncol(iris)],iter=1000)
#' out[["patch_rate_0.1_elim_rate_0.2"]]
#'
#' @return list of dataset
#'
#' out\[\["patch_rate_0.1_elim_rate_0.2"\]\] return the dataset that its parameter is "patch_rate = 0.1" and "elim_rate = 0.2"
#'
#' @export DPdii

DPdii<-function(data.df, imp="mice", del_rate=0.05, patch_rates=0.1, elim_rates=0.2, iter=1000, penl="SQD"){

  out.ls<-NULL
  list_names.ls<-NULL

  for(i in 1:iter){
    missing.df<-missForest::prodNA(data.df,noNA=del_rate)
    if(imp=="mice"){
      data_mice.mice<-mice::mice(missing.df,seed=i,m=1,printFlag=FALSE,remove.collinear = FALSE)
      imp.df<-mice::complete(data_mice.mice,1)
    }else if(imp=="missForst"){
      imp.df<-missForest::missForest(missing.df)$ximp
    }
    if(penl=="ABD"){
      if(!exists("diff_sum.df")){#absolute difference
        diff_sum.df<-abs(data.df-imp.df)
        missing_count.df<-is.na(missing.df)
      }else{
        diff_sum.df<-diff_sum.df+abs(data.df-imp.df)
        missing_count.df<-missing_count.df+is.na(missing.df)
      }
    }else if(penl=="SQD"){#squared difference
      if(!exists("diff_sum.df")){
        diff_sum.df<-(data.df-imp.df)^2
        missing_count.df<-is.na(missing.df)
      }else{
        diff_sum.df<-diff_sum.df+abs(data.df-imp.df)^2
        missing_count.df<-missing_count.df+is.na(missing.df)
      }
    }
    if(!exists("imp_sum.df")){
      imp_sum.df<-imp.df
    }else{
      imp_sum.df<-imp_sum.df+imp.df
    }
  }

  diff.df<-diff_sum.df/missing_count.df
  patch.df<-imp_sum.df/missing_count.df
  sum_diff.ls<-apply(diff.df,1,sum)
  data.df$rank<-rank(sum_diff.ls)
  patch.df$rank<-data.df$rank

  replace_checker<-function(diff.ls){
    qu_3rd<-quantile(diff.ls,0.75)
    replace_checker.ls<-diff.ls>qu_3rd
  }
  replace_check.df<-data.frame(apply(diff.df,2,replace_checker))
  replace_check.df$rank<-data.df$rank


  for(elim_rate in elim_rates){
    for(patch_rate in patch_rates){
      patch_data.df<-subset(data.df,
                            (data.df$rank>round(nrow(data.df)*(1-(patch_rate+elim_rate))))
                            &
                            (data.df$rank<=round(nrow(data.df)*(1-elim_rate)))
      )

      patch_replace_check.df<-subset(replace_check.df,
                                    (replace_check.df$rank>round(nrow(replace_check.df)*(1-(patch_rate+elim_rate))))
                                    &
                                    (replace_check.df$rank<=round(nrow(replace_check.df)*(1-elim_rate)))
      )

      patch_patch.df<-subset(patch.df,
                            (patch.df$rank>round(nrow(patch.df)*(1-(patch_rate+elim_rate))))
                            &
                            (patch.df$rank<=round(nrow(patch.df)*(1-elim_rate)))
      )

      patch_comp.df<-patch_data.df
      patch_comp.df[patch_replace_check.df==T]<-patch_patch.df[patch_replace_check.df==T]

      unpatch_data.df<-subset(data.df,(data.df$rank<=round(nrow(data.df)*(1-(patch_rate+elim_rate)))))
      comp.df<-rbind(unpatch_data.df,patch_comp.df)
      comp.df<-subset(comp.df,select=-c(rank))

      list_name<-paste('patch_rate',patch_rate,'elim_rate',elim_rate,sep='_')
      list_names.ls<-c(list_names.ls,list(list_name))
      out.ls<-c(out.ls,list(comp.df))
      names(out.ls)<-list_names.ls
    }
  }
  return(out.ls)
}
