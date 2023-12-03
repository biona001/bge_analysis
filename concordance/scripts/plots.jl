using Plots
gr(fmt=:png)
include("utilities.jl")

function make_aggregate_R2_plot(
    aggregate_R2::Vector{T},
    plt_label::String,
    maf_bins::Vector{T},
    plt_title::String
    ) where T
    maf_bin_xaxis = [(maf_bins[i] + maf_bins[i-1])/2 for i in 2:length(maf_bins)]
    plt = plot(maf_bin_xaxis, aggregate_R2, markershape=:circle, 
        ylabel="Aggregate R2", label=plt_label,
        xlabel="MAF (%)", xaxis=:log, ylim=(0, 1), xlim=(0.00003, 0.6),
        xticks=([0.0001, 0.001, 0.01, 0.1, 0.5], ["0.01", "0.1", "1", "10", "50"]),
        legend=:bottomright, title=plt_title)
    return plt
end

function make_aggregate_R2_plots(
    aggregate_R2s::Vector{Vector{T}},
    plt_labels::Vector{String},
    maf_bins::Vector{T},
    plt_title::String
    ) where T
    maf_bin_xaxis = [(maf_bins[i] + maf_bins[i-1])/2 for i in 2:length(maf_bins)]   

    # make init plot
    plt = make_aggregate_R2_plot(
        aggregate_R2s[1], plt_labels[1], maf_bins, plt_title
    )

    # remaining plots
    for i in 2:length(aggregate_R2s)
        plot!(plt, maf_bin_xaxis, aggregate_R2s[i], label=plt_labels[i], markershape=:circle)
    end

    return plt
end

function make_non_ref_concordance_plot(
    concordance::Vector{T},
    mafs::Vector{T},
    plt_label::String,
    maf_bins::Vector{T},
    plt_title::String
    ) where T
    length(concordance) == length(mafs) || 
        error("expected length(concordance) == length(mafs)")
    
    maf_bin_xaxis = [(maf_bins[i] + maf_bins[i-1])/2 for i in 2:length(maf_bins)]
    concordance_by_maf_bins = T[]
    for i in 2:length(maf_bins)
        idx = findall(x -> maf_bins[i-1] ≤ x ≤ maf_bins[i], mafs)
        cur_concordance = concordance[idx]
        non_nan_idx = findall(!isnan, cur_concordance)
        push!(concordance_by_maf_bins, mean(cur_concordance[non_nan_idx]))
    end

    plt = plot(maf_bin_xaxis, concordance_by_maf_bins, markershape=:circle, 
        ylabel="Non-ref conconcordance", label=plt_label,
        xlabel="MAF (%)", xaxis=:log, ylim=(0, 1), xlim=(0.00003, 0.6),
        xticks=([0.0001, 0.001, 0.01, 0.1, 0.5], ["0.01", "0.1", "1", "10", "50"]),
        legend=:bottomright, title=plt_title)
    
    return plt
end

function make_non_ref_concordance_plots(
    concordances::Vector{Vector{T}},
    mafs::Vector{Vector{T}},
    plt_labels::Vector{String},
    maf_bins::Vector{T},
    plt_title::String
    ) where T
    length(concordances) == length(mafs) == length(plt_labels) || 
        error("expected length(concordances) == length(mafs)")

    maf_bin_xaxis = [(maf_bins[i] + maf_bins[i-1])/2 for i in 2:length(maf_bins)]

    # make init plot
    plt = make_non_ref_concordance_plot(
        concordances[1], mafs[1], plt_labels[1], maf_bins, plt_title
    )

    # remaining plots
    for j in 2:length(concordances)
        concordance = concordances[j]
        maf = mafs[j]

        concordance_by_maf_bins = T[]
        for i in 2:length(maf_bins)
            idx = findall(x -> maf_bins[i-1] ≤ x ≤ maf_bins[i], maf)
            cur_concordance = concordance[idx]
            non_nan_idx = findall(!isnan, cur_concordance)
            push!(concordance_by_maf_bins, mean(cur_concordance[non_nan_idx]))
        end

        plot!(plt, maf_bin_xaxis, concordance_by_maf_bins,
            label=plt_labels[j], markershape=:circle)
    end

    return plt
end