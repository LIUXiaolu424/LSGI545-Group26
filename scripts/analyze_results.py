#!/usr/bin/env python3
"""Summarize actual BehaviorSpace output and generate report-ready figures."""

from __future__ import annotations

import csv
import math
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
FIGURES = ROOT / "figures"


def header_row(path: Path) -> int:
    with path.open(encoding="utf-8-sig", newline="") as handle:
        for index, line in enumerate(handle):
            if line.lstrip().startswith('"[run number]"') or line.startswith("[run number]"):
                return index
    raise ValueError(f"BehaviorSpace header not found in {path}")


def read_bs(path: Path) -> pd.DataFrame:
    if not path.is_file():
        raise FileNotFoundError(f"Required actual NetLogo output is missing: {path}")
    frame = pd.read_csv(path, skiprows=header_row(path))
    frame.columns = [str(column).strip() for column in frame.columns]
    return frame


def ci95(series: pd.Series) -> float:
    clean = pd.to_numeric(series, errors="coerce").dropna()
    if len(clean) < 2:
        return 0.0
    return 1.96 * clean.std(ddof=1) / math.sqrt(len(clean))


def scenario_label(row: pd.Series) -> str:
    return f"I={row['isolation-compliance']:g}, C={row['cleaning-frequency']:g}, E={row['post-symptom-exclusion']:g}"


def main() -> None:
    FIGURES.mkdir(parents=True, exist_ok=True)
    main_df = read_bs(RESULTS / "main_interventions_18x50.csv")
    factors = ["isolation-compliance", "cleaning-frequency", "post-symptom-exclusion"]
    metrics = ["final-attack-rate", "peak-infectious", "time-to-peak", "outbreak-duration",
               "direct-infections", "environmental-infections", "isolation-person-days"]
    for column in factors + metrics:
        main_df[column] = pd.to_numeric(main_df[column], errors="raise")

    grouped = main_df.groupby(factors, as_index=False)
    summary = grouped[metrics].agg(["mean", "std", "count"])
    summary.columns = ["_".join(filter(None, column)).rstrip("_") for column in summary.columns.to_flat_index()]
    for metric in metrics:
        summary[f"{metric}_se"] = summary[f"{metric}_std"] / np.sqrt(summary[f"{metric}_count"])
        summary[f"{metric}_ci95"] = 1.96 * summary[f"{metric}_se"]
    summary.to_csv(RESULTS / "scenario_summary.csv", index=False)

    plot_df = summary.sort_values(factors).reset_index(drop=True)
    labels = [scenario_label(row) for _, row in plot_df.iterrows()]
    fig, ax = plt.subplots(figsize=(13, 6.5))
    x = np.arange(len(plot_df))
    ax.bar(x, plot_df["final-attack-rate_mean"], color="#377eb8", alpha=0.9)
    ax.errorbar(x, plot_df["final-attack-rate_mean"], yerr=plot_df["final-attack-rate_ci95"],
                fmt="none", ecolor="black", capsize=3, linewidth=1)
    ax.set_xticks(x, labels, rotation=65, ha="right")
    ax.set_ylabel("Mean final attack rate")
    ax.set_xlabel("Scenario (isolation compliance, cleaning/day, exclusion days)")
    ax.set_ylim(0, min(1, max(0.1, float((plot_df["final-attack-rate_mean"] + plot_df["final-attack-rate_ci95"]).max()) * 1.12)))
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIGURES / "figure1_attack_rate_18_scenarios.png", dpi=300)
    plt.close(fig)

    time_path = RESULTS / "baseline_timeseries_50.csv"
    if time_path.is_file():
        time_df = read_bs(time_path)
        state_columns = {
            'count students with [disease-state = "S"]': "S",
            'count students with [disease-state = "E"]': "E",
            'count students with [disease-state = "I-sym"]': "I-sym",
            'count students with [disease-state = "I-asym"]': "I-asym",
            'count students with [disease-state = "P"]': "P",
            'count students with [disease-state = "R"]': "R",
        }
        fig, ax = plt.subplots(figsize=(10, 6))
        colors = {"S": "#377eb8", "E": "#ffd92f", "I-sym": "#e41a1c", "I-asym": "#ff7f00", "P": "#984ea3", "R": "#4daf4a"}
        ticks = sorted(pd.to_numeric(time_df["[step]"], errors="coerce").dropna().unique())
        for source, label in state_columns.items():
            time_df[source] = pd.to_numeric(time_df[source], errors="coerce")
            stats = time_df.groupby("[step]")[source].agg(["mean", "std", "count"]).reindex(ticks)
            ci = 1.96 * stats["std"].fillna(0) / np.sqrt(stats["count"].clip(lower=1))
            ax.plot(ticks, stats["mean"], label=label, color=colors[label])
            ax.fill_between(ticks, stats["mean"] - ci, stats["mean"] + ci, color=colors[label], alpha=0.12)
        ax.set_xlabel("Tick (6 hours)")
        ax.set_ylabel("Students")
        ax.set_title("Baseline epidemic curve (mean and 95% CI)")
        ax.legend(ncol=3)
        ax.grid(alpha=0.2)
        fig.tight_layout()
        fig.savefig(FIGURES / "figure2_baseline_epidemic_curve.png", dpi=300)
        plt.close(fig)

    for exclusion in [0, 2]:
        subset = plot_df[plot_df["post-symptom-exclusion"] == exclusion]
        pivot = subset.pivot(index="isolation-compliance", columns="cleaning-frequency", values="final-attack-rate_mean")
        fig, ax = plt.subplots(figsize=(6.5, 5))
        image = ax.imshow(pivot.values, cmap="YlOrRd", vmin=0, vmax=max(0.01, float(plot_df["final-attack-rate_mean"].max())), aspect="auto")
        ax.set_xticks(range(len(pivot.columns)), [f"{v:g}" for v in pivot.columns])
        ax.set_yticks(range(len(pivot.index)), [f"{v:g}" for v in pivot.index])
        ax.set_xlabel("Cleaning frequency (times/day)")
        ax.set_ylabel("Isolation compliance")
        ax.set_title(f"Mean attack rate: post-symptom exclusion = {exclusion} days")
        for i in range(pivot.shape[0]):
            for j in range(pivot.shape[1]):
                ax.text(j, i, f"{pivot.values[i, j]:.3f}", ha="center", va="center", color="black")
        fig.colorbar(image, ax=ax, label="Mean final attack rate")
        fig.tight_layout()
        fig.savefig(FIGURES / f"figure3_heatmap_exclusion_{exclusion}.png", dpi=300)
        plt.close(fig)

    fig, ax = plt.subplots(figsize=(13, 6.5))
    width = 0.4
    ax.bar(x - width / 2, plot_df["direct-infections_mean"], width, label="Direct", color="#377eb8")
    ax.bar(x + width / 2, plot_df["environmental-infections_mean"], width, label="Environmental", color="#ff7f00")
    ax.set_xticks(x, labels, rotation=65, ha="right")
    ax.set_ylabel("Mean infections")
    ax.legend()
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIGURES / "figure4_transmission_routes.png", dpi=300)
    plt.close(fig)
    print(f"Wrote {RESULTS / 'scenario_summary.csv'} and figures under {FIGURES}")


if __name__ == "__main__":
    main()
