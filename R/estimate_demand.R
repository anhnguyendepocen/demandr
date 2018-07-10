## DOCUMENTATION!

estimate_demand <- function(df,
                            market_ids,
                            market_share,
                            outside_share,
                            exog_charac,
                            price,
                            nest_shares = NULL,
                            instruments = NULL,
                            marketFE = "both",
                            supply_side = FALSE
                            ){
    # estimate OLS Model with no supply side
    if(supply_side == FALSE && is.null(instruments)){
        estimating_equation <- create_equation(market_ids,
                                                market_share,
                                                outside_share,
                                                exog_charac,
                                                price,
                                                nest_shares,
                                                instruments,
                                                marketFE)

        output <- lm(estimating_equation, data = df)
        return(output)
    }
}

create_lhs <- function(exog_charac, price, nest_shares){
    lhs_variables <- c(exog_charac, price, nest_shares)
    lhs_formula   <- paste(lhs_variables, collapse = "+")
    return(lhs_formula)
}

create_fe <- function(market_ids, market_fe = "both"){

    if(market_fe == "both"){
        mkt_fe <- unlist(market_ids)
        mkt_fe <- lapply("as.factor(", paste, unlist(mkt_ids), ")", sep = "")[[1]]
        mkt_fe <- paste(mkt_fe, collapse = "+")
        return(mkt_fe)
    } else if(market_fe == "geog") {
        mkt_fe <- lapply("as.factor(", paste, unlist(mkt_ids$geog_id), ")", sep = "")[[1]]
        return(mkt_fe)
    } else if (market_fe == "time"){
        mkt_fe <- lapply("as.factor(", paste, unlist(mkt_ids$time_id), ")", sep = "")[[1]]
        return(mkt_fe)
    }

}

create_rhs <- function(mkt_share, out_share){
    log_mktshare <- paste0("log(", mkt_share, ")")
    log_outshare <- paste0("log(", out_share, ")")

    dep_var <- paste(log_mktshare, log_outshare, sep = "-")
    return(dep_var)
}

create_equation <- function(market_ids,
                            market_share,
                            outside_share,
                            exog_charac,
                            price,
                            nest_shares,
                            instruments = NULL,
                            marketFE = "both"){


     y             <- create_rhs(market_share, outside_share)
     lhs_charac    <- create_lhs(exog_charac, price, nest_shares)
     fixed_effects <- create_fe(market_ids, market_fe = marketFE)

    if (is.null(instruments)){
        est_eq <- paste(y, lhs_charac, sep = "~")
        est_eq_fe <- as.formula(paste(est_eq, fixed_effects, sep = "+"))
    }

    return(est_eq_fe)
}