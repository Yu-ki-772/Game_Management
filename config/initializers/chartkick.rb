# chartkickの共通設定
Chartkick.options = {
  library: {
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: "#111827",
        borderColor:     "rgba(255,255,255,0.1)",
        borderWidth:     1,
        titleColor:      "#d1d5db",
        bodyColor:       "#9ca3af",
        padding:         10
      }
    },
    scales: {
      x: {
        ticks: { color: "#9ca3af", font: { size: 11 } },
        grid:  { color: "rgba(107,114,128,0.1)" }
      },
      y: {
        ticks: { color: "#9ca3af", font: { size: 11 } },
        grid:  { color: "rgba(107,114,128,0.1)" }
      }
    }
  }
}

