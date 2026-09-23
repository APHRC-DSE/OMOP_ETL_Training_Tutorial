library(ggplot2)

### ggplot themes

ggtheme_descriptive_plot <- function(angletext_yaxis=0, angletext_xaxis=0, textsize_yaxis=10, textsize_xaxis=10,
                                     legendtext_size = 8, legendtitle_size = 8, legendtitle_colour = "red",
                                     striptext_size_x = 9, striptext_size_y = 9){
  theme_set(theme_minimal() +
              theme(
                legend.position="bottom",
                legend.text = element_text(size = legendtext_size),
                legend.title = element_text(size = legendtitle_size, color = legendtitle_colour, face = "bold", hjust = 0.5),
                axis.line.y = element_line(colour = "grey",inherit.blank = FALSE),
                axis.line.x = element_line(colour = "grey",inherit.blank = FALSE),
                axis.ticks.y = element_line(linewidth = 0.5, color="black"),
                axis.ticks.x = element_line(linewidth = 0.5, color="black"),
                axis.text.y = element_text(angle = angletext_yaxis, lineheight = 0.7, size = textsize_yaxis), #hjust = 0.5
                axis.text.x = element_text(angle = angletext_xaxis, lineheight = 0.7, size = textsize_xaxis), #vjust = 0.5
                plot.title = element_text(hjust = 0.5, face = "bold", size = 10),
                plot.caption = element_text(angle = 0, size = 10, face = "italic"),
                axis.title.x = element_text(size = 10, face = "bold"),
                axis.title.y = element_text(size = 10, face = "bold"),
                strip.text.x = element_text(size = striptext_size_x),
                strip.text.y = element_text(size = striptext_size_y),
                panel.grid.major.y = element_blank(),
                panel.grid.major.x = element_blank(),
                panel.grid.minor.x = element_blank(),
                panel.grid.minor.y = element_blank()
              )
  )
}

