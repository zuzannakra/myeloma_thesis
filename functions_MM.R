main_theme <- function() {
  theme(
    axis.text.y = element_text(size = 10, color = "black"),
    axis.text.x = element_text(size = 10, color = "black"),
    axis.title.y = element_text(size = 10, color = "black"),
    axis.title.x = element_text(size = 10, color = "black"),
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    axis.line = element_line(size = 0.5, linetype = "solid",
                             colour = "black"),
    legend.key.size = unit(0.8, "cm"),
    legend.text = element_text(size =10, color = "black")
  )
}

elbow <- function (df){
  wss <- (nrow(df) - 1) * sum(apply(df, 2, var))
  max_clusters <- min(nrow(df) - 1, 15)
  for (i in 2:max_clusters) wss[i] <- sum(kmeans(df, centers = i)$withinss)  
  plot(1:max_clusters, wss, type = "b", 
       xlab = "Number of clusters",
       ylab = "Within groups sum of squares", 
       main = "Elbow Method for Optimal Clusters")
}


