updateSliderInput(session, "filter_severity_adult", "Adult qSOFA score", min = 0, max = 3, value = c(0, 3))
updatePrettySwitch(session, "filter_severity_child_0", label = "Include Child/Neonate with 0 severity criteria", value = TRUE)
updatePrettySwitch(session, "filter_severity_child_1", label = "Include Child/Neonate with ≥ 1 severity criteria", value = TRUE)