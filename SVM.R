library(ggplot2)

data(iris)
iris2cat = iris[1:100,]

f = ggplot(iris2cat, aes(Sepal.Width, 
                        Sepal.Length, colour = Species))
f + geom_jitter() + scale_colour_hue() + 
  theme(legend.position = "bottom") + labs(x = 'Sepal Width', y = "Sepal Length")